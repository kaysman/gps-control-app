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
/// Call [requestPermissions] once on app start, then [startListening] to
/// receive incoming SMS. Send with [send].
class SmsService {
  SmsService._();
  static final instance = SmsService._();

  final _telephony = Telephony.instance;
  final _incomingCtrl = StreamController<SmsMessage>.broadcast();
  bool _listening = false;

  /// Emits every incoming [SmsMessage] while the app is in the foreground.
  Stream<SmsMessage> get incoming => _incomingCtrl.stream;

  /// Requests SEND_SMS and RECEIVE_SMS at runtime. Returns true if granted.
  Future<bool> requestPermissions() async {
    debugPrint('[SmsService] requestPermissions: requesting...');
    final granted = await _telephony.requestPhoneAndSmsPermissions;
    debugPrint('[SmsService] requestPermissions: granted=$granted');
    return granted ?? false;
  }

  /// Registers the broadcast receiver. Safe to call multiple times.
  void startListening() {
    if (_listening) {
      debugPrint('[SmsService] startListening: already listening, skip');
      return;
    }
    _listening = true;
    debugPrint('[SmsService] startListening: registering broadcast receiver');
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
  /// platform confirms SENT or DELIVERED.
  ///
  /// Pass [subscriptionId] (from `SimCard.subscriptionId`) to send via a
  /// specific SIM; -1 leaves the choice to the Android default-SMS SIM.
  void send({
    required String to,
    required String body,
    int subscriptionId = -1,
    void Function(bool success)? onStatus,
  }) {
    debugPrint('[SmsService] send: to=$to body=$body subId=$subscriptionId');
    _telephony.sendSms(
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
