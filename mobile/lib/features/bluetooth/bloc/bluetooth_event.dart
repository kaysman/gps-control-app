part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent {
  const BluetoothEvent();
}

// ── Public events ────────────────────────────────────────────────────────────

final class BleScanStarted extends BluetoothEvent {
  const BleScanStarted();
}

final class BleScanStopped extends BluetoothEvent {
  const BleScanStopped();
}

final class BleConnectRequested extends BluetoothEvent {
  const BleConnectRequested(this.tracker);
  final ScannedTracker tracker;
}

final class BleDisconnectRequested extends BluetoothEvent {
  const BleDisconnectRequested();
}

final class BleUnlockRequested extends BluetoothEvent {
  const BleUnlockRequested();
}

final class BleLockRequested extends BluetoothEvent {
  const BleLockRequested();
}

final class BleStatusRefreshRequested extends BluetoothEvent {
  const BleStatusRefreshRequested();
}

// ── Internal events ──────────────────────────────────────────────────────────

final class _BleScanTicked extends BluetoothEvent {
  const _BleScanTicked();
}

final class _BleResultsUpdated extends BluetoothEvent {
  const _BleResultsUpdated(this.found);
  final List<ScannedTracker> found;
}

final class _BleScanCompleted extends BluetoothEvent {
  const _BleScanCompleted();
}

final class _BleScanFailed extends BluetoothEvent {
  const _BleScanFailed(this.message);
  final String message;
}

final class _BleConnectionLost extends BluetoothEvent {
  const _BleConnectionLost();
}
