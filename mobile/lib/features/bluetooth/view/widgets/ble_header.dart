import 'package:bariox_control/app/tokens.dart';
import 'package:flutter/material.dart';

/// Header strip used on the connected BLE screen. Shows the back chevron when
/// [onBack] is provided and the [title] (tracker name or "Bluetooth" by
/// default).
class BleHeader extends StatelessWidget {
  const BleHeader({
    super.key,
    this.title = 'Bluetooth',
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(onBack != null ? 8 : 18, 10, 18, 14),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 6, 10, 6),
                child: Icon(Icons.chevron_left, size: 26, color: kNavy),
              ),
            ),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kSans,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kNavy,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
