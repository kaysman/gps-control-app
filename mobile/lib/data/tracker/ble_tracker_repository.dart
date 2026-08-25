import 'dart:async';
import 'dart:io';

import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';

/// [TrackerRepository] backed by real hardware: `flutter_blue_plus` for the
/// transport and `bariox_tracker` for the frame format.
///
/// Speaks the legacy `AA-55-A9` protocol — the one HB-series firmware actually
/// answers. See [BarioxTrackerLegacy].
class BleTrackerRepository implements TrackerRepository {
  static const _protocol = BarioxTrackerLegacy();
  static const _commandTimeout = Duration(seconds: 7);

  final _scanResults = StreamController<List<ScannedTracker>>.broadcast();
  final _scanStopped = StreamController<void>.broadcast();
  final _connectionLost = StreamController<void>.broadcast();

  /// Scan hits by [ScannedTracker.id], so [connect] can recover the BLE handle.
  final _discovered = <String, DiscoveredTracker>{};

  StreamSubscription<DiscoveredTracker>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  TrackerConnection? _connection;

  @override
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  @override
  Stream<BluetoothAdapterStatus> get adapterStatus =>
      FlutterBluePlus.adapterState.map(_toStatus);

  @override
  Future<bool> ensureAdapterOn() async {
    var state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) return true;

    // Android can be asked to power the adapter on; iOS cannot.
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
      state = await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => BluetoothAdapterState.off,
          );
    }
    return state == BluetoothAdapterState.on;
  }

  @override
  Stream<List<ScannedTracker>> get scanResults => _scanResults.stream;

  @override
  Stream<void> get scanStopped => _scanStopped.stream;

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await _scanSub?.cancel();
    _discovered.clear();

    final found = <ScannedTracker>[];
    _scanResults.add(const []);

    _scanSub = TrackerScanner.scan(timeout: timeout).listen(
      (tracker) {
        final scanned = _toScanned(tracker);
        _discovered[scanned.id] = tracker;
        found.add(scanned);
        _scanResults.add(List.unmodifiable(found));
      },
      onError: (Object e) => _scanResults.addError(TrackerException('$e')),
      // TrackerScanner closes its stream when the scan stops.
      onDone: () => _scanStopped.add(null),
    );
  }

  @override
  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    await FlutterBluePlus.stopScan();
  }

  @override
  Stream<void> get connectionLost => _connectionLost.stream;

  @override
  Future<void> connect(ScannedTracker tracker) async {
    final device = _discovered[tracker.id];
    if (device == null) {
      throw TrackerException('${tracker.label} is no longer in range');
    }

    await stopScan();

    await _guard(() async {
      final conn = await device.connect();
      _connection = conn;

      await _connStateSub?.cancel();
      _connStateSub = conn.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          _connection = null;
          _connectionLost.add(null);
        }
      });
      device.device.cancelWhenDisconnected(
        _connStateSub!,
        delayed: true,
        next: true,
      );
    });
  }

  @override
  Future<void> disconnect() async {
    await _connStateSub?.cancel();
    _connStateSub = null;
    final conn = _connection;
    _connection = null;
    await conn?.disconnect();
  }

  @override
  Future<LegacyStatus> readStatus() => _guard(() async {
    final response = await _send(_protocol.statusFrame());
    final status = response?.status;
    if (status == null) throw const TrackerException('No status response');
    return status;
  });

  @override
  Future<LegacyStatus> unlock() => _switch(_protocol.unlockFrame());

  @override
  Future<LegacyStatus> lock() => _switch(_protocol.lockFrame());

  @override
  Future<void> dispose() async {
    await _scanSub?.cancel();
    await _connStateSub?.cancel();
    await _connection?.disconnect();
    await _scanResults.close();
    await _scanStopped.close();
    await _connectionLost.close();
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Sends a switch command, then reads the lock back so the caller learns the
  /// state the lock actually ended up in rather than the state we asked for.
  Future<LegacyStatus> _switch(Uint8List frame) => _guard(() async {
    final echo = await _send(frame);
    if (echo == null) throw const TrackerException('No response (timeout)');
    return readStatus();
  });

  Future<LegacyResponse?> _send(Uint8List frame) {
    final conn = _connection;
    if (conn == null) throw const TrackerException('Not connected');
    return conn.sendCommand<LegacyResponse>(
      frame,
      parse: _parseNotification,
      timeout: _commandTimeout,
    );
  }

  /// Runs [body], turning any platform-level failure into a [TrackerException]
  /// so callers only ever handle one error type.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on TrackerException {
      rethrow;
    } on Exception catch (e) {
      throw TrackerException('$e');
    }
  }

  /// Drops the spurious 1-byte `0xAA` preamble the lock fires before every
  /// real reply; completes only on a full, checksum-valid frame.
  static LegacyResponse? _parseNotification(Uint8List notification) {
    if (LegacyFrameParser.isPreamble(notification)) return null;
    if (!LegacyFrameParser.isCompleteFrame(notification)) return null;
    return LegacyResponse(
      cmd: notification[3],
      rawFrame: notification,
      status: LegacyFrameParser.parseStatus(notification),
    );
  }

  static ScannedTracker _toScanned(DiscoveredTracker tracker) => ScannedTracker(
    id: tracker.device.remoteId.str,
    name: tracker.advName,
    serial: tracker.deviceId,
    rssi: tracker.rssi,
  );

  static BluetoothAdapterStatus _toStatus(BluetoothAdapterState state) =>
      switch (state) {
        BluetoothAdapterState.on => BluetoothAdapterStatus.on,
        BluetoothAdapterState.off ||
        BluetoothAdapterState.turningOff ||
        BluetoothAdapterState.turningOn => BluetoothAdapterStatus.off,
        BluetoothAdapterState.unauthorized =>
          BluetoothAdapterStatus.unauthorized,
        BluetoothAdapterState.unavailable => BluetoothAdapterStatus.unavailable,
        BluetoothAdapterState.unknown => BluetoothAdapterStatus.unknown,
      };
}
