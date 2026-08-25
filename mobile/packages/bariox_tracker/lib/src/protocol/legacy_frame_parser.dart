import 'dart:typed_data';

import 'package:bariox_tracker/src/models/legacy_status.dart';

/// Parses incoming notifications from a lock running the legacy `AA-55-A9`
/// protocol.
///
/// Successful response frames have the same overall shape as requests:
/// ```text
/// [0xAA][0x55][0xA9][CMD][LEN_H][LEN_L][0x01][0x01][DATA ...][XOR]
/// ```
abstract final class LegacyFrameParser {
  static const List<int> _header = [0xAA, 0x55, 0xA9];

  /// Bit-name table for byte 7 of a system_status response payload.
  /// LSB-first ordering, per the SDK's `getBooleanArray` walk in
  /// `LockManager.getLockInfo`.
  static const List<String> byteBFlagNames = [
    'seal_up',
    'rope',
    'child_connect',
    'back_cover',
    'back_isopen',
    'open_lock_state',
    'cut_line',
    'motor_failure',
  ];

  /// Returns `true` if [bytes] is the spurious 1-byte `0xAA` preamble that the
  /// lock emits before each real response frame. Callers can drop these
  /// without further processing.
  static bool isPreamble(Uint8List bytes) =>
      bytes.length == 1 && bytes[0] == 0xAA;

  /// Returns `true` if [bytes] starts with the legacy `AA 55 A9` header,
  /// declares a length consistent with the buffer, and the XOR checksum
  /// validates. Useful for the connection layer to know whether to keep
  /// buffering more notifications or hand the buffer off to a parser.
  static bool isCompleteFrame(Uint8List bytes) {
    if (bytes.length < 9) return false;
    for (var i = 0; i < _header.length; i++) {
      if (bytes[i] != _header[i]) return false;
    }
    final declared = (bytes[4] << 8) | bytes[5];
    if (declared < 9 || declared > bytes.length) return false;
    var xor = 0;
    for (var k = 2; k < declared - 1; k++) {
      xor ^= bytes[k];
    }
    return (xor & 0xFF) == bytes[declared - 1];
  }

  /// Decodes [bytes] (an `AA 55 A9 …` frame) into a [LegacyStatus] when it is
  /// a `cmd=0x00` system_status response. Returns `null` for any other shape.
  static LegacyStatus? parseStatus(Uint8List bytes) {
    if (!isCompleteFrame(bytes)) return null;
    if (bytes[3] != 0x00) return null;
    // Skip [hdr 3][cmd 1][len 2][reserved 2] = 8 bytes; payload is 8 bytes;
    // the byte after that is the XOR.
    if (bytes.length < 17) return null;

    final payload = bytes.sublist(8, bytes.length - 1);
    if (payload.length < 8) return null;

    final deviceId = _bcdBytesToString(payload.sublist(0, 5));
    final byteA = payload[6];
    final byteB = payload[7];
    final flags = <String>[
      for (var i = 0; i < byteBFlagNames.length; i++)
        if ((byteB & (1 << i)) != 0) byteBFlagNames[i],
    ];

    return LegacyStatus(
      deviceId: deviceId,
      batteryPct: payload[5],
      byteARaw: byteA,
      byteBRaw: byteB,
      flags: flags,
    );
  }

  /// Returns the cmd byte of [bytes] when it is a complete legacy response,
  /// otherwise null. Useful to identify lock/unlock echoes (`cmd=0x01`)
  /// without fully decoding their payload.
  static int? cmdOf(Uint8List bytes) =>
      isCompleteFrame(bytes) ? bytes[3] : null;

  static String _bcdBytesToString(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb
        ..write(((b >> 4) & 0x0F).toString())
        ..write((b & 0x0F).toString());
    }
    return sb.toString();
  }
}
