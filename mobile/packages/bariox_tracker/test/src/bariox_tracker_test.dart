// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarioxTracker utilities', () {
    test('deviceIdBytes encodes 12-digit string', () {
      final bytes = BarioxTracker.deviceIdBytes('000123456789');
      expect(bytes, equals([0x00, 0x01, 0x23, 0x45, 0x67, 0x89]));
    });

    test('deviceIdBytes pads short IDs with leading zeros', () {
      final bytes = BarioxTracker.deviceIdBytes('123456789');
      expect(bytes, equals([0x00, 0x01, 0x23, 0x45, 0x67, 0x89]));
    });

    test('deviceIdString decodes 6-byte BCD to string', () {
      final bytes = Uint8List.fromList([0x00, 0x01, 0x23, 0x45, 0x67, 0x89]);
      expect(BarioxTracker.deviceIdString(bytes), '000123456789');
    });

    test('deviceIdBytes and deviceIdString are inverse operations', () {
      const id = '000123456789';
      expect(BarioxTracker.deviceIdString(BarioxTracker.deviceIdBytes(id)), id);
    });

    test('passwordBytes encodes ASCII correctly', () {
      final bytes = BarioxTracker.passwordBytes('000000');
      expect(bytes, equals([0x30, 0x30, 0x30, 0x30, 0x30, 0x30]));
    });

    test('passwordBytes pads short passwords', () {
      final bytes = BarioxTracker.passwordBytes('1234');
      expect(bytes.length, 6);
    });
  });

  group('TrackerTime', () {
    test('fromDateTime round-trips through toBytes', () {
      final dt = DateTime(2025, 12, 10, 8, 17, 59);
      final time = TrackerTime.fromDateTime(dt);
      expect(time.year, 25);
      expect(time.month, 12);
      expect(time.day, 10);
      expect(time.hour, 8);
      expect(time.minute, 17);
      expect(time.second, 59);
    });

    test('toBytes encodes BCD correctly', () {
      final time = TrackerTime(
        year: 25,
        month: 12,
        day: 10,
        hour: 8,
        minute: 17,
        second: 59,
      );
      // 25→0x25, 12→0x12, 10→0x10, 08→0x08, 17→0x17, 59→0x59
      expect(time.toBytes(),
          equals([0x25, 0x12, 0x10, 0x08, 0x17, 0x59]));
    });

    test('fromBytes decodes BCD correctly', () {
      final bytes =
          Uint8List.fromList([0x25, 0x12, 0x10, 0x08, 0x17, 0x59]);
      final time = TrackerTime.fromBytes(bytes);
      expect(time.year, 25);
      expect(time.month, 12);
      expect(time.second, 59);
    });

    test('toDateTime uses 2000 as century base', () {
      final time = TrackerTime(
        year: 25,
        month: 1,
        day: 1,
        hour: 0,
        minute: 0,
        second: 0,
      );
      expect(time.toDateTime().year, 2025);
    });
  });

  group('FrameBuilder', () {
    test('build produces correct header and trailer', () {
      final frame = FrameBuilder.build(0x01, Uint8List(0));
      expect(frame[0], 0xAA);
      expect(frame[1], 0xBB);
      expect(frame[2], 0x01);
      expect(frame[frame.length - 2], 0x0D);
      expect(frame[frame.length - 1], 0x0A);
    });

    test('build with empty data has correct length (8 bytes)', () {
      final frame = FrameBuilder.build(0x01, Uint8List(0));
      expect(frame.length, 8);
    });

    test('build encodes LEN field as big-endian data length', () {
      final data = Uint8List(13);
      final frame = FrameBuilder.build(0x01, data);
      expect(frame[3], 0x00); // high byte
      expect(frame[4], 0x0D); // low byte = 13
    });

    test('build checksum is XOR of all bytes before checksum', () {
      final data = Uint8List.fromList([0x01, 0x02]);
      final frame = FrameBuilder.build(0x05, data);
      var expected = 0;
      for (var i = 0; i < frame.length - 3; i++) {
        expected ^= frame[i];
      }
      expect(frame[frame.length - 3], expected);
    });

    test('buildLock sets control byte to 0x00', () {
      final deviceId = BarioxTracker.deviceIdBytes('000123456789');
      final password = BarioxTracker.passwordBytes('000000');
      final frame = FrameBuilder.buildLock(
          deviceId: deviceId, password: password);
      // Data starts at byte 5; control byte is at offset 12 within data
      expect(frame[5 + 12], 0x00);
    });

    test('buildUnlock sets control byte to 0x01', () {
      final deviceId = BarioxTracker.deviceIdBytes('000123456789');
      final password = BarioxTracker.passwordBytes('000000');
      final frame = FrameBuilder.buildUnlock(
          deviceId: deviceId, password: password);
      expect(frame[5 + 12], 0x01);
    });

    test('buildLock and buildUnlock produce 21-byte frames', () {
      final deviceId = BarioxTracker.deviceIdBytes('000123456789');
      final password = BarioxTracker.passwordBytes('000000');
      // 8 + 13 (data length for CMD 0x01) = 21
      expect(
          FrameBuilder.buildLock(deviceId: deviceId, password: password)
              .length,
          21);
      expect(
          FrameBuilder.buildUnlock(deviceId: deviceId, password: password)
              .length,
          21);
    });
  });

  group('FrameParser.verifyChecksum', () {
    test('returns true for a correctly built frame', () {
      final frame = FrameBuilder.build(0x02, Uint8List.fromList([0xAB, 0xCD]));
      expect(FrameParser.verifyChecksum(frame), isTrue);
    });

    test('returns false when checksum byte is corrupted', () {
      final frame = FrameBuilder.build(0x02, Uint8List.fromList([0xAB, 0xCD]));
      final corrupted = Uint8List.fromList(frame)
        ..[frame.length - 3] ^= 0xFF;
      expect(FrameParser.verifyChecksum(corrupted), isFalse);
    });
  });

  group('FrameParser.parseBroadcast', () {
    Uint8List _makeBroadcast({
      int deviceTypeByte = 0x01,
      List<int> deviceId = const [0x00, 0x01, 0x23, 0x45, 0x67, 0x89],
      int hwVersion = 0x0A,
      int swHigh = 0x27,
      int swLow = 0x11,
      int battery = 80,
      int tempByte = 0x28, // 0x28 - 40 = 0°C
      int chargingByte = 0x00,
      int sealByte = 0x00,
    }) =>
        Uint8List.fromList([
          0x48, 0x4C,       // header
          0x38, 0xAF,       // manufacturer
          deviceTypeByte,
          ...deviceId,
          hwVersion,
          swHigh, swLow,
          battery,
          tempByte,
          chargingByte,
          sealByte,
        ]);

    test('returns null for wrong header', () {
      final bytes = Uint8List.fromList(List.filled(18, 0x00));
      expect(FrameParser.parseBroadcast(bytes), isNull);
    });

    test('returns null for too-short payload', () {
      expect(FrameParser.parseBroadcast(Uint8List(10)), isNull);
    });

    test('parses device type A1i', () {
      final packet = FrameParser.parseBroadcast(_makeBroadcast())!;
      expect(packet.deviceType, TrackerDeviceType.subLockA1i);
    });

    test('parses device ID', () {
      final packet = FrameParser.parseBroadcast(_makeBroadcast())!;
      expect(packet.deviceId, '000123456789');
    });

    test('parses hardware version 0x0A as "1.0"', () {
      final packet = FrameParser.parseBroadcast(_makeBroadcast())!;
      expect(packet.hardwareVersion, '1.0');
    });

    test('parses software version', () {
      final packet = FrameParser.parseBroadcast(_makeBroadcast())!;
      expect(packet.softwareVersion, 0x2711); // 10001
    });

    test('parses battery level', () {
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(battery: 75))!;
      expect(packet.batteryLevel, 75);
    });

    test('temperature offset: 0x28 → 0°C', () {
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(tempByte: 0x28))!;
      expect(packet.temperature, 0);
    });

    test('temperature 0xFF → null', () {
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(tempByte: 0xFF))!;
      expect(packet.temperature, isNull);
    });

    test('parses charging bits', () {
      // bit0=charging, bit1=full, bit2=fault, bit3=battery fault
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(chargingByte: 0x03))!;
      expect(packet.isCharging, isTrue);
      expect(packet.isFullyCharged, isTrue);
      expect(packet.hasChargingFault, isFalse);
    });

    test('parses seal bits: isUnlocked', () {
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(sealByte: 0x01))!;
      expect(packet.isUnlocked, isTrue);
      expect(packet.hasChainIssue, isFalse);
    });

    test('parses seal bits: isRearCoverOpen and isLockStuck', () {
      final packet =
          FrameParser.parseBroadcast(_makeBroadcast(sealByte: 0x30))!;
      expect(packet.isRearCoverOpen, isTrue);
      expect(packet.isLockStuck, isTrue);
    });
  });

  group('FrameParser.parseResponse', () {
    /// Builds a synthetic response frame from raw field values.
    Uint8List _makeResponse({
      required int cmd,
      required int responseCode,
      required List<int> data,
    }) {
      // data field = responseCode(1) + data(N)
      final payload = [responseCode, ...data];
      final dataLen = payload.length;
      final lenHigh = (dataLen >> 8) & 0xFF;
      final lenLow = dataLen & 0xFF;

      final frameData = [
        0xAA, 0xBB, cmd, lenHigh, lenLow,
        ...payload,
      ];
      var checksum = 0;
      for (final b in frameData) {
        checksum ^= b;
      }
      return Uint8List.fromList([...frameData, checksum, 0x0D, 0x0A]);
    }

    final deviceIdBytes = [0x00, 0x01, 0x23, 0x45, 0x67, 0x89];

    test('returns null for wrong header', () {
      expect(
          FrameParser.parseResponse(Uint8List.fromList([0x00, 0x00, 0x01])),
          isNull);
    });

    test('returns null for bad trailer', () {
      final frame = _makeResponse(
          cmd: 0x01, responseCode: 0x00, data: deviceIdBytes);
      final bad = Uint8List.fromList(frame)
        ..[frame.length - 1] = 0xFF;
      expect(FrameParser.parseResponse(bad), isNull);
    });

    test('returns null on checksum mismatch', () {
      final frame = _makeResponse(
          cmd: 0x01, responseCode: 0x00, data: deviceIdBytes);
      final bad = Uint8List.fromList(frame)
        ..[frame.length - 3] ^= 0xFF;
      expect(FrameParser.parseResponse(bad), isNull);
    });

    test('parses successful lock response', () {
      final frame = _makeResponse(
          cmd: 0x01, responseCode: 0x00, data: deviceIdBytes);
      final response = FrameParser.parseResponse(frame)!;
      expect(response.command, TrackerCommand.switchLock);
      expect(response.responseCode, TrackerResponseCode.success);
      expect(response.isSuccess, isTrue);
    });

    test('parses wrong-password response', () {
      final frame = _makeResponse(
          cmd: 0x01, responseCode: 0x06, data: deviceIdBytes);
      final response = FrameParser.parseResponse(frame)!;
      expect(response.responseCode, TrackerResponseCode.wrongPassword);
      expect(response.isSuccess, isFalse);
    });

    test('deviceId accessor decodes first 6 bytes of data', () {
      final frame = _makeResponse(
          cmd: 0x01, responseCode: 0x00, data: deviceIdBytes);
      final response = FrameParser.parseResponse(frame)!;
      expect(response.deviceId, '000123456789');
    });

    test('time accessor decodes CMD 0x0C response', () {
      final timeBytes = [0x25, 0x12, 0x10, 0x08, 0x17, 0x59];
      final frame = _makeResponse(
          cmd: 0x0C, responseCode: 0x00, data: [...deviceIdBytes, ...timeBytes]);
      final response = FrameParser.parseResponse(frame)!;
      final time = response.time!;
      expect(time.year, 25);
      expect(time.month, 12);
      expect(time.second, 59);
    });
  });

  group('BarioxTracker integration', () {
    late BarioxTracker tracker;
    late Uint8List deviceId;

    setUp(() {
      tracker = BarioxTracker();
      deviceId = BarioxTracker.deviceIdBytes('000123456789');
    });

    test('lockFrame produces a valid frame with correct CMD byte', () {
      final frame = tracker.lockFrame(deviceId);
      expect(frame[2], TrackerCommand.switchLock.value);
      expect(FrameParser.verifyChecksum(frame), isTrue);
    });

    test('unlockFrame produces a valid frame with correct CMD byte', () {
      final frame = tracker.unlockFrame(deviceId);
      expect(frame[2], TrackerCommand.switchLock.value);
      expect(FrameParser.verifyChecksum(frame), isTrue);
    });

    test('all query frame builders produce valid checksums', () {
      for (final frame in [
        tracker.queryLockStatusFrame(deviceId),
        tracker.checkDeviceInfoFrame(deviceId),
        tracker.checkSealStatusFrame(deviceId),
        tracker.checkChargingStatusFrame(deviceId),
        tracker.queryTimeFrame(deviceId),
        tracker.readSoftwareVersionFrame(deviceId),
      ]) {
        expect(FrameParser.verifyChecksum(frame), isTrue,
            reason: 'checksum failed for CMD 0x${frame[2].toRadixString(16)}');
      }
    });

    test('setTimeFrame encodes current time and passes checksum', () {
      final time = TrackerTime.fromDateTime(DateTime(2025, 12, 10, 8, 17, 59));
      final frame = tracker.setTimeFrame(deviceId, time);
      expect(frame[2], TrackerCommand.setTime.value);
      expect(FrameParser.verifyChecksum(frame), isTrue);
    });

    test('custom password is used in frames', () {
      final customTracker = BarioxTracker(password: '123456');
      final frame = customTracker.lockFrame(deviceId);
      // password starts at byte offset 5+6=11 in data field
      // '1'=0x31, '2'=0x32, ...
      expect(frame[5 + 6], 0x31); // '1'
      expect(frame[5 + 7], 0x32); // '2'
    });
  });

  group('TrackerResponseCode', () {
    test('fromValue returns correct enum member', () {
      expect(TrackerResponseCode.fromValue(0x00), TrackerResponseCode.success);
      expect(TrackerResponseCode.fromValue(0x06),
          TrackerResponseCode.wrongPassword);
    });

    test('fromValue falls back to operationFailed for unknown code', () {
      expect(TrackerResponseCode.fromValue(0xFF),
          TrackerResponseCode.operationFailed);
    });

    test('isSuccess is true only for success', () {
      expect(TrackerResponseCode.success.isSuccess, isTrue);
      expect(TrackerResponseCode.wrongPassword.isSuccess, isFalse);
    });
  });

  group('TrackerCommand', () {
    test('fromValue returns correct command', () {
      expect(
          TrackerCommand.fromValue(0x01), TrackerCommand.switchLock);
      expect(
          TrackerCommand.fromValue(0x14), TrackerCommand.readSoftwareVersion);
    });

    test('fromValue returns null for unknown byte', () {
      expect(TrackerCommand.fromValue(0xFF), isNull);
    });
  });
}
