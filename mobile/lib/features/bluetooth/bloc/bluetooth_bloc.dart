import 'dart:async';
import 'dart:io';

import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

/// BLoC that manages BLE scanning, connection, and lock commands for a single
/// Bariox HB-series tracker.
class BluetoothBloc extends Bloc<BluetoothEvent, BleState> {
  /// Creates a [BluetoothBloc] in the disconnected idle state.
  BluetoothBloc() : super(const BleState()) {
    on<BleScanStarted>(_onScanStarted);
    on<BleScanStopped>(_onScanStopped);
    on<BleConnectRequested>(_onConnectRequested);
    on<BleDisconnectRequested>(_onDisconnectRequested);
    on<BleUnlockRequested>(_onUnlockRequested);
    on<BleLockRequested>(_onLockRequested);
    on<BleStatusRefreshRequested>(_onStatusRefreshRequested);

    on<_BleScanTicked>(_onScanTicked);
    on<_BleResultsUpdated>(_onResultsUpdated);
    on<_BleScanCompleted>(_onScanCompleted);
    on<_BleScanFailed>(_onScanFailed);
    on<_BleConnectionLost>(_onConnectionLost);
  }

  static const _tracker = BarioxTrackerLegacy();

  Timer? _scanTimer;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningStateSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  TrackerConnection? _connection;

  @override
  Future<void> close() async {
    _scanTimer?.cancel();
    unawaited(_scanSub?.cancel());
    unawaited(_isScanningStateSub?.cancel());
    unawaited(_connStateSub?.cancel());
    unawaited(_connection?.disconnect());
    return super.close();
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onScanStarted(
    BleScanStarted event,
    Emitter<BleState> emit,
  ) async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      emit(
        state.copyWith(
          connectionError: 'Bluetooth not supported on this device',
        ),
      );
      return;
    }

    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        adapterState = await FlutterBluePlus.adapterState
            .where((s) => s == BluetoothAdapterState.on)
            .first
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => BluetoothAdapterState.off,
            );
      }
      if (adapterState != BluetoothAdapterState.on) {
        emit(state.copyWith(connectionError: 'Bluetooth is not enabled'));
        return;
      }
    }

    emit(
      state.copyWith(
        bleStatus: BleStatus.scanning,
        scannedDevices: const <DiscoveredTracker>[],
        scanSecondsLeft: kBleScanDuration,
        connectionError: null,
      ),
    );

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _BleScanTicked()),
    );

    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.onScanResults.listen(
      (results) => add(_BleResultsUpdated(results)),
      onError: (Object e) => add(_BleScanFailed(e.toString())),
    );
    FlutterBluePlus.cancelWhenScanComplete(_scanSub!);

    await _isScanningStateSub?.cancel();
    _isScanningStateSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) add(const _BleScanCompleted());
    });

    unawaited(
      FlutterBluePlus.startScan(
        timeout: const Duration(seconds: kBleScanDuration),
      ),
    );
  }

  void _onScanTicked(_BleScanTicked event, Emitter<BleState> emit) {
    final left = (state.scanSecondsLeft - 1).clamp(0, kBleScanDuration);
    emit(state.copyWith(scanSecondsLeft: left));
    if (left == 0) _scanTimer?.cancel();
  }

  void _onResultsUpdated(
    _BleResultsUpdated event,
    Emitter<BleState> emit,
  ) {
    final seen = <String>{};
    final devices = <DiscoveredTracker>[];
    for (final result in event.results) {
      final mac = result.device.remoteId.str;
      if (!seen.add(mac)) continue;
      final name = result.advertisementData.advName;
      final hasNus = result.advertisementData.serviceUuids.any(
        (g) => g == Guid(NusConstants.serviceUuid),
      );
      if (name.startsWith(TrackerScanner.namePrefix) && hasNus) {
        devices.add(
          DiscoveredTracker(
            device: result.device,
            advName: name,
            rssi: result.rssi,
          ),
        );
      }
    }
    emit(state.copyWith(scannedDevices: devices));
  }

  void _onScanCompleted(_BleScanCompleted event, Emitter<BleState> emit) {
    _scanTimer?.cancel();
    unawaited(_isScanningStateSub?.cancel());
    if (state.bleStatus == BleStatus.scanning) {
      emit(state.copyWith(bleStatus: BleStatus.disconnected));
    }
  }

  void _onScanFailed(_BleScanFailed event, Emitter<BleState> emit) {
    _scanTimer?.cancel();
    unawaited(_isScanningStateSub?.cancel());
    emit(
      state.copyWith(
        bleStatus: BleStatus.disconnected,
        connectionError: event.message,
      ),
    );
  }

  void _onScanStopped(BleScanStopped event, Emitter<BleState> emit) {
    _scanTimer?.cancel();
    unawaited(_isScanningStateSub?.cancel());
    unawaited(_scanSub?.cancel());
    unawaited(FlutterBluePlus.stopScan());
    emit(state.copyWith(bleStatus: BleStatus.disconnected));
  }

  // ── Connection ────────────────────────────────────────────────────────────

  Future<void> _onConnectRequested(
    BleConnectRequested event,
    Emitter<BleState> emit,
  ) async {
    _scanTimer?.cancel();
    unawaited(_isScanningStateSub?.cancel());
    unawaited(_scanSub?.cancel());
    unawaited(FlutterBluePlus.stopScan());

    emit(
      state.copyWith(
        bleStatus: BleStatus.connecting,
        connectionError: null,
        lastStatus: null,
        commandError: null,
      ),
    );

    try {
      final conn = await event.tracker.connect();
      _connection = conn;

      await _connStateSub?.cancel();
      _connStateSub = conn.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          add(const _BleConnectionLost());
        }
      });
      event.tracker.device.cancelWhenDisconnected(
        _connStateSub!,
        delayed: true,
        next: true,
      );

      emit(
        state.copyWith(
          bleStatus: BleStatus.connected,
          connectedTracker: event.tracker,
        ),
      );

      // Auto-fetch status so the UI shows real lock/battery data immediately.
      add(const BleStatusRefreshRequested());
    } on Exception catch (e) {
      emit(
        state.copyWith(
          bleStatus: BleStatus.disconnected,
          connectionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDisconnectRequested(
    BleDisconnectRequested event,
    Emitter<BleState> emit,
  ) async {
    await _connStateSub?.cancel();
    await _connection?.disconnect();
    _connection = null;
    emit(
      state.copyWith(
        bleStatus: BleStatus.disconnected,
        connectedTracker: null,
        connectionError: null,
        busyCommand: null,
        lastStatus: null,
        commandError: null,
      ),
    );
  }

  void _onConnectionLost(_BleConnectionLost event, Emitter<BleState> emit) {
    _connection = null;
    unawaited(_connStateSub?.cancel());
    emit(
      state.copyWith(
        bleStatus: BleStatus.disconnected,
        connectedTracker: null,
        busyCommand: null,
      ),
    );
  }

  // ── Commands ──────────────────────────────────────────────────────────────

  Future<void> _onUnlockRequested(
    BleUnlockRequested event,
    Emitter<BleState> emit,
  ) async {
    final conn = _connection;
    if (conn == null) {
      emit(state.copyWith(commandError: 'Not connected'));
      return;
    }

    // Stay busy through the unlock + follow-up status fetch so the dial button
    // remains in "Sending…" state until we have an accurate lock reading.
    emit(
      state.copyWith(
        busyCommand: BleCommand.unlock,
        commandError: null,
        lastCompletedCommand: null,
      ),
    );

    try {
      final echo = await conn.sendCommand<LegacyResponse>(
        _tracker.unlockFrame(),
        parse: _parseLegacyNotification,
        timeout: const Duration(seconds: 7),
      );
      if (echo == null) {
        emit(
          state.copyWith(
            busyCommand: null,
            commandError: 'No response (timeout)',
          ),
        );
        return;
      }
      final statusResp = await conn.sendCommand<LegacyResponse>(
        _tracker.statusFrame(),
        parse: _parseLegacyNotification,
        timeout: const Duration(seconds: 7),
      );
      final newStatus = statusResp?.status;
      final succeeded = newStatus?.isUnlocked == true;
      emit(
        state.copyWith(
          busyCommand: null,
          lastStatus: newStatus ?? state.lastStatus,
          lastCompletedCommand: succeeded ? BleCommand.unlock : null,
          commandError: succeeded
              ? null
              : (newStatus == null
                    ? 'No status response'
                    : 'Unlock failed — check password or battery'),
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(busyCommand: null, commandError: e.toString()));
    }
  }

  Future<void> _onLockRequested(
    BleLockRequested event,
    Emitter<BleState> emit,
  ) async {
    final conn = _connection;
    if (conn == null) {
      emit(state.copyWith(commandError: 'Not connected'));
      return;
    }

    emit(
      state.copyWith(
        busyCommand: BleCommand.lock,
        commandError: null,
        lastCompletedCommand: null,
      ),
    );

    try {
      final echo = await conn.sendCommand<LegacyResponse>(
        _tracker.lockFrame(),
        parse: _parseLegacyNotification,
        timeout: const Duration(seconds: 7),
      );
      if (echo == null) {
        emit(
          state.copyWith(
            busyCommand: null,
            commandError: 'No response (timeout)',
          ),
        );
        return;
      }
      final statusResp = await conn.sendCommand<LegacyResponse>(
        _tracker.statusFrame(),
        parse: _parseLegacyNotification,
        timeout: const Duration(seconds: 7),
      );
      final newStatus = statusResp?.status;
      final succeeded = newStatus?.isUnlocked == false;
      emit(
        state.copyWith(
          busyCommand: null,
          lastStatus: newStatus ?? state.lastStatus,
          lastCompletedCommand: succeeded ? BleCommand.lock : null,
          commandError: succeeded
              ? null
              : (newStatus == null
                    ? 'No status response'
                    : 'Lock failed — check password or battery'),
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(busyCommand: null, commandError: e.toString()));
    }
  }

  Future<void> _onStatusRefreshRequested(
    BleStatusRefreshRequested event,
    Emitter<BleState> emit,
  ) async {
    final conn = _connection;
    if (conn == null) {
      emit(state.copyWith(commandError: 'Not connected'));
      return;
    }

    emit(
      state.copyWith(
        busyCommand: BleCommand.refresh,
        commandError: null,
        lastCompletedCommand: null,
      ),
    );

    try {
      final response = await conn.sendCommand<LegacyResponse>(
        _tracker.statusFrame(),
        parse: _parseLegacyNotification,
        timeout: const Duration(seconds: 7),
      );
      if (response == null) {
        emit(
          state.copyWith(
            busyCommand: null,
            commandError: 'No response (timeout)',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          busyCommand: null,
          lastStatus: response.status ?? state.lastStatus,
          lastCompletedCommand: BleCommand.refresh,
          commandError: null,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(busyCommand: null, commandError: e.toString()));
    }
  }

  // Drops the 1-byte 0xAA preamble; completes only on a full, valid frame.
  static LegacyResponse? _parseLegacyNotification(Uint8List notification) {
    if (LegacyFrameParser.isPreamble(notification)) return null;
    if (!LegacyFrameParser.isCompleteFrame(notification)) return null;
    return LegacyResponse(
      cmd: notification[3],
      rawFrame: notification,
      status: LegacyFrameParser.parseStatus(notification),
    );
  }
}
