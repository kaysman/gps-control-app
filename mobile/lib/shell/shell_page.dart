import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/l10n/l10n.dart';

/// The shell's three top-level destinations.
enum AppTab { ble, sms, settings }

class ShellPage extends StatelessWidget {
  const ShellPage({
    required this.shell,
    super.key,
  });

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(
        children: [
          Positioned.fill(
            // StatefulShellRoute.indexedStack keeps every branch mounted, so
            // the BluetoothBloc (and any active BLE connection) survives tab
            // switches. The shell itself is the widget that renders them.
            child: shell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // AppTab is declared in the same order as the router's branches,
            // so its index doubles as the shell's branch index.
            child: _BottomTabBar(
              tab: AppTab.values[shell.currentIndex],
              onTab: (t) => shell.goBranch(t.index),
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
    // Floats clear of the bottom edge instead of sitting in a full-width
    // chrome bar: the ink pill reads as one object over any page behind it,
    // dark radar screen included.
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 10 + bottomPad),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kInkDeep,
          borderRadius: BorderRadius.circular(kR30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33070E0B),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
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
        ),
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
    // Active tab fills with green and switches to ink; inactive stays a quiet
    // white so only one destination ever reads as selected.
    final fg = active ? kInk : kWhite.withValues(alpha: 0.62);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          // 44pt minimum touch height, kept by the padding below.
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(kR22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabIcon(id: id, color: fg, active: active),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: kSans,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      color: fg,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (showBeta) ...[
                    const SizedBox(width: 4),
                    _TabBetaDot(active: active),
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

/// The SMS tab is still beta. A full pill does not fit inside a tab, so the
/// flag shrinks to a dot here — the pill itself still appears on the page.
class _TabBetaDot extends StatelessWidget {
  const _TabBetaDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: active ? kInk : kLime,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.id, required this.color, required this.active});

  final AppTab id;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final icon = switch (id) {
      AppTab.ble => active ? Icons.bluetooth : Icons.bluetooth_outlined,
      AppTab.sms => active ? Icons.chat_bubble : Icons.chat_bubble_outline,
      AppTab.settings => active ? Icons.settings : Icons.settings_outlined,
    };
    return Icon(icon, size: 22, color: color);
  }
}
