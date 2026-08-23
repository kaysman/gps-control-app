import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:flutter/foundation.dart';

/// Power state of the host's Bluetooth adapter, as the app layer sees it.
enum BluetoothAdapterStatus {
  /// Not yet reported by the platform.
  unknown,

  /// Ready to scan.
  on,

  /// Powered off by the user.
  off,

  /// The app lacks the permission to use Bluetooth.
  unauthorized,

  /// No Bluetooth hardware, or the platform doesn't support it.
  unavailable,
}

/// A tracker seen during a scan.
///
/// [id] is an opaque handle — pass it back to
/// [TrackerRepository.connect] to open a connection. Deliberately not a MAC
/// address in the type's contract: only the repository knows what it is.
@immutable
class ScannedTracker {
  /// Creates a [ScannedTracker].
  const ScannedTracker({
    required this.id,
    required this.name,
    required this.serial,
    required this.rssi,
  });

  /// Opaque connection handle.
  final String id;

  /// Advertised name, e.g. `HB_2500000016`. May be empty.
  final String name;

  /// Device serial number, e.g. `2500000016`.
  final String serial;

  /// Signal strength in dBm at the time of discovery.
  final int rssi;

  /// Name to show in the UI, falling back to the serial number.
  String get label => name.isNotEmpty ? name : serial;

  @override
  bool operator ==(Object other) =>
      other is ScannedTracker && other.id == id && other.rssi == rssi;

  @override
  int get hashCode => Object.hash(id, rssi);
}

/// Anything that went wrong talking to a lock. [message] is safe to show.
class TrackerException implements Exception {
  /// Creates a [TrackerException].
  const TrackerException(this.message);

  /// Human-readable cause.
  final String message;

  @override
  String toString() => 'TrackerException: $message';
}

/// The app's source of truth for lock data over Bluetooth.
///
/// Callers work in terms of [ScannedTracker] and [LegacyStatus] and never see
/// the BLE plugin, the frame format, or whether the data came from real
/// hardware. Every command completes with the lock's own reading of itself, or
/// throws [TrackerException].
abstract interface class TrackerRepository {
  /// Whether this host can do BLE at all.
  Future<bool> get isSupported;

  /// Adapter power state. Emits the current value on listen.
  Stream<BluetoothAdapterStatus> get adapterStatus;

  /// Ensures the adapter is on, asking the platform to enable it where that is
  /// allowed. Returns whether it ended up on.
  Future<bool> ensureAdapterOn();

  /// Trackers found so far in the running scan. Each event is the full list,
  /// growing as devices are discovered.
  Stream<List<ScannedTracker>> get scanResults;

  /// Fires when a scan ends, whether by timeout or [stopScan].
  Stream<void> get scanStopped;

  /// Starts a scan that stops itself after [timeout].
  Future<void> startScan({Duration timeout});

  /// Stops the running scan, if any.
  Future<void> stopScan();

  /// Fires when an established connection drops on its own.
  Stream<void> get connectionLost;

  /// Connects to [tracker]. Stops any running scan first.
  Future<void> connect(ScannedTracker tracker);

  /// Closes the active connection, if any.
  Future<void> disconnect();

  /// Reads the lock's current status.
  Future<LegacyStatus> readStatus();

  /// Unlocks, then reads back the resulting status.
  Future<LegacyStatus> unlock();

  /// Locks, then reads back the resulting status.
  Future<LegacyStatus> lock();

  /// Releases every resource held. The repository is unusable afterwards.
  Future<void> dispose();
}
