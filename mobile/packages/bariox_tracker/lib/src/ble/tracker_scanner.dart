import 'dart:async';
import 'dart:typed_data';

import 'package:bariox_tracker/src/ble/discovered_tracker.dart';
import 'package:bariox_tracker/src/ble/nus_constants.dart';
import 'package:bariox_tracker/src/protocol/frame_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Scans for Bariox e-lock devices over BLE.
///
/// Two identification paths, in order:
///
/// 1. **Docx broadcast format** — `48 4C 38 AF …` manufacturer-specific data
///    that includes the 18-byte status payload. No HB-series unit we have
///    actually advertises this; kept for forward compatibility.
/// 2. **Local Name + NUS service UUID** — `HB_<digits>` advertised local name
///    accompanied by Nordic UART Service (`6e400001-…`). This is what every
///    real test unit uses today.
abstract final class TrackerScanner {
  /// Local Name prefix that identifies a Bariox HB-series lock.
  static const String namePrefix = 'HB_';

  /// Returns a stream of nearby Bariox devices.
  ///
  /// Each device is emitted once (subsequent advertisements from the same MAC
  /// are deduplicated). The stream closes when the scan stops (after [timeout]
  /// or when [FlutterBluePlus.stopScan] is called).
  ///
  /// If [deviceId] is provided, only the device with that 10-digit decimal SN
  /// (or 12-digit BCD-decoded SN, when the docx broadcast is present) is
  /// emitted.
  static Stream<DiscoveredTracker> scan({
    String? deviceId,
    Duration timeout = const Duration(seconds: 15),
  }) {
    final seenMacs = <String>{};
    final controller = StreamController<DiscoveredTracker>();

    late StreamSubscription<List<ScanResult>> resultSub;
    late StreamSubscription<bool> stateSub;

    void close() {
      unawaited(resultSub.cancel());
      unawaited(stateSub.cancel());
      if (!controller.isClosed) unawaited(controller.close());
    }

    resultSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final mac = result.device.remoteId.str;
        if (seenMacs.contains(mac)) continue;

        final discovered = _identify(result);
        if (discovered == null) continue;
        if (deviceId != null && discovered.deviceId != deviceId) continue;

        seenMacs.add(mac);
        controller.add(discovered);
      }
    });

    stateSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) close();
    });

    controller.onCancel = () {
      unawaited(FlutterBluePlus.stopScan());
      close();
    };

    unawaited(FlutterBluePlus.startScan(timeout: timeout));

    return controller.stream;
  }

  /// Scans until a device matching [deviceId] is found, then stops scanning
  /// and returns it. Returns null if the device is not found within [timeout].
  static Future<DiscoveredTracker?> findDevice({
    required String deviceId,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final completer = Completer<DiscoveredTracker?>();

    final sub = scan(deviceId: deviceId, timeout: timeout).listen(
      (tracker) {
        if (!completer.isCompleted) {
          unawaited(FlutterBluePlus.stopScan());
          completer.complete(tracker);
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(null);
      },
    );

    final result = await completer.future;
    await sub.cancel();
    return result;
  }

  /// Reconstructs the full manufacturer payload from the (companyId, data)
  /// pair that flutter_blue_plus exposes. The on-air bytes are
  /// `[companyLow, companyHigh, ...data]` — FBP splits this into the map
  /// entry; we put it back together for parsers that expect the raw stream.
  static Uint8List reconstructManufacturerData(int companyId, Uint8List data) {
    final bytes = Uint8List(2 + data.length);
    bytes[0] = companyId & 0xFF;
    bytes[1] = (companyId >> 8) & 0xFF;
    bytes.setRange(2, bytes.length, data);
    return bytes;
  }

  // ── Private identification ────────────────────────────────────────────────

  static DiscoveredTracker? _identify(ScanResult result) {
    // 1. Try the docx broadcast format first (current units don't ship with
    // this, but keep the path in case firmware adds it later).
    for (final entry in result.advertisementData.manufacturerData.entries) {
      final bytes = reconstructManufacturerData(
        entry.key,
        Uint8List.fromList(entry.value),
      );
      final packet = FrameParser.parseBroadcast(bytes);
      if (packet != null) {
        return DiscoveredTracker(
          device: result.device,
          advName: result.advertisementData.advName,
          rssi: result.rssi,
          packet: packet,
        );
      }
    }

    // 2. Fall back to "HB_<digits>" local name accompanied by the Nordic
    // UART Service in the advertised service UUIDs.
    final advName = result.advertisementData.advName;
    if (!advName.startsWith(namePrefix)) return null;
    final services = result.advertisementData.serviceUuids;
    final hasNus = services.any(
      (g) => g == Guid(NusConstants.serviceUuid),
    );
    if (!hasNus) return null;

    return DiscoveredTracker(
      device: result.device,
      advName: advName,
      rssi: result.rssi,
    );
  }
}
