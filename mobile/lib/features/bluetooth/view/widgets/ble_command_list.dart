import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Stacked list of BLE actions: unlock, lock, refresh, disconnect.
class BleCommandList extends StatelessWidget {
  const BleCommandList({
    required this.isLocked,
    required this.refreshBusy,
    required this.onUnlock,
    required this.onLock,
    required this.onRefresh,
    required this.onDisconnect,
    super.key,
  });

  final bool? isLocked;
  final bool refreshBusy;
  final VoidCallback onUnlock;
  final VoidCallback onLock;
  final VoidCallback onRefresh;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kRule),
      ),
      child: Column(
        children: [
          _BleRow(
            label: l10n.bleCmdUnlock,
            sub: l10n.bleCmdUnlockSub,
            iconData: Icons.lock_open_outlined,
            onTap: onUnlock,
          ),
          const Divider(height: 1, color: kRule),
          _BleRow(
            label: l10n.bleCmdLock,
            sub: l10n.bleCmdLockSub,
            iconData: Icons.lock_outlined,
            onTap: onLock,
          ),
          const Divider(height: 1, color: kRule),
          _BleRow(
            label: l10n.bleCmdRefresh,
            sub: l10n.bleCmdRefreshSub,
            iconData: Icons.refresh,
            busy: refreshBusy,
            onTap: onRefresh,
          ),
          const Divider(height: 1, color: kRule),
          _BleRow(
            label: l10n.bleCmdDisconnect,
            sub: l10n.bleCmdDisconnectSub,
            iconData: Icons.bluetooth_disabled,
            onTap: onDisconnect,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _BleRow extends StatelessWidget {
  const _BleRow({
    required this.label,
    required this.sub,
    required this.iconData,
    required this.onTap,
    this.busy = false,
    this.last = false,
  });

  final String label;
  final String sub;
  final IconData iconData;
  final bool busy;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kBone,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, size: 18, color: kNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 12,
                      color: kMute,
                    ),
                  ),
                ],
              ),
            ),
            if (!busy)
              const Icon(Icons.chevron_right, size: 18, color: kMute2)
            else
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kNavy,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
