import 'dart:typed_data';

import 'package:bariox_tracker/src/models/broadcast_packet.dart';
import 'package:bariox_tracker/src/models/tracker_command.dart';
import 'package:bariox_tracker/src/models/tracker_device_type.dart';
import 'package:bariox_tracker/src/models/tracker_response.dart';
import 'package:bariox_tracker/src/models/tracker_response_code.dart';
import 'package:ble_framed_protocol/ble_framed_protocol.dart';

/// Parses raw byte arrays received over BLE into Bariox protocol models.
class FrameParser {
  FrameParser._();

  // ── Broadcast constants ─────────────────────────────────────────────────
  static const int _broadcastLength = 18;
  static const int _broadcastHdr1 = 0x48;
  static const int _broadcastHdr2 = 0x4C;
  static const int _manufacturerHigh = 0x38;
  static const int _manufacturerLow = 0xAF;
  static const int _invalidTemperature = 0xFF;

  /// Parses a Bariox BLE advertisement manufacturer-specific payload into a
  /// [BroadcastPacket].
  ///
  /// Returns null when [bytes] is too short, has wrong headers, or has an
  /// unexpected manufacturer code.
  static BroadcastPacket? parseBroadcast(Uint8List bytes) {
    if (bytes.length < _broadcastLength) return null;
    if (bytes[0] != _broadcastHdr1 || bytes[1] != _broadcastHdr2) return null;
    if (bytes[2] != _manufacturerHigh || bytes[3] != _manufacturerLow) {
      return null;
    }

    final deviceId = _bcdBytesToString(bytes.sublist(5, 11));

    // Hardware version: decimal value encodes as V(major).(minor)
    // e.g. 0x0A = 10 decimal → V1.0
    final hwDecimal = bytes[11];
    final hardwareVersion = '${hwDecimal ~/ 10}.${hwDecimal % 10}';

    final softwareVersion = (bytes[12] << 8) | bytes[13];

    final tempByte = bytes[15];
    final temperature =
        tempByte == _invalidTemperature ? null : tempByte - 40;

    final chargingByte = bytes[16];
    final sealByte = bytes[17];

    return BroadcastPacket(
      deviceType: TrackerDeviceType.fromValue(bytes[4]),
      deviceId: deviceId,
      hardwareVersion: hardwareVersion,
      softwareVersion: softwareVersion,
      batteryLevel: bytes[14],
      temperature: temperature,
      isCharging: (chargingByte & 0x01) != 0,
      isFullyCharged: (chargingByte & 0x02) != 0,
      hasChargingFault: (chargingByte & 0x04) != 0,
      hasBatteryFault: (chargingByte & 0x08) != 0,
      isUnlocked: (sealByte & 0x01) != 0,
      hasChainIssue: (sealByte & 0x02) != 0,
      isCoverOpen: (sealByte & 0x04) != 0,
      hasRfModuleFault: (sealByte & 0x08) != 0,
      isRearCoverOpen: (sealByte & 0x10) != 0,
      isLockStuck: (sealByte & 0x20) != 0,
    );
  }

  /// Parses a response frame received from the device after a command.
  ///
  /// Frame layout (decoded by [FramedProtocol.standard]):
  /// ```
  /// [0xAA][0xBB][CMD][LEN_H][LEN_L][RESP_CODE][DATA...][XOR_CHECKSUM][0x0D][0x0A]
  /// ```
  /// LEN includes both the response-code byte and the data bytes. The first
  /// byte of [Frame.payload] is the response code; the rest is data.
  ///
  /// Returns null when the frame is malformed (wrong headers/trailer, bad
  /// length, or checksum mismatch) or carries no response code.
  static TrackerResponse? parseResponse(Uint8List bytes) {
    final frame = FramedProtocol.standard.decode(bytes);
    if (frame == null) return null;
    if (frame.payload.isEmpty) return null;

    return TrackerResponse(
      command: TrackerCommand.fromValue(frame.cmdId),
      responseCode: TrackerResponseCode.fromValue(frame.payload[0]),
      data: Uint8List.fromList(frame.payload.sublist(1)),
    );
  }

  /// Returns true when [frame] has a valid XOR checksum.
  ///
  /// Useful for validating outgoing frames before transmission.
  static bool verifyChecksum(Uint8List frame) =>
      FramedProtocol.standard.verifyChecksum(frame);

  // ── Internal helpers ─────────────────────────────────────────────────────

  static String _bcdBytesToString(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(((b >> 4) & 0x0F).toString());
      sb.write((b & 0x0F).toString());
    }
    return sb.toString();
  }
}
