# bariox_tracker

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Pure-Dart protocol library for communicating with Bariox e-lock GPS trackers over BLE. Handles frame serialization, checksum calculation, broadcast packet parsing, and response decoding. Does **not** manage the BLE connection itself — raw bytes go in and out so any BLE plugin can be used as the transport.

---

## Overview

The Bariox device operates in two modes:

| Mode | Direction | Description |
|---|---|---|
| **Broadcast** | Device → App | 18-byte BLE advertisement emitted periodically with battery, temperature, and seal/lock status |
| **Point-to-point** | App ↔ Device | GATT write + notification; app sends a request frame, device replies with a response frame |

### Request frame layout

```
[0xAA][0xBB][CMD][LEN_H][LEN_L][DATA...][XOR_CHECKSUM][0x0D][0x0A]
```

### Response frame layout

```
[0xAA][0xBB][CMD][LEN_H][LEN_L][RESP_CODE][DATA...][XOR_CHECKSUM][0x0D][0x0A]
```

`LEN` is big-endian and counts only the data bytes (response code + payload). The checksum is XOR of every byte from `0xAA` up to (but not including) the checksum byte.

---

## Quick start

```dart
import 'package:bariox_tracker/bariox_tracker.dart';

final tracker = BarioxTracker(password: '000000'); // default password

// Encode the device serial number to the 6-byte BCD format used in frames
final deviceId = BarioxTracker.deviceIdBytes('000123456789');

// Build a lock command — send the returned bytes via BLE GATT write
final lockFrame = tracker.lockFrame(deviceId);

// Parse a broadcast advertisement payload received from the BLE scanner
final broadcast = tracker.parseBroadcast(advertisementBytes);
print('Battery: ${broadcast?.batteryLevel}%');
print('Unlocked: ${broadcast?.isUnlocked}');

// Parse a GATT notification received after sending a command
final response = tracker.parseResponse(notificationBytes);
if (response?.isSuccess ?? false) {
  print('Lock command succeeded, device: ${response?.deviceId}');
} else {
  print('Error: ${response?.responseCode}');
}
```

---

## API reference

### `BarioxTracker`

The main entry point. Constructed with an optional `password` (default `"000000"`).

#### Frame builders

| Method | CMD | Description |
|---|---|---|
| `lockFrame(deviceId)` | `0x01` | Lock the device |
| `unlockFrame(deviceId)` | `0x01` | Unlock the device |
| `queryLockStatusFrame(deviceId)` | `0x02` | Query current lock state |
| `checkDeviceInfoFrame(deviceId)` | `0x04` | Retrieve device metadata |
| `checkSealStatusFrame(deviceId)` | `0x0E` | Query e-seal / tamper status |
| `checkChargingStatusFrame(deviceId)` | `0x0F` | Query battery and charging state |
| `setTimeFrame(deviceId, TrackerTime)` | `0x0B` | Set the device clock |
| `queryTimeFrame(deviceId)` | `0x0C` | Read the device clock |
| `readSoftwareVersionFrame(deviceId)` | `0x14` | Read firmware version string |
| `changePasswordFrame(deviceId, newPassword)` | `0x05` | Change the device password |

#### Parsers

| Method | Input | Returns |
|---|---|---|
| `parseBroadcast(bytes)` | 18-byte advertisement payload | `BroadcastPacket?` |
| `parseResponse(bytes)` | GATT notification bytes | `TrackerResponse?` |

#### Static utilities

| Method | Description |
|---|---|
| `BarioxTracker.deviceIdBytes(String)` | 12-digit decimal string → 6-byte BCD `Uint8List` |
| `BarioxTracker.deviceIdString(Uint8List)` | 6-byte BCD → 12-digit decimal string |
| `BarioxTracker.passwordBytes(String)` | 6-char ASCII password → `Uint8List` |

---

### `BroadcastPacket`

Parsed representation of the 18-byte advertisement.

| Field | Type | Description |
|---|---|---|
| `deviceType` | `TrackerDeviceType?` | A1i or A1m |
| `deviceId` | `String` | 12-digit BCD identifier |
| `hardwareVersion` | `String` | e.g. `"1.0"` |
| `softwareVersion` | `int` | e.g. `10001` for V1.0.0.01 |
| `batteryLevel` | `int` | 0–100 % |
| `temperature` | `int?` | °C; null when device reports 0xFF |
| `isCharging` | `bool` | External charger active |
| `isFullyCharged` | `bool` | Battery at 100 % |
| `hasChargingFault` | `bool` | Charging fault bit |
| `hasBatteryFault` | `bool` | Battery fault bit |
| `isUnlocked` | `bool` | Device is in unlocked state |
| `hasChainIssue` | `bool` | Lock-chain anomaly |
| `isCoverOpen` | `bool` | Front cover open |
| `isRearCoverOpen` | `bool` | Rear cover open |
| `isLockStuck` | `bool` | Motor / mechanism stuck |
| `hasRfModuleFault` | `bool` | RF module fault |

---

### `TrackerResponse`

Parsed response frame received after a command.

| Field / accessor | Type | Description |
|---|---|---|
| `command` | `TrackerCommand?` | Which command this response belongs to |
| `responseCode` | `TrackerResponseCode` | Status from the device |
| `isSuccess` | `bool` | `true` when `responseCode == success` |
| `data` | `Uint8List` | Raw payload after the response code |
| `deviceId` | `String?` | Decoded from first 6 bytes of `data` |
| `time` | `TrackerTime?` | Decoded from `queryTime` (CMD 0x0C) response |
| `softwareVersion` | `String?` | Decoded from `readSoftwareVersion` (CMD 0x14) response |

---

### `TrackerResponseCode`

| Value | Name | Meaning |
|---|---|---|
| `0x00` | `success` | Request processed successfully |
| `0x01` | `invalidChecksum` | XOR checksum verification failed |
| `0x02` | `frameError` | Wrong header or trailer bytes |
| `0x03` | `invalidLength` | Length field mismatch |
| `0x04` | `unsupportedCommand` | Command not supported by device |
| `0x05` | `operationFailed` | General operation failure |
| `0x06` | `wrongPassword` | Incorrect password |
| `0x07` | `deviceBusy` | Device busy, retry later |

---

### `TrackerTime`

BCD-encoded device clock used in `setTime` / `queryTime` frames.

```dart
// From a Dart DateTime
final time = TrackerTime.fromDateTime(DateTime.now());

// From 6-byte BCD bytes in a response
final time = TrackerTime.fromBytes(responseData.sublist(6, 12));

// To bytes for a request frame (handled internally by setTimeFrame)
final bytes = time.toBytes(); // [YY, MM, DD, hh, mm, ss] BCD

// Back to DateTime (century base = 2000)
final dt = time.toDateTime();
```

---

### Low-level builders and parsers

`FrameBuilder` and `FrameParser` are exposed for cases where direct frame control is needed (custom commands, firmware upgrade flows, etc.).

```dart
// Build a raw frame for any command
final frame = FrameBuilder.build(0x09, Uint8List(0)); // factory reset, no data

// Validate a frame's checksum before sending
assert(FrameParser.verifyChecksum(frame));

// Parse a broadcast from raw advertisement bytes
final packet = FrameParser.parseBroadcast(bytes);

// Parse a response from raw GATT notification bytes
final response = FrameParser.parseResponse(bytes);
```

---

## Connecting with a BLE plugin

This package is transport-agnostic. Below is a sketch using [`flutter_reactive_ble`](https://pub.dev/packages/flutter_reactive_ble):

```dart
// 1. Scan — filter by manufacturer code 0x38AF (decimal 14511)
flutterReactiveBle.scanForDevices(
  withServices: [],
  scanMode: ScanMode.lowLatency,
).listen((device) {
  final mfr = device.manufacturerData;
  final packet = tracker.parseBroadcast(mfr);
  if (packet != null) {
    // Found a Bariox device
    connectAndCommand(device.id, packet.deviceId);
  }
});

// 2. Connect and write a lock command
Future<void> connectAndCommand(String macAddress, String deviceIdStr) async {
  final deviceId = BarioxTracker.deviceIdBytes(deviceIdStr);

  final connection = flutterReactiveBle.connectToDevice(id: macAddress);
  await connection.firstWhere((s) => s.connectionState ==
      DeviceConnectionState.connected);

  // 3. Subscribe to notifications on the response characteristic
  flutterReactiveBle
      .subscribeToCharacteristic(responseCharacteristic)
      .listen((bytes) {
    final response = tracker.parseResponse(Uint8List.fromList(bytes));
    if (response?.isSuccess ?? false) {
      print('Locked: ${response?.deviceId}');
    }
  });

  // 4. Write the lock frame
  await flutterReactiveBle.writeCharacteristicWithResponse(
    commandCharacteristic,
    value: tracker.lockFrame(deviceId),
  );
}
```

---

## Running tests

```sh
flutter test
```

Or with coverage via the Very Good CLI:

```sh
dart pub global activate very_good_cli
very_good test --coverage
```

---

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
