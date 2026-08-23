import 'dart:async';

import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:gps_control/features/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:gps_control/features/bluetooth/view/bluetooth_off_placeholder.dart';
import 'package:gps_control/features/bluetooth/view/connected_view.dart';
import 'package:gps_control/features/bluetooth/view/scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root of the Bluetooth tab. Monitors the system BLE adapter and shows an
/// explanatory placeholder when Bluetooth is off; otherwise hands off to the
/// BLoC-driven body.
///
/// [isActive] should be `true` whenever the BLE tab is the currently selected
/// tab. The body uses this to auto-start scanning each time the tab comes into
/// view while the connection is idle.
class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key, required this.isActive});

  /// Whether this tab is currently visible to the user.
  final bool isActive;

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothAdapterStatus _adapterState = BluetoothAdapterStatus.unknown;
  late StreamSubscription<BluetoothAdapterStatus> _adapterSub;

  @override
  void initState() {
    super.initState();
    _adapterSub = context.read<TrackerRepository>().adapterStatus.listen((s) {
      if (mounted) setState(() => _adapterState = s);
    });
  }

  @override
  void dispose() {
    unawaited(_adapterSub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adapterState != BluetoothAdapterStatus.on &&
        _adapterState != BluetoothAdapterStatus.unknown) {
      return BluetoothOffPlaceholder(state: _adapterState);
    }
    return BlocProvider(
      create: (ctx) => BluetoothBloc(ctx.read<TrackerRepository>()),
      child: _BleBody(isActive: widget.isActive),
    );
  }
}

class _BleBody extends StatefulWidget {
  const _BleBody({required this.isActive});

  final bool isActive;

  @override
  State<_BleBody> createState() => _BleBodyState();
}

class _BleBodyState extends State<_BleBody> {
  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoScan());
    }
  }

  @override
  void didUpdateWidget(_BleBody old) {
    super.didUpdateWidget(old);
    // Trigger scan each time the tab becomes active while idle.
    if (!old.isActive && widget.isActive) {
      _maybeAutoScan();
    }
  }

  void _maybeAutoScan() {
    if (!mounted) return;
    final bloc = context.read<BluetoothBloc>();
    if (bloc.state.bleStatus == BleStatus.disconnected) {
      bloc.add(const BleScanStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BleState>(
      buildWhen: (prev, next) =>
          (prev.bleStatus == BleStatus.connected) !=
          (next.bleStatus == BleStatus.connected),
      builder: (context, state) {
        if (state.bleStatus == BleStatus.connected) {
          return const ConnectedView();
        }
        return const ScanView();
      },
    );
  }
}
