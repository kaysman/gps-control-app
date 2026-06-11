import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown when the system BLE adapter is off, unavailable, etc.
class BluetoothOffPlaceholder extends StatelessWidget {
  const BluetoothOffPlaceholder({super.key, required this.state});

  final BluetoothAdapterState state;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final label = state.toString().split('.').last;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(32, topPad + 80, 32, 0),
      child: Column(
        children: [
          Icon(Icons.bluetooth_disabled, size: 72, color: kMute2),
          const SizedBox(height: 16),
          Text(
            l10n.bluetoothOffTitle(label),
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.bluetoothOffMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: kMute),
          ),
        ],
      ),
    );
  }
}
