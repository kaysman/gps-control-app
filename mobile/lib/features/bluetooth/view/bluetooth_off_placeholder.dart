import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Shown when the system BLE adapter is off, unavailable, etc.
class BluetoothOffPlaceholder extends StatelessWidget {
  const BluetoothOffPlaceholder({required this.state, super.key});

  final BluetoothAdapterStatus state;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final label = state.name;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(32, topPad + 80, 32, 0),
      child: Column(
        children: [
          const Icon(Icons.bluetooth_disabled, size: 72, color: kMute2),
          const SizedBox(height: 16),
          Text(
            l10n.bluetoothOffTitle(label),
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.bluetoothOffMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 13,
              color: kMute,
            ),
          ),
        ],
      ),
    );
  }
}
