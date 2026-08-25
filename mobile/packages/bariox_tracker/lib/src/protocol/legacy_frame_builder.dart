import 'dart:typed_data';

/// Builds Bariox e-lock request frames for the legacy `AA-55-A9` protocol.
///
/// Frame layout:
/// ```text
/// [0xAA][0x55][0xA9][CMD][LEN_H][LEN_L][0x01][0x01][PAYLOAD ...][XOR]
/// ```
///
/// - **Total length** = full frame size (header through checksum), big-endian.
/// - **Reserved** = `01 01` (always — SDK convention).
/// - **XOR** = bytes 2..n-2 inclusive (i.e. starting at the third header byte
///   `0xA9` through the last payload byte before the checksum).
///
/// Reverse-engineered from `lockinfodemo/lock-sdk.jar` and verified end-to-end
/// against the HB-series lock at the bench.
abstract final class LegacyFrameBuilder {
  /// `AA 55 A9` — fixed three-byte header.
  static const List<int> headerBytes = [0xAA, 0x55, 0xA9];

  /// `01 01` — reserved bytes the SDK always sends.
  static const List<int> reservedBytes = [0x01, 0x01];

  /// SDK's hardcoded test device-id used in the lock-control frame (5 bytes).
  /// The lock does **not** validate this value for cmd 0x01, so the same
  /// constant works on every unit running the legacy firmware.
  static const List<int> sdkHardcodedDeviceId = [0x91, 0x00, 0x02, 0x00, 0x86];

  // ── Generic builder ───────────────────────────────────────────────────────

  /// Encodes a frame with the given [cmd] byte and optional [extra] payload.
  /// `extra` is everything after the `01 01` reserved field, before the XOR.
  static Uint8List build(int cmd, [Uint8List? extra]) {
    assert(cmd >= 0 && cmd <= 0xFF, 'cmd must fit in one byte');
    final extraBytes = extra ?? Uint8List(0);
    final totalLen =
        headerBytes.length +
        1 +
        2 +
        reservedBytes.length +
        extraBytes.length +
        1;
    assert(totalLen <= 0xFFFF, 'frame too large for the 2-byte length field');

    final out = Uint8List(totalLen);
    var i = 0;
    for (final b in headerBytes) {
      out[i++] = b;
    }
    out[i++] = cmd;
    out[i++] = (totalLen >> 8) & 0xFF;
    out[i++] = totalLen & 0xFF;
    for (final b in reservedBytes) {
      out[i++] = b;
    }
    for (var j = 0; j < extraBytes.length; j++) {
      out[i++] = extraBytes[j];
    }
    var xor = 0;
    for (var k = 2; k < i; k++) {
      xor ^= out[k];
    }
    out[i] = xor & 0xFF;
    return out;
  }

  // ── Common commands ───────────────────────────────────────────────────────

  /// `cmd=0x00` — system status / battery query. No payload.
  ///
  /// On-air bytes: `AA 55 A9 00 00 09 01 01 A0`.
  static Uint8List status() => build(0x00);

  /// `cmd=0x01 sub=0x04` — unlock command.
  ///
  /// Payload is `password(6) || deviceId(5) || 0x04`. Pass [deviceId] = null
  /// to use the SDK's hardcoded test device id (lock doesn't validate it on
  /// this firmware).
  static Uint8List unlock({
    required Uint8List password,
    Uint8List? deviceId,
  }) {
    return _switchControl(
      password: password,
      deviceId: deviceId,
      sub: 0x04,
    );
  }

  /// `cmd=0x01 sub=0x05` — lock command.
  ///
  /// Payload shape identical to [unlock] except the trailing sub-command byte.
  static Uint8List lock({
    required Uint8List password,
    Uint8List? deviceId,
  }) {
    return _switchControl(
      password: password,
      deviceId: deviceId,
      sub: 0x05,
    );
  }

  static Uint8List _switchControl({
    required Uint8List password,
    required int sub,
    Uint8List? deviceId,
  }) {
    assert(password.length == 6, 'password must be 6 bytes');
    final id = deviceId ?? Uint8List.fromList(sdkHardcodedDeviceId);
    assert(id.length == 5, 'legacy deviceId must be 5 bytes');
    final extra = Uint8List(password.length + id.length + 1)
      ..setRange(0, 6, password)
      ..setRange(6, 11, id)
      ..[11] = sub;
    return build(0x01, extra);
  }
}
