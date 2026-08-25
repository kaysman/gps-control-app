import 'dart:async';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/foundation.dart';
import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/models/chat_message.dart';

/// Background handler — runs in a separate Dart isolate when the app is
/// killed/backgrounded. Cannot touch Flutter UI state; foreground reception
/// via [SmsRepository.incoming] is sufficient for testing.
@pragma('vm:entry-point')
void onBackgroundSms(SmsMessage message) {}

/// [SmsRepository] backed by the device's telephony stack.
///
/// ## Why everything funnels through [ensureReady]
///
/// The Android side of `another_telephony` (`SmsMethodCallHandler`) keeps a
/// *single* pending `MethodChannel.Result`, action and permission request
/// code as instance fields. Any call that needs a permission it doesn't have
/// yet — `requestPhoneAndSmsPermissions`, `listenIncomingSms` (via
/// `startBackgroundService`) or `sendSms` — parks its reply there and fires an
/// Android permission request. Two of those in flight at once overwrite each
/// other: the first result answers the reply, then Android delivers the
/// second result against the same, already-answered reply and the plugin
/// throws `IllegalStateException: Reply already submitted` on the main
/// thread, killing the app.
///
/// So: only ever one permission request in flight, and never touch a
/// permission-gated telephony call before the grant has landed.
// Constructed by the composition root in main.dart; the lint does not see
// through the interface-typed factory that hands it out.
// ignore: unreachable_from_main
class TelephonySmsRepository implements SmsRepository {
  final Telephony _telephony = Telephony.instance;
  final _incoming = StreamController<IncomingSms>.broadcast();
  bool _listening = false;
  bool _granted = false;
  Future<bool>? _pending;

  @override
  Stream<IncomingSms> get incoming => _incoming.stream;

  /// Nothing is persisted yet, so history starts empty on every launch and
  /// lives only in the page's own state for the session.
  @override
  Future<List<ChatMessage>> loadHistory() async => const [];

  /// Likewise: no persisted selection yet.
  @override
  Future<Set<String>> loadRecipientSelection() async => const {};

  /// Requests SEND_SMS/RECEIVE_SMS/phone permissions and, once granted,
  /// registers the incoming-SMS broadcast receiver.
  ///
  /// Concurrent callers all await the same in-flight request instead of
  /// starting a second one. A grant is remembered; a denial is not, so a later
  /// call can ask again.
  @override
  Future<bool> ensureReady() {
    final pending = _pending;
    if (pending != null) return pending;

    final request = _prepare();
    _pending = request;
    request.then((granted) {
      if (!granted) _pending = null;
    }).ignore();
    return request;
  }

  @override
  Future<bool> send({
    required String to,
    required String body,
    int subscriptionId = -1,
  }) async {
    if (!await ensureReady()) {
      debugPrint('[SmsRepo] send: no permission, dropping message to $to');
      return false;
    }

    debugPrint('[SmsRepo] send: to=$to body=$body subId=$subscriptionId');
    // sendSms reports SENT and then DELIVERED; the first verdict is the answer.
    final settled = Completer<bool>();
    await _telephony.sendSms(
      to: to,
      message: body,
      subscriptionId: subscriptionId,
      statusListener: (status) {
        final ok = status == SendStatus.SENT || status == SendStatus.DELIVERED;
        debugPrint('[SmsRepo] send status: to=$to status=$status ok=$ok');
        if (!settled.isCompleted) settled.complete(ok);
      },
    );
    return settled.future;
  }

  Future<bool> _prepare() async {
    if (!_granted) {
      debugPrint('[SmsRepo] ensureReady: requesting permissions');
      _granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
      debugPrint('[SmsRepo] ensureReady: granted=$_granted');
    }
    if (!_granted) return false;
    _startListening();
    return true;
  }

  /// Registers the broadcast receiver. Only called once the permissions are
  /// already granted — otherwise `listenIncomingSms` would kick off its own
  /// Android permission request and race the one in [ensureReady].
  void _startListening() {
    if (_listening) return;
    _listening = true;
    debugPrint('[SmsRepo] registering broadcast receiver');
    _telephony.listenIncomingSms(
      onNewMessage: (msg) {
        debugPrint(
          '[SmsRepo] incoming SMS — from=${msg.address} body=${msg.body}',
        );
        _incoming.add(
          IncomingSms(from: msg.address ?? 'unknown', body: msg.body ?? ''),
        );
      },
      onBackgroundMessage: onBackgroundSms,
    );
  }
}
