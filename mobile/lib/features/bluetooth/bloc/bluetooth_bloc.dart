import 'dart:async';

import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:bloc/bloc.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

/// BLoC that drives scanning, connection, and lock commands for a single
/// tracker.
///
/// Talks only to a [TrackerRepository], so it neither knows nor cares whether
/// a real lock is answering.
class BluetoothBloc extends Bloc<BluetoothEvent, BleState> {
  /// Creates a [BluetoothBloc] in the disconnected idle state.
  BluetoothBloc(this._trackers) : super(const BleState()) {
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

  final TrackerRepository _trackers;

  Timer? _scanTimer;
  StreamSubscription<List<ScannedTracker>>? _resultsSub;
  StreamSubscription<void>? _scanStoppedSub;
  StreamSubscription<void>? _connectionLostSub;

  @override
  Future<void> close() async {
    _scanTimer?.cancel();
    await _resultsSub?.cancel();
    await _scanStoppedSub?.cancel();
    await _connectionLostSub?.cancel();
    await _trackers.disconnect();
    return super.close();
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onScanStarted(
    BleScanStarted event,
    Emitter<BleState> emit,
  ) async {
    if (!await _trackers.isSupported) {
      emit(
        state.copyWith(
          connectionError: 'Bluetooth not supported on this device',
        ),
      );
      return;
    }
    if (!await _trackers.ensureAdapterOn()) {
      emit(state.copyWith(connectionError: 'Bluetooth is not enabled'));
      return;
    }

    emit(
      state.copyWith(
        bleStatus: BleStatus.scanning,
        scannedDevices: const <ScannedTracker>[],
        scanSecondsLeft: kBleScanDuration,
        connectionError: null,
      ),
    );

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _BleScanTicked()),
    );

    await _resultsSub?.cancel();
    _resultsSub = _trackers.scanResults.listen(
      (found) => add(_BleResultsUpdated(found)),
      onError: (Object e) => add(_BleScanFailed(_messageOf(e))),
    );

    await _scanStoppedSub?.cancel();
    _scanStoppedSub = _trackers.scanStopped.listen(
      (_) => add(const _BleScanCompleted()),
    );

    try {
      await _trackers.startScan(
        timeout: const Duration(seconds: kBleScanDuration),
      );
    } on TrackerException catch (e) {
      add(_BleScanFailed(e.message));
    }
  }

  void _onScanTicked(_BleScanTicked event, Emitter<BleState> emit) {
    final left = (state.scanSecondsLeft - 1).clamp(0, kBleScanDuration);
    emit(state.copyWith(scanSecondsLeft: left));
    if (left == 0) _scanTimer?.cancel();
  }

  void _onResultsUpdated(_BleResultsUpdated event, Emitter<BleState> emit) {
    emit(state.copyWith(scannedDevices: event.found));
  }

  void _onScanCompleted(_BleScanCompleted event, Emitter<BleState> emit) {
    _stopScanning();
    if (state.bleStatus == BleStatus.scanning) {
      emit(state.copyWith(bleStatus: BleStatus.disconnected));
    }
  }

  void _onScanFailed(_BleScanFailed event, Emitter<BleState> emit) {
    _stopScanning();
    emit(
      state.copyWith(
        bleStatus: BleStatus.disconnected,
        connectionError: event.message,
      ),
    );
  }

  Future<void> _onScanStopped(
    BleScanStopped event,
    Emitter<BleState> emit,
  ) async {
    _stopScanning();
    await _trackers.stopScan();
    emit(state.copyWith(bleStatus: BleStatus.disconnected));
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    unawaited(_resultsSub?.cancel());
    unawaited(_scanStoppedSub?.cancel());
    _resultsSub = null;
    _scanStoppedSub = null;
  }

  // ── Connection ────────────────────────────────────────────────────────────

  Future<void> _onConnectRequested(
    BleConnectRequested event,
    Emitter<BleState> emit,
  ) async {
    _stopScanning();
    emit(
      state.copyWith(
        bleStatus: BleStatus.connecting,
        connectionError: null,
        lastStatus: null,
        commandError: null,
      ),
    );

    try {
      await _trackers.connect(event.tracker);
    } on TrackerException catch (e) {
      emit(
        state.copyWith(
          bleStatus: BleStatus.disconnected,
          connectionError: e.message,
        ),
      );
      return;
    }

    await _connectionLostSub?.cancel();
    _connectionLostSub = _trackers.connectionLost.listen(
      (_) => add(const _BleConnectionLost()),
    );

    emit(
      state.copyWith(
        bleStatus: BleStatus.connected,
        connectedTracker: event.tracker,
      ),
    );

    // Fetch status straight away so the dial shows a real reading.
    add(const BleStatusRefreshRequested());
  }

  Future<void> _onDisconnectRequested(
    BleDisconnectRequested event,
    Emitter<BleState> emit,
  ) async {
    await _connectionLostSub?.cancel();
    _connectionLostSub = null;
    await _trackers.disconnect();
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
    unawaited(_connectionLostSub?.cancel());
    _connectionLostSub = null;
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
  ) => _runCommand(
    BleCommand.unlock,
    emit,
    _trackers.unlock,
    succeeded: (status) => status.isUnlocked,
    failure: 'Unlock failed — check password or battery',
  );

  Future<void> _onLockRequested(
    BleLockRequested event,
    Emitter<BleState> emit,
  ) => _runCommand(
    BleCommand.lock,
    emit,
    _trackers.lock,
    succeeded: (status) => !status.isUnlocked,
    failure: 'Lock failed — check password or battery',
  );

  Future<void> _onStatusRefreshRequested(
    BleStatusRefreshRequested event,
    Emitter<BleState> emit,
  ) => _runCommand(BleCommand.refresh, emit, _trackers.readStatus);

  /// Runs [action], holding [cmd] busy until the lock has reported back.
  ///
  /// A command counts as done only when the status read afterwards agrees it
  /// happened, which is why [succeeded] inspects the reading rather than
  /// trusting the acknowledgement.
  Future<void> _runCommand(
    BleCommand cmd,
    Emitter<BleState> emit,
    Future<LegacyStatus> Function() action, {
    bool Function(LegacyStatus status)? succeeded,
    String? failure,
  }) async {
    emit(
      state.copyWith(
        busyCommand: cmd,
        commandError: null,
        lastCompletedCommand: null,
      ),
    );

    try {
      final status = await action();
      final ok = succeeded?.call(status) ?? true;
      emit(
        state.copyWith(
          busyCommand: null,
          lastStatus: status,
          lastCompletedCommand: ok ? cmd : null,
          commandError: ok ? null : failure,
        ),
      );
    } on TrackerException catch (e) {
      emit(state.copyWith(busyCommand: null, commandError: e.message));
    }
  }

  static String _messageOf(Object error) =>
      error is TrackerException ? error.message : '$error';
}
