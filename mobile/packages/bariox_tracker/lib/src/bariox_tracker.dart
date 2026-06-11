import 'dart:typed_data';

import 'package:bariox_tracker/src/models/broadcast_packet.dart';
import 'package:bariox_tracker/src/models/tracker_command.dart';
import 'package:bariox_tracker/src/models/tracker_response.dart';
import 'package:bariox_tracker/src/models/tracker_time.dart';
import 'package:bariox_tracker/src/protocol/frame_builder.dart';
import 'package:bariox_tracker/src/protocol/frame_parser.dart';

/// High-level API for the Bariox e-lock BLE protocol.
///
/// [BarioxTracker] builds outgoing request frames and parses incoming
/// broadcast/response payloads.  It does **not** manage the BLE connection
/// itself — raw bytes are passed in and out so that the BLE transport layer
/// remains independent.
///
/// ```dart
/// final tracker = BarioxTracker(password: '123456');
/// final deviceId = BarioxTracker.deviceIdBytes('000123456789');
///
/// // Build a frame to send via BLE GATT write
/// final lockFrame = tracker.lockFrame(deviceId);
///
/// // Parse the device's response notification
/// final response = tracker.parseResponse(notificationBytes);
/// if (response?.isSuccess ?? false) { ... }
/// ```
class BarioxTracker {
  /// Creates a [BarioxTracker] with the given [password].
  ///
  /// [password] must be exactly 6 ASCII characters; defaults to "888888".
  const BarioxTracker({String password = defaultPassword})
      : _password = password;

  /// Factory default password.
  static const String defaultPassword = '888888';

  final String _password;

  // ── Frame builders ────────────────────────────────────────────────────────

  /// Returns a **lock** request frame for [deviceId].
  Uint8List lockFrame(Uint8List deviceId) => FrameBuilder.buildLock(
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns an **unlock** request frame for [deviceId].
  Uint8List unlockFrame(Uint8List deviceId) => FrameBuilder.buildUnlock(
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **query lock status** frame for [deviceId] (CMD 0x02).
  Uint8List queryLockStatusFrame(Uint8List deviceId) =>
      FrameBuilder.buildSimpleQuery(
        command: TrackerCommand.queryLockStatus,
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **check device info** frame for [deviceId] (CMD 0x04).
  Uint8List checkDeviceInfoFrame(Uint8List deviceId) =>
      FrameBuilder.buildSimpleQuery(
        command: TrackerCommand.checkDeviceInfo,
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **check e-seal status** frame for [deviceId] (CMD 0x0E).
  Uint8List checkSealStatusFrame(Uint8List deviceId) =>
      FrameBuilder.buildSimpleQuery(
        command: TrackerCommand.checkSealStatus,
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **check charging status** frame for [deviceId] (CMD 0x0F).
  Uint8List checkChargingStatusFrame(Uint8List deviceId) =>
      FrameBuilder.buildSimpleQuery(
        command: TrackerCommand.checkChargingStatus,
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **set time** frame for [deviceId] using [time] (CMD 0x0B).
  Uint8List setTimeFrame(Uint8List deviceId, TrackerTime time) =>
      FrameBuilder.buildSetTime(
        deviceId: deviceId,
        password: passwordBytes(_password),
        time: time,
      );

  /// Returns a **query time** frame for [deviceId] (CMD 0x0C).
  Uint8List queryTimeFrame(Uint8List deviceId) =>
      FrameBuilder.buildQueryTime(
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **read software version** frame for [deviceId] (CMD 0x14).
  Uint8List readSoftwareVersionFrame(Uint8List deviceId) =>
      FrameBuilder.buildReadSoftwareVersion(
        deviceId: deviceId,
        password: passwordBytes(_password),
      );

  /// Returns a **change password** frame for [deviceId] (CMD 0x05).
  Uint8List changePasswordFrame(
    Uint8List deviceId,
    String newPassword,
  ) =>
      FrameBuilder.buildChangePassword(
        deviceId: deviceId,
        password: passwordBytes(_password),
        newPassword: passwordBytes(newPassword),
      );

  // ── Parsers ───────────────────────────────────────────────────────────────

  /// Parses a 18-byte BLE advertisement manufacturer payload into a
  /// [BroadcastPacket], or returns null if [bytes] is not a valid Bariox
  /// broadcast.
  BroadcastPacket? parseBroadcast(Uint8List bytes) =>
      FrameParser.parseBroadcast(bytes);

  /// Parses a GATT notification payload into a [TrackerResponse], or returns
  /// null if [bytes] is not a valid Bariox response frame.
  TrackerResponse? parseResponse(Uint8List bytes) =>
      FrameParser.parseResponse(bytes);

  // ── Static utilities ──────────────────────────────────────────────────────

  /// Encodes a decimal device ID string into the 6-byte BCD representation
  /// used in protocol frames.
  ///
  /// [id] is padded to 12 digits with leading zeros if shorter.
  ///
  /// ```dart
  /// BarioxTracker.deviceIdBytes('123456789') // → [0x00,0x01,0x23,0x45,0x67,0x89]
  /// ```
  static Uint8List deviceIdBytes(String id) {
    final padded = id.padLeft(12, '0');
    assert(padded.length == 12, 'device ID must be at most 12 digits');
    final result = Uint8List(6);
    for (var i = 0; i < 6; i++) {
      final hi = int.parse(padded[i * 2]);
      final lo = int.parse(padded[i * 2 + 1]);
      result[i] = (hi << 4) | lo;
    }
    return result;
  }

  /// Decodes a 6-byte BCD device ID into its 12-digit decimal string.
  static String deviceIdString(Uint8List bytes) {
    assert(bytes.length == 6, 'deviceId must be 6 bytes');
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(((b >> 4) & 0x0F).toString());
      sb.write((b & 0x0F).toString());
    }
    return sb.toString();
  }

  /// Encodes a 6-character ASCII [password] into the byte array used in
  /// protocol frames (e.g. "000000" → [0x30,0x30,0x30,0x30,0x30,0x30]).
  static Uint8List passwordBytes(String password) {
    final padded = password.padRight(6, '0').substring(0, 6);
    return Uint8List.fromList(padded.codeUnits);
  }
}
