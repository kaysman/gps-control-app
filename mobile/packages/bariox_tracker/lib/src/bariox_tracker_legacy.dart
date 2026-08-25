import 'dart:typed_data';

import 'package:bariox_tracker/src/models/legacy_status.dart';
import 'package:bariox_tracker/src/protocol/legacy_frame_builder.dart';
import 'package:bariox_tracker/src/protocol/legacy_frame_parser.dart';

/// High-level API for the legacy `AA-55-A9` protocol used by HB-series locks
/// shipping with the older firmware family (e.g. SN 2500000016).
///
/// This is the protocol verified working end-to-end on the bench. The newer
/// `AA-BB-0A` docx protocol is implemented separately in `BarioxTracker` and
/// has not been observed working on any unit we've tested.
class BarioxTrackerLegacy {
  /// Creates a [BarioxTrackerLegacy] with the given factory [password].
  const BarioxTrackerLegacy({String password = defaultPassword})
    : _password = password;

  /// Factory default password (`888888`).
  static const String defaultPassword = '888888';

  final String _password;

  // ── Frame builders ────────────────────────────────────────────────────────

  /// Builds the `system_status` frame (cmd=0x00). No device id needed.
  Uint8List statusFrame() => LegacyFrameBuilder.status();

  /// Builds the `unlock` frame (cmd=0x01 sub=0x04).
  ///
  /// Pass [deviceId] when you want the frame to reference a specific device's
  /// 5-byte legacy id; on the firmware we tested the lock does not validate
  /// the field for cmd 0x01, so omitting it (and using the SDK's hardcoded
  /// constant) works on every unit.
  Uint8List unlockFrame({Uint8List? deviceId}) => LegacyFrameBuilder.unlock(
    password: passwordBytes(_password),
    deviceId: deviceId,
  );

  /// Builds the `lock` frame (cmd=0x01 sub=0x05). See [unlockFrame] for the
  /// device-id semantics.
  Uint8List lockFrame({Uint8List? deviceId}) => LegacyFrameBuilder.lock(
    password: passwordBytes(_password),
    deviceId: deviceId,
  );

  // ── Parsers ───────────────────────────────────────────────────────────────

  /// Decodes a `cmd=0x00` notification into a [LegacyStatus], or null if the
  /// frame isn't one (or hasn't fully arrived yet).
  LegacyStatus? parseStatus(Uint8List bytes) =>
      LegacyFrameParser.parseStatus(bytes);

  /// True when [bytes] is the spurious 1-byte `0xAA` preamble notification
  /// the lock fires before every real response frame.
  bool isPreamble(Uint8List bytes) => LegacyFrameParser.isPreamble(bytes);

  /// True when [bytes] is a complete, checksum-valid legacy response frame.
  bool isCompleteFrame(Uint8List bytes) =>
      LegacyFrameParser.isCompleteFrame(bytes);

  // ── Static utilities ──────────────────────────────────────────────────────

  /// Encodes a 6-character ASCII [password] into the byte array used in
  /// protocol frames. Pads or truncates to exactly 6 bytes.
  static Uint8List passwordBytes(String password) {
    final padded = password.padRight(6, '0').substring(0, 6);
    return Uint8List.fromList(padded.codeUnits);
  }

  /// Encodes a 10-digit decimal serial number (e.g. `"2500000016"`) into the
  /// 5-byte legacy device id used in `cmd=0x01` frames.
  ///
  /// Pads with leading zeros if shorter; throws if longer than 10 digits.
  static Uint8List deviceIdBytes(String sn) {
    if (sn.length > 10) {
      throw ArgumentError.value(sn, 'sn', 'must be at most 10 decimal digits');
    }
    final padded = sn.padLeft(10, '0');
    final result = Uint8List(5);
    for (var i = 0; i < 5; i++) {
      final hi = int.parse(padded[i * 2]);
      final lo = int.parse(padded[i * 2 + 1]);
      result[i] = (hi << 4) | lo;
    }
    return result;
  }
}
