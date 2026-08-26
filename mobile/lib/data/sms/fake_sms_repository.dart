import 'dart:async';

import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

/// [SmsRepository] that answers as the trackers would, without a SIM.
///
/// It behaves like a device on the other end of the line: [send] takes the
/// same command text the real path sends, parses the command out of it, and
/// pushes a reply onto [incoming] a moment later. The UI cannot tell the
/// difference — it sends text and waits for messages either way.
///
/// The reply bodies follow the vendor's formats. The position report is the
/// documented one, comma-delimited and framed by `*` and `#`; the short
/// `KEY:value` acknowledgements are representative rather than verified.
class FakeSmsRepository implements SmsRepository {
  final _incoming = StreamController<IncomingSms>.broadcast();

  static const _batteryMv = 4021;
  static const _imei = '352094081234505';

  /// The tracker every single-recipient reply comes from.
  static MockTracker get _unit => smsTrackers.firstWhere(
    (t) => t.id == _imei,
    orElse: () => smsTrackers.first,
  );

  @override
  Future<bool> ensureReady() async => true;

  @override
  Stream<IncomingSms> get incoming => _incoming.stream;

  @override
  Future<Set<String>> loadRecipientSelection() async => {
    smsTrackers[0].id,
    smsTrackers[1].id,
    _unit.id,
  };

  @override
  Future<List<ChatMessage>> loadHistory() async {
    final now = DateTime.now();
    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));
    final selected = await loadRecipientSelection();

    return [
      SentChatMessage(
        timestamp: ago(34),
        recipientShorts: selected
            .map((id) => smsTrackers.firstWhere((t) => t.id == id).short)
            .toList(),
        commandId: 'battery',
        smsText: '  readio 67',
      ),
      ReceivedChatMessage(
        timestamp: ago(33),
        from: smsTrackers[0].phone,
        body: 'IO ID:67 Value:4102',
      ),
      ReceivedChatMessage(
        timestamp: ago(33),
        from: smsTrackers[1].phone,
        body: 'IO ID:67 Value:3874',
      ),
      ReceivedChatMessage(
        timestamp: ago(32),
        from: _unit.phone,
        body: 'IO ID:67 Value:$_batteryMv',
      ),
      SentChatMessage(
        timestamp: ago(18),
        recipientShorts: [_unit.short],
        commandId: 'gps',
        smsText: '  getgps',
      ),
      ReceivedChatMessage(
        timestamp: ago(17),
        from: _unit.phone,
        body: _gpsReport(),
      ),
    ];
  }

  @override
  Future<bool> send({
    required String to,
    required String body,
    int subscriptionId = -1,
  }) async {
    Timer(const Duration(milliseconds: 1200), () {
      if (_incoming.isClosed) return;
      _incoming.add(IncomingSms(from: to, body: _replyTo(body)));
    });
    return true;
  }

  /// Closes the reply stream.
  Future<void> dispose() => _incoming.close();

  // ── Canned device ─────────────────────────────────────────────────────────

  /// Picks a reply for a command the app sent.
  ///
  /// Teltonika messages arrive as `<login> <password> <command> [args]`, so
  /// the credentials are dropped and the verb is whatever is left.
  static String _replyTo(String body) {
    final parts = body.trim().split(RegExp(r'\s+'));
    // A password may or may not be present; the verb is the first token that
    // is not one.
    final verb = parts.firstWhere(
      (p) => _verbs.contains(p),
      orElse: () => parts.isEmpty ? '' : parts.last,
    );
    final args = parts.skipWhile((p) => p != verb).skip(1).join(' ');

    return switch (verb) {
      'getinfo' =>
        'INI:2026/8/25 09:02 RTC:2026/8/25 10:42 RST:2 ERR:0 SR:0 BR:0 '
            'CF:0 FG:0 FL:0 SMS:2 NOGPS:0:04 GPS:3 SAT:9 RS:3 MD:4',
      'getgps' => _gpsReport(),
      'getio' => 'DI1:0 DI2:0 DI3:0 AIN1:0.0 DO1:1 DO2:0',
      'getstatus' =>
        'Data Link:1 GPRS:1 Phone:0 SIM:0 OP:43801 Signal:4 NewSMS:0 '
            'Roaming:0 SMSFull:0 LAC:8322 Cell ID:51',
      'getver' =>
        'Ver:03.27.07 Rev:00 GPS:AXN_5.10 Hw:FMB920 Mod:11 '
            'IMEI:$_imei Init:2026/1/9',
      'readio' => 'IO ID:$args Value:$_batteryMv',
      'getparam' => '$args:30',
      'setparam' => '$args OK',
      'setdigout' => 'DOUT1:${args.startsWith('1') ? 1 : 0} OK',
      'cpureset' => 'CPU reset in progress',
      'deleterecords' => 'Records deleted',
      _ => 'Unknown command: $verb',
    };
  }

  /// Verbs this device answers to — the catalogue in `mock_data.dart`.
  static const _verbs = {
    'getinfo',
    'getgps',
    'getio',
    'getstatus',
    'getver',
    'readio',
    'getparam',
    'setparam',
    'setdigout',
    'cpureset',
    'deleterecords',
  };

  /// The documented `getgps` answer.
  static String _gpsReport() =>
      'GPS:1 Sat:9 Lat:37.960077 Long:58.326063 Alt:214 Speed:0 Dir:126 '
      'Date:2026/8/25 Time:${_clock()}';

  static String _clock() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}
