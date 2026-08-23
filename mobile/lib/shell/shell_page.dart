import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/app/widgets/beta_badge.dart';
import 'package:gps_control/features/bluetooth/view/bluetooth_page.dart';
import 'package:gps_control/features/settings/view/settings_page.dart';
import 'package:gps_control/features/sms/view/sms_page.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The shell's three top-level destinations.
enum AppTab { ble, sms, settings }

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, this.initialTab = AppTab.ble});

  /// Tab shown on first build.
  final AppTab initialTab;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late AppTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 0,
            // IndexedStack keeps all tabs mounted so the BluetoothBloc (and
            // any active BLE connection) survives tab switches.
            child: IndexedStack(
              index: _tab.index,
              children: [
                BluetoothPage(isActive: _tab == AppTab.ble),
                const SmsPage(),
                const SettingsPage(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomTabBar(
              tab: _tab,
              onTab: (t) => setState(() => _tab = t),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar({required this.tab, required this.onTab});

  final AppTab tab;
  final ValueChanged<AppTab> onTab;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(color: kRule)),
      ),
      padding: EdgeInsets.fromLTRB(0, 6, 0, 6 + bottomPad),
      child: Row(
        children: [
          _TabBtn(
            id: AppTab.ble,
            label: l10n.tabBluetooth,
            active: tab == AppTab.ble,
            onTap: () => onTab(AppTab.ble),
          ),
          _TabBtn(
            id: AppTab.sms,
            label: l10n.tabSms,
            active: tab == AppTab.sms,
            showBeta: true,
            onTap: () => onTab(AppTab.sms),
          ),
          _TabBtn(
            id: AppTab.settings,
            label: l10n.tabSettings,
            active: tab == AppTab.settings,
            onTap: () => onTab(AppTab.settings),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.id,
    required this.label,
    required this.active,
    required this.onTap,
    this.showBeta = false,
  });

  final AppTab id;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool showBeta;

  @override
  Widget build(BuildContext context) {
    final color = active ? kNavy : kMute2;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabIcon(id: id, active: active),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: kSans,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (showBeta) ...[
                    const SizedBox(width: 4),
                    const BetaBadge(compact: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.id, required this.active});

  final AppTab id;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? kNavy : kMute2;
    final icon = switch (id) {
      AppTab.ble => Icons.bluetooth,
      AppTab.sms => active ? Icons.chat_bubble : Icons.chat_bubble_outline,
      AppTab.settings => active ? Icons.settings : Icons.settings_outlined,
    };
    return Icon(icon, size: 24, color: color);
  }
}
