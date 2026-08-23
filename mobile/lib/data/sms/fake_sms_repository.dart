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

  static const _batteryPct = 78;
  static const _serial = '2500000016';

  /// The tracker every single-recipient reply comes from.
  static MockTracker get _unit => smsTrackers.firstWhere(
    (t) => t.id == '2500000016',
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
        smsText: '#000000,RDBL',
      ),
      ReceivedChatMessage(
        timestamp: ago(33),
        from: smsTrackers[0].phone,
        body: 'BAT:86%,CHG:1',
      ),
      ReceivedChatMessage(
        timestamp: ago(33),
        from: smsTrackers[1].phone,
        body: 'BAT:41%,CHG:0',
      ),
      ReceivedChatMessage(
        timestamp: ago(32),
        from: _unit.phone,
        body: 'BAT:$_batteryPct%,CHG:0',
      ),
      SentChatMessage(
        timestamp: ago(18),
        recipientShorts: [_unit.short],
        commandId: 'position',
        smsText: '#000000,RDLO',
      ),
      ReceivedChatMessage(
        timestamp: ago(17),
        from: _unit.phone,
        body: _positionReport('09:14:22'),
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
  /// Commands look like `#<password>,<KEY>[:<args>]`, except the two lock
  /// controls, which use the parenthesised `(P4x,…)` form.
  static String _replyTo(String body) {
    if (body.startsWith('(P43')) return 'P43 OK';
    if (body.startsWith('(P44')) return 'PWD CHANGED OK';

    final comma = body.indexOf(',');
    if (comma == -1) return 'ERR:FORMAT';
    final command = body.substring(comma + 1);
    final colon = command.indexOf(':');
    final key = (colon == -1 ? command : command.substring(0, colon)).trim();
    final args = colon == -1 ? '' : command.substring(colon + 1).trim();

    return switch (key) {
      'RDBL' => 'BAT:$_batteryPct%,CHG:0',
      'RDLS' => 'LOCK:1,COVER:0,ROPE:0,MOTOR:0',
      'RDLO' => _positionReport(_clock()),
      'RDRF' => 'RFID:2226557347,2226557351',
      'SLRA' => 'PH1:${smsTrackers[0].phone},PH2:${smsTrackers[1].phone}',
      'RDVE' => 'VER:HB_V1.0.0.07 2026-02-06',
      'REST' => 'REST OK',
      'CLRD' => 'CLRD OK',
      'INIT' => 'INIT-SYS OK',
      'STPF' => '$args OK',
      _ => args.isEmpty ? '$key OK' : '$key:$args OK',
    };
  }

  /// The documented status report: `*MM/DD/YY,HH:MM:SS,SN,lat,N,lon,E,speed,
  /// height,&,battery,charging,unlock,chainBreak,simCover,topCover,motor#`
  static String _positionReport(String time) =>
      '*08/20/26,$time,$_serial,37.960077,N,58.326063,E,0,214,&,'
      '$_batteryPct,0,1,0,0,0,0#';

  static String _clock() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}
