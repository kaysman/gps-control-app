import 'package:gps_control/app/tokens.dart';
import 'package:flutter/material.dart';

/// Small "BETA" pill used to flag work-in-progress areas of the app.
class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key, this.compact = false});

  /// When true, renders a tighter version suitable for the bottom tab bar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: kOrange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kOrange.withValues(alpha: 0.4)),
      ),
      child: Text(
        'BETA',
        style: TextStyle(
          fontFamily: kMono,
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w800,
          color: kOrangeD,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
