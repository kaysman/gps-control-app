import 'dart:typed_data';

import 'package:bariox_tracker/src/models/tracker_command.dart';
import 'package:bariox_tracker/src/models/tracker_time.dart';
import 'package:ble_framed_protocol/ble_framed_protocol.dart';

/// Builds Bariox BLE request frames.
///
/// Frame layout (handled by [FramedProtocol.standard]):
/// ```
/// [0xAA][0xBB][CMD][LEN_H][LEN_L][DATA...][XOR_CHECKSUM][0x0D][0x0A]
/// ```
class FrameBuilder {
  FrameBuilder._();

  /// Assembles a raw request frame for [cmdId] carrying [data].
  static Uint8List build(int cmdId, Uint8List data) =>
      FramedProtocol.standard.encode(Frame(cmdId: cmdId, payload: data));

  /// Builds a **lock** command frame (CMD 0x01, control byte 0x00).
  static Uint8List buildLock({
    required Uint8List deviceId,
    required Uint8List password,
  }) =>
      _buildSwitchLock(deviceId: deviceId, password: password, unlock: false);

  /// Builds an **unlock** command frame (CMD 0x01, control byte 0x01).
  static Uint8List buildUnlock({
    required Uint8List deviceId,
    required Uint8List password,
  }) =>
      _buildSwitchLock(deviceId: deviceId, password: password, unlock: true);

  static Uint8List _buildSwitchLock({
    required Uint8List deviceId,
    required Uint8List password,
    required bool unlock,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    // Data: DeviceID(6) + Password(6) + ControlCmd(1) = 13 bytes
    final data = Uint8List(13)
      ..setRange(0, 6, deviceId)
      ..setRange(6, 12, password)
      ..[12] = unlock ? 0x01 : 0x00;
    return build(TrackerCommand.switchLock.value, data);
  }

  /// Builds a **change password** command frame (CMD 0x05).
  ///
  /// Data: DeviceID(6) + OldPassword(6) + NewPassword(6) = 18 bytes.
  static Uint8List buildChangePassword({
    required Uint8List deviceId,
    required Uint8List password,
    required Uint8List newPassword,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    assert(newPassword.length == 6, 'newPassword must be 6 bytes');
    final data = Uint8List(18)
      ..setRange(0, 6, deviceId)
      ..setRange(6, 12, password)
      ..setRange(12, 18, newPassword);
    return build(TrackerCommand.changePassword.value, data);
  }

  /// Builds a **set time** command frame (CMD 0x0B).
  ///
  /// Data: DeviceID(6) + Password(6) + Time(6 bytes BCD) = 18 bytes.
  static Uint8List buildSetTime({
    required Uint8List deviceId,
    required Uint8List password,
    required TrackerTime time,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    final data = Uint8List(18)
      ..setRange(0, 6, deviceId)
      ..setRange(6, 12, password)
      ..setRange(12, 18, time.toBytes());
    return build(TrackerCommand.setTime.value, data);
  }

  /// Builds a **query time** command frame (CMD 0x0C).
  ///
  /// Data: Password(6) + DeviceID(6) = 12 bytes.
  static Uint8List buildQueryTime({
    required Uint8List deviceId,
    required Uint8List password,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    final data = Uint8List(12)
      ..setRange(0, 6, password)
      ..setRange(6, 12, deviceId);
    return build(TrackerCommand.queryTime.value, data);
  }

  /// Builds a **read software version** command frame (CMD 0x14).
  ///
  /// Data: Password(6) + DeviceID(6) = 12 bytes.
  static Uint8List buildReadSoftwareVersion({
    required Uint8List deviceId,
    required Uint8List password,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    final data = Uint8List(12)
      ..setRange(0, 6, password)
      ..setRange(6, 12, deviceId);
    return build(TrackerCommand.readSoftwareVersion.value, data);
  }

  /// Builds a generic **query** frame for commands whose only payload is
  /// DeviceID(6) + Password(6) (e.g. 0x02, 0x04, 0x0E, 0x0F).
  static Uint8List buildSimpleQuery({
    required TrackerCommand command,
    required Uint8List deviceId,
    required Uint8List password,
  }) {
    assert(deviceId.length == 6, 'deviceId must be 6 bytes');
    assert(password.length == 6, 'password must be 6 bytes');
    final data = Uint8List(12)
      ..setRange(0, 6, deviceId)
      ..setRange(6, 12, password);
    return build(command.value, data);
  }
}
