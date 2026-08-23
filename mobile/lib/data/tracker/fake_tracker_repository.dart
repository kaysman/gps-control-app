import 'dart:async';

import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:bariox_tracker/bariox_tracker.dart';

/// [TrackerRepository] that answers from canned data instead of hardware, so
/// the app can be demoed and screenshotted without a lock on the desk.
///
/// Timings imitate the real thing: devices trickle into the scan, connecting
/// and commands take about as long as they do over BLE. The status values are
/// the same bytes [LegacyFrameParser] would decode off the wire — `byteB`
/// bit 3 is `back_cover` and bit 5 is `open_lock_state`, so unlocked reads
/// `0x28` and locked `0x08`.
class FakeTrackerRepository implements TrackerRepository {
  static const _appearInterval = Duration(milliseconds: 900);
  static const _connectDelay = Duration(milliseconds: 900);
  static const _commandDelay = Duration(milliseconds: 1100);
  static const _batteryPct = 78;
  static const _serial = '2500000016';

  static final _fleet = [
    const ScannedTracker(
      id: 'CD:4A:5E:80:E3:9E',
      name: 'HB_$_serial',
      serial: _serial,
      rssi: -47,
    ),
    const ScannedTracker(
      id: 'FE:92:54:AE:D0:06',
      name: 'HB_2500000017',
      serial: '2500000017',
      rssi: -63,
    ),
    const ScannedTracker(
      id: 'D2:18:B7:0C:41:5A',
      name: 'HB_2500000020',
      serial: '2500000020',
      rssi: -78,
    ),
  ];

  final _scanResults = StreamController<List<ScannedTracker>>.broadcast();
  final _scanStopped = StreamController<void>.broadcast();
  final _connectionLost = StreamController<void>.broadcast();

  final _scanTimers = <Timer>[];
  bool _unlocked = false;
  bool _connected = false;

  @override
  Future<bool> get isSupported async => true;

  @override
  Stream<BluetoothAdapterStatus> get adapterStatus =>
      Stream.value(BluetoothAdapterStatus.on);

  @override
  Future<bool> ensureAdapterOn() async => true;

  @override
  Stream<List<ScannedTracker>> get scanResults => _scanResults.stream;

  @override
  Stream<void> get scanStopped => _scanStopped.stream;

  /// Returns as soon as the scan is under way, like the real one — results
  /// arrive on [scanResults] afterwards.
  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await stopScan();
    _scanResults.add(const []);

    final found = <ScannedTracker>[];
    for (var i = 0; i < _fleet.length; i++) {
      _scanTimers.add(
        Timer(_appearInterval * (i + 1), () {
          if (_scanResults.isClosed) return;
          found.add(_fleet[i]);
          _scanResults.add(List.unmodifiable(found));
        }),
      );
    }

    // Run out the rest of the window, then report the scan over.
    _scanTimers.add(
      Timer(timeout, () {
        if (!_scanStopped.isClosed) _scanStopped.add(null);
      }),
    );
  }

  @override
  Future<void> stopScan() async {
    for (final timer in _scanTimers) {
      timer.cancel();
    }
    _scanTimers.clear();
  }

  @override
  Stream<void> get connectionLost => _connectionLost.stream;

  @override
  Future<void> connect(ScannedTracker tracker) async {
    await stopScan();
    await Future<void>.delayed(_connectDelay);
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Future<LegacyStatus> readStatus() => _command(() {});

  @override
  Future<LegacyStatus> unlock() => _command(() => _unlocked = true);

  @override
  Future<LegacyStatus> lock() => _command(() => _unlocked = false);

  @override
  Future<void> dispose() async {
    await stopScan();
    await _scanResults.close();
    await _scanStopped.close();
    await _connectionLost.close();
  }

  Future<LegacyStatus> _command(void Function() apply) async {
    if (!_connected) throw const TrackerException('Not connected');
    await Future<void>.delayed(_commandDelay);
    apply();
    return LegacyStatus(
      deviceId: _serial,
      batteryPct: _batteryPct,
      byteARaw: 0x01,
      byteBRaw: _unlocked ? 0x28 : 0x08,
      flags: [
        'back_cover',
        if (_unlocked) 'open_lock_state',
      ],
    );
  }
}
