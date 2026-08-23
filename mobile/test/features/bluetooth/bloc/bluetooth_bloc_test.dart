import 'package:gps_control/data/tracker/fake_tracker_repository.dart';
import 'package:gps_control/features/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BluetoothBloc', () {
    late FakeTrackerRepository trackers;
    late BluetoothBloc bloc;

    setUp(() {
      trackers = FakeTrackerRepository();
      bloc = BluetoothBloc(trackers);
    });

    tearDown(() async {
      await bloc.close();
      await trackers.dispose();
    });

    test('starts disconnected with nothing found', () {
      expect(bloc.state.bleStatus, BleStatus.disconnected);
      expect(bloc.state.scannedDevices, isEmpty);
      expect(bloc.state.lastStatus, isNull);
    });

    test('a scan reports the trackers it finds', () async {
      bloc.add(const BleScanStarted());

      final scanning = await bloc.stream.firstWhere(
        (s) => s.bleStatus == BleStatus.scanning,
      );
      expect(scanning.scanSecondsLeft, kBleScanDuration);

      final found = await bloc.stream.firstWhere(
        (s) => s.scannedDevices.length == 3,
      );
      expect(found.scannedDevices.first.serial, '2500000016');
      expect(found.connectionError, isNull);
    });

    test('connecting reads the lock back, and lock/unlock flip it', () async {
      bloc.add(const BleScanStarted());
      final found = await bloc.stream.firstWhere(
        (s) => s.scannedDevices.isNotEmpty,
      );

      bloc.add(BleConnectRequested(found.scannedDevices.first));

      // Connecting auto-fetches status, so the first reading arrives unasked.
      final connected = await bloc.stream.firstWhere(
        (s) => s.bleStatus == BleStatus.connected && s.lastStatus != null,
      );
      expect(connected.lastStatus!.batteryPct, 78);
      expect(connected.lastStatus!.isUnlocked, isFalse);
      expect(connected.lastCompletedCommand, BleCommand.refresh);

      bloc.add(const BleUnlockRequested());
      final unlocked = await bloc.stream.firstWhere(
        (s) => s.lastCompletedCommand == BleCommand.unlock,
      );
      expect(unlocked.lastStatus!.isUnlocked, isTrue);
      expect(unlocked.busyCommand, isNull);
      expect(unlocked.commandError, isNull);

      bloc.add(const BleLockRequested());
      final locked = await bloc.stream.firstWhere(
        (s) => s.lastCompletedCommand == BleCommand.lock,
      );
      expect(locked.lastStatus!.isUnlocked, isFalse);
    });

    test('a command without a connection reports the error', () async {
      bloc.add(const BleStatusRefreshRequested());

      final failed = await bloc.stream.firstWhere(
        (s) => s.commandError != null,
      );
      expect(failed.commandError, 'Not connected');
      expect(failed.busyCommand, isNull);
    });
  });
}
