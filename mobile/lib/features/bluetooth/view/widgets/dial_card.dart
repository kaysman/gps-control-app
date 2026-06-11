import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/features/bluetooth/view/widgets/dial_button.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The hero card on the connected screen: tracker name, lock status pill,
/// dial + central tap target, battery/cover/updated stats, and an optional
/// toast or error banner.
class DialCard extends StatelessWidget {
  const DialCard({
    super.key,
    required this.tracker,
    required this.status,
    required this.isLocked,
    required this.busy,
    required this.refreshBusy,
    required this.arcAnim,
    required this.spinCtrl,
    required this.toast,
    required this.commandError,
    required this.onToggle,
  });

  final DiscoveredTracker tracker;
  final LegacyStatus? status;
  final bool? isLocked;
  final bool busy;
  final bool refreshBusy;
  final Animation<double> arcAnim;
  final AnimationController spinCtrl;
  final String? toast;
  final String? commandError;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final locked = isLocked ?? true;
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: locked ? kNavyInk : kNavy,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Stack(
        children: [
          Column(
            children: [
              // Name row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tracker.advName.isNotEmpty
                        ? tracker.advName
                        : tracker.deviceId,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (isLocked != null)
                    _StatusPill(locked: isLocked!)
                  else
                    _StatusPill(locked: true, label: l10n.bleStatusFetching),
                ],
              ),
              // Dial
              SizedBox(
                height: 240,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: arcAnim,
                        builder: (_, _) => CustomPaint(
                          size: const Size(240, 240),
                          painter: DialPainter(progress: arcAnim.value),
                        ),
                      ),
                      DialButton(
                        isLocked: isLocked,
                        busy: busy,
                        spinCtrl: spinCtrl,
                        onTap: onToggle,
                      ),
                    ],
                  ),
                ),
              ),
              // Status strip
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0x141C3D5E)),
                  ),
                ),
                child: Row(
                  children: [
                    _StatCell(
                      label: l10n.bleStatBattery,
                      value: status != null
                          ? '${status!.batteryPct}%'
                          : l10n.bleStatPending,
                      warn: status != null && status!.batteryPct <= 25,
                    ),
                    _StatCell(
                      label: l10n.bleStatCover,
                      value: status == null
                          ? l10n.bleStatPending
                          : (status!.isCoverOpen
                                ? l10n.bleStatCoverOpen
                                : l10n.bleStatCoverClosed),
                      warn: status?.isCoverOpen ?? false,
                    ),
                    _StatCell(
                      label: l10n.bleStatUpdated,
                      value: refreshBusy
                          ? l10n.bleStatBusy
                          : l10n.bleStatUpdatedJustNow,
                      last: true,
                    ),
                  ],
                ),
              ),
              // Toast or command error
              if (toast != null) ...[
                const SizedBox(height: 12),
                _Toast(message: toast!),
              ] else if (commandError != null) ...[
                const SizedBox(height: 12),
                _ErrorToast(message: commandError!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.locked, this.label});

  final bool locked;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: locked
            ? kNavy.withValues(alpha: 0.6)
            : kOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: locked
              ? kWhite.withValues(alpha: 0.15)
              : kOrange.withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        label ??
            (locked
                ? context.l10n.bleStatusSealed
                : context.l10n.bleStatusOpen),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: locked ? kMute2 : kOrangeD,
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.warn = false,
    this.last = false,
  });

  final String label;
  final String value;
  final bool warn;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: last
                ? BorderSide.none
                : const BorderSide(color: Color(0x14FFFFFF)),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: kMute2,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: warn ? kOrange : kWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: kNavy),
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorToast extends StatelessWidget {
  const _ErrorToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kBad.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBad.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: kBad),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kBad,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
