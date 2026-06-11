import 'dart:async';

import 'package:bariox_tracker/src/ble/nus_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// An active BLE connection to a Bariox e-lock.
///
/// Use [TrackerConnection.connect] to establish a connection. The connection
/// exposes a raw [notifications] stream and a [writeFrame] method, plus a
/// generic [sendCommand] helper that pairs the two with a caller-supplied
/// parser. Always call [disconnect] when done.
///
/// ```dart
/// final conn = await TrackerConnection.connect(device);
/// final tracker = const BarioxTrackerLegacy();
/// final response = await conn.sendCommand<LegacyResponse>(
///   tracker.unlockFrame(),
///   parse: (notification) {
///     if (LegacyFrameParser.isPreamble(notification)) return null;
///     if (!LegacyFrameParser.isCompleteFrame(notification)) return null;
///     return LegacyResponse(
///       cmd: notification[3],
///       rawFrame: notification,
///       status: LegacyFrameParser.parseStatus(notification),
///     );
///   },
/// );
/// await conn.disconnect();
/// ```
class TrackerConnection {
  TrackerConnection._({
    required BluetoothDevice device,
    required BluetoothCharacteristic rxChar,
    required BluetoothCharacteristic txChar,
  })  : _device = device,
        _rxChar = rxChar,
        _txChar = txChar;

  final BluetoothDevice _device;
  final BluetoothCharacteristic _rxChar;
  final BluetoothCharacteristic _txChar;

  /// Connects to [device], discovers NUS services, requests a higher MTU, and
  /// enables TX notifications.
  ///
  /// The MTU exchange is **required** before the lock will accept control
  /// commands (`cmd=0x01`) — reads work without it but writes are silently
  /// dropped at the GATT layer. We negotiate to 512 and tolerate failure.
  ///
  /// Throws [StateError] if the device does not expose the Nordic UART Service
  /// or its required characteristics.
  static Future<TrackerConnection> connect(BluetoothDevice device) async {
    debugPrint('[TrackerConn] connecting to ${device.remoteId}');
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 15),
    );
    debugPrint('[TrackerConn] connected — requesting MTU 512');

    try {
      final mtu = await device.requestMtu(512);
      debugPrint('[TrackerConn] MTU negotiated: $mtu');
    } on Exception catch (e) {
      debugPrint('[TrackerConn] MTU negotiation failed (ignored): $e');
    }

    final services = await device.discoverServices();
    debugPrint('[TrackerConn] discovered ${services.length} service(s): '
        '${services.map((s) => s.serviceUuid).join(', ')}');

    final nus = services.firstWhereOrNull(
      (s) => s.serviceUuid == Guid(NusConstants.serviceUuid),
    );
    if (nus == null) {
      throw StateError('Nordic UART Service not found on device');
    }

    final rxChar = nus.characteristics.firstWhereOrNull(
      (c) => c.characteristicUuid == Guid(NusConstants.rxUuid),
    );
    final txChar = nus.characteristics.firstWhereOrNull(
      (c) => c.characteristicUuid == Guid(NusConstants.txUuid),
    );

    if (rxChar == null) throw StateError('NUS RX characteristic not found');
    if (txChar == null) throw StateError('NUS TX characteristic not found');

    await txChar.setNotifyValue(true);
    debugPrint('[TrackerConn] TX notifications enabled');

    return TrackerConnection._(device: device, rxChar: rxChar, txChar: txChar);
  }

  /// Stream of raw GATT notifications received on the NUS TX characteristic.
  /// Each event is exactly one notification — frames that span multiple
  /// notifications (rare with MTU 512 and our small frames) are NOT
  /// reassembled here; do that in the caller if you need to.
  Stream<Uint8List> get notifications => _txChar.onValueReceived.map(
        (bytes) => Uint8List.fromList(bytes),
      );

  /// Writes [frame] to the NUS RX characteristic. Uses write-with-response
  /// by default so transmission is acknowledged at the ATT layer.
  Future<void> writeFrame(Uint8List frame) async {
    final hex = frame
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
    debugPrint('[TrackerConn] writeFrame ${frame.length}B → $hex');
    await _rxChar.write(frame);
  }

  /// Writes [frame] and listens to [notifications] until [parse] returns a
  /// non-null result, then completes with that result. Returns null on
  /// [timeout]. The [parse] callback is called once per notification — return
  /// null to keep waiting (e.g. for known preamble bytes), return a value when
  /// the notification is the response you want.
  Future<T?> sendCommand<T>(
    Uint8List frame, {
    required T? Function(Uint8List notification) parse,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final completer = Completer<T?>();

    final sub = notifications.listen((bytes) {
      if (completer.isCompleted) return;
      final hex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      debugPrint('[TrackerConn] ← notification ${bytes.length}B: $hex');
      final result = parse(bytes);
      if (result != null) completer.complete(result);
    });

    try {
      await writeFrame(frame);
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      debugPrint('[TrackerConn] ✗ sendCommand timeout');
      return null;
    } finally {
      await sub.cancel();
    }
  }

  /// Disconnects from the device.
  Future<void> disconnect() => _device.disconnect();

  /// Stream of connection state changes for this device.
  Stream<BluetoothConnectionState> get connectionState =>
      _device.connectionState;

  /// The underlying BLE device.
  BluetoothDevice get device => _device;
}

extension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
