/// Decoded payload of a legacy `AA-55-A9` system_status (cmd=0x00) response.
///
/// Frame: `AA 55 A9 | 00 | 00 11 | 01 01 | <8B payload> | XOR`
///
/// Payload layout (after the 8-byte frame header and before the XOR byte):
///
/// | offset | size | meaning                                                |
/// |--------|------|--------------------------------------------------------|
/// | 0..4   | 5    | device id, BCD-encoded                                 |
/// | 5      | 1    | battery percentage, 0..100                             |
/// | 6      | 1    | flag byte A — `lock_state`, `low_electricity`, etc.    |
/// | 7      | 1    | flag byte B — see [byteBRaw]                           |
class LegacyStatus {
  /// Creates a [LegacyStatus].
  const LegacyStatus({
    required this.deviceId,
    required this.batteryPct,
    required this.byteARaw,
    required this.byteBRaw,
    required this.flags,
  });

  /// 10-digit decimal device id, e.g. `"2500000016"`.
  final String deviceId;

  /// Battery percentage, 0..100. The lock's firmware is known to refuse motor
  /// commands below some unspecified threshold (~15% in our tests).
  final int batteryPct;

  /// Raw value of byte 6 — covers `lock_state` and `low_electricity` bits per
  /// the SDK. Exact bit layout is not fully reverse-engineered yet; expose the
  /// raw byte for callers who need it.
  final int byteARaw;

  /// Raw value of byte 7 — bitfield over `seal_up`, `rope`, `child_connect`,
  /// `back_cover`, `back_isopen`, `open_lock_state`, `cut_line`,
  /// `motor_failure` (LSB-first per the SDK's `getBooleanArray` usage).
  final int byteBRaw;

  /// Names of the bits set in [byteBRaw], LSB-first per the SDK ordering.
  /// Bit-to-name mapping is best-guess until cross-checked on real hardware.
  final List<String> flags;

  /// Bit 3 of [byteBRaw] = `back_cover` (`1` = closed per docs).
  bool get isCoverClosed => (byteBRaw & 0x08) != 0;

  /// Bit 4 of [byteBRaw] = `back_isopen` (`1` = open per docs).
  bool get isCoverOpen => (byteBRaw & 0x10) != 0;

  /// Bit 5 of [byteBRaw] = `open_lock_state` (`1` = unlocked).
  bool get isUnlocked => (byteBRaw & 0x20) != 0;

  @override
  String toString() =>
      'LegacyStatus(deviceId: $deviceId, batteryPct: $batteryPct, '
      'byteARaw: 0x${_hex(byteARaw)}, '
      'byteBRaw: 0x${_hex(byteBRaw)}, '
      'flags: $flags)';

  static String _hex(int b) =>
      b.toRadixString(16).padLeft(2, '0').toUpperCase();
}
