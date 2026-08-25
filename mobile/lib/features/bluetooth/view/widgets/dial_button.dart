import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Big circular tap target at the centre of the dial: shows "Tap to unlock"
/// / "Tap to lock" / "Tap to refresh" depending on [isLocked] and busy state.
class DialButton extends StatelessWidget {
  const DialButton({
    required this.isLocked,
    required this.busy,
    required this.spinCtrl,
    required this.onTap,
    super.key,
  });

  /// null = unknown (still fetching status), true = locked, false = unlocked.
  final bool? isLocked;
  final bool busy;
  final AnimationController spinCtrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = isLocked ?? true;
    final bg = busy ? kOrange : (locked ? kWhite : kOrange);
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 168,
        height: 168,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: locked
                  ? Colors.black.withValues(alpha: 0.30)
                  : kOrange.withValues(alpha: 0.50),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy) ...[
                _BusyRing(spinCtrl: spinCtrl),
                const SizedBox(height: 6),
                _DialLabel(text: l10n.bleSending, large: false),
              ] else if (isLocked == null) ...[
                const Icon(Icons.sync, size: 28, color: kNavy),
                const SizedBox(height: 6),
                _DialLabel(text: l10n.bleTapToRefresh),
              ] else ...[
                Icon(
                  locked ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: 28,
                  color: kNavy,
                ),
                const SizedBox(height: 6),
                _DialLabel(
                  text: locked ? l10n.bleTapToUnlock : l10n.bleTapToLock,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialLabel extends StatelessWidget {
  const _DialLabel({required this.text, this.large = true});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kSans,
        fontWeight: FontWeight.w700,
        fontSize: large ? 15 : 13,
        color: kNavy,
        letterSpacing: 0.3,
        height: 1.15,
      ),
    );
  }
}

class _BusyRing extends StatelessWidget {
  const _BusyRing({required this.spinCtrl});

  final AnimationController spinCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spinCtrl,
      builder: (_, _) => Transform.rotate(
        angle: spinCtrl.value * math.pi * 2,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kNavy, width: 2.5),
          ),
          child: const ClipOval(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 12,
                child: ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter for the surrounding tick ring + progress arc.
class DialPainter extends CustomPainter {
  const DialPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const outerR = 108.0;
    const tickIn = 92.0;
    const tickOut = 100.0;

    final ghostPaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), outerR, ghostPaint);

    final tickPaint = Paint()
      ..color = const Color(0x29FFFFFF)
      ..strokeWidth = 1;
    for (var i = 0; i < 36; i++) {
      final angle = (i / 36) * math.pi * 2;
      final x1 = cx + math.cos(angle) * tickIn;
      final y1 = cy + math.sin(angle) * tickIn;
      final x2 = cx + math.cos(angle) * tickOut;
      final y2 = cy + math.sin(angle) * tickOut;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    final sweepAngle = progress * math.pi * 2;
    final arcPaint = Paint()
      ..color = kOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(DialPainter old) => old.progress != progress;
}
