import 'dart:async';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/foundation.dart';

/// Background handler — runs in a separate Dart isolate when the app is
/// killed/backgrounded. Cannot touch Flutter UI state; foreground reception
/// via [SmsService.incoming] is sufficient for testing.
@pragma('vm:entry-point')
void onBackgroundSms(SmsMessage message) {}

/// Thin singleton wrapper around the [Telephony] package.
///
/// Call [ensureReady] before anything else — it grants permissions and
/// registers the broadcast receiver. Send with [send].
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
class SmsService {
  SmsService._();
  static final instance = SmsService._();

  final _telephony = Telephony.instance;
  final _incomingCtrl = StreamController<SmsMessage>.broadcast();
  bool _listening = false;
  bool _granted = false;
  Future<bool>? _pending;

  /// Emits every incoming [SmsMessage] while the app is in the foreground.
  Stream<SmsMessage> get incoming => _incomingCtrl.stream;

  /// Requests SEND_SMS/RECEIVE_SMS/phone permissions and, once granted,
  /// registers the incoming-SMS broadcast receiver.
  ///
  /// Safe to call from anywhere, any number of times: concurrent callers all
  /// await the same in-flight request instead of starting a second one. A
  /// grant is remembered; a denial is not, so a later call can ask again.
  Future<bool> ensureReady() {
    final pending = _pending;
    if (pending != null) return pending;

    final request = _prepare();
    _pending = request;
    request
        .then((granted) {
          if (!granted) _pending = null;
        })
        .ignore();
    return request;
  }

  Future<bool> _prepare() async {
    if (!_granted) {
      debugPrint('[SmsService] ensureReady: requesting permissions');
      _granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
      debugPrint('[SmsService] ensureReady: granted=$_granted');
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
    debugPrint('[SmsService] registering broadcast receiver');
    _telephony.listenIncomingSms(
      onNewMessage: (msg) {
        debugPrint(
          '[SmsService] incoming SMS — from=${msg.address} body=${msg.body}',
        );
        _incomingCtrl.add(msg);
      },
      onBackgroundMessage: onBackgroundSms,
      listenInBackground: true,
    );
  }

  /// Sends [body] as an SMS to [to]. The [onStatus] callback fires once the
  /// platform confirms SENT or DELIVERED, or with `false` if the permissions
  /// were refused.
  ///
  /// Pass [subscriptionId] (from `SimCard.subscriptionId`) to send via a
  /// specific SIM; -1 leaves the choice to the Android default-SMS SIM.
  Future<void> send({
    required String to,
    required String body,
    int subscriptionId = -1,
    void Function(bool success)? onStatus,
  }) async {
    if (!await ensureReady()) {
      debugPrint('[SmsService] send: no permission, dropping message to $to');
      onStatus?.call(false);
      return;
    }
    debugPrint('[SmsService] send: to=$to body=$body subId=$subscriptionId');
    await _telephony.sendSms(
      to: to,
      message: body,
      subscriptionId: subscriptionId,
      statusListener: (status) {
        final ok = status == SendStatus.SENT || status == SendStatus.DELIVERED;
        debugPrint('[SmsService] send status: to=$to status=$status ok=$ok');
        onStatus?.call(ok);
      },
    );
  }
}
