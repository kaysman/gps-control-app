part of 'bluetooth_bloc.dart';

/// How many seconds a single BLE scan runs before timing out.
const kBleScanDuration = 15;

/// BLE connection phase.
enum BleStatus { disconnected, scanning, connecting, connected }

/// Which one-tap BLE command is currently in-flight.
enum BleCommand { unlock, lock, refresh }

// Sentinel that distinguishes "pass null to clear this field" from
// "leave this field untouched".
class _Absent {
  const _Absent();
}

const _absent = _Absent();

/// Immutable state for [BluetoothBloc].
class BleState {
  /// Creates a [BleState].
  const BleState({
    this.bleStatus = BleStatus.disconnected,
    this.connectedTracker,
    this.connectionError,
    this.scannedDevices = const [],
    this.scanSecondsLeft = kBleScanDuration,
    this.busyCommand,
    this.lastStatus,
    this.lastCompletedCommand,
    this.commandError,
  });

  /// Current BLE lifecycle phase.
  final BleStatus bleStatus;

  /// The tracker we are connected to, when [bleStatus] is
  /// [BleStatus.connected].
  final ScannedTracker? connectedTracker;

  /// Human-readable scan / connection error, if any.
  final String? connectionError;

  /// Bariox HB_ devices found during the most recent scan.
  final List<ScannedTracker> scannedDevices;

  /// Seconds remaining in the current scan; counts down from
  /// [kBleScanDuration].
  final int scanSecondsLeft;

  /// The command currently being sent to the lock, or null when idle.
  final BleCommand? busyCommand;

  /// Latest decoded system-status frame from the lock.
  final LegacyStatus? lastStatus;

  /// Set to the command that just finished successfully; cleared when the
  /// next command starts. The UI uses this to trigger toast messages.
  final BleCommand? lastCompletedCommand;

  /// Error from the most recent command, cleared when a new command starts.
  final String? commandError;

  /// Returns a copy of this state with the supplied fields replaced.
  BleState copyWith({
    BleStatus? bleStatus,
    Object? connectedTracker = _absent,
    Object? connectionError = _absent,
    List<ScannedTracker>? scannedDevices,
    int? scanSecondsLeft,
    Object? busyCommand = _absent,
    Object? lastStatus = _absent,
    Object? lastCompletedCommand = _absent,
    Object? commandError = _absent,
  }) {
    return BleState(
      bleStatus: bleStatus ?? this.bleStatus,
      connectedTracker: identical(connectedTracker, _absent)
          ? this.connectedTracker
          : connectedTracker as ScannedTracker?,
      connectionError: identical(connectionError, _absent)
          ? this.connectionError
          : connectionError as String?,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      scanSecondsLeft: scanSecondsLeft ?? this.scanSecondsLeft,
      busyCommand: identical(busyCommand, _absent)
          ? this.busyCommand
          : busyCommand as BleCommand?,
      lastStatus: identical(lastStatus, _absent)
          ? this.lastStatus
          : lastStatus as LegacyStatus?,
      lastCompletedCommand: identical(lastCompletedCommand, _absent)
          ? this.lastCompletedCommand
          : lastCompletedCommand as BleCommand?,
      commandError: identical(commandError, _absent)
          ? this.commandError
          : commandError as String?,
    );
  }
}
