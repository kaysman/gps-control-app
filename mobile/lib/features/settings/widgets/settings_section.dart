import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';

/// A labelled group of settings rows drawn as one rounded card.
class SettingsSection extends StatelessWidget {
  /// Creates a section titled [title] wrapping [children].
  const SettingsSection({
    required this.title,
    required this.children,
    this.action,
    super.key,
  });

  /// Small all-caps heading above the card.
  final String title;

  /// Rows inside the card. Dividers are inserted between them.
  final List<Widget> children;

  /// Optional trailing control on the heading row (e.g. a refresh button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: kMute,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              ?action,
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(kR22),
            boxShadow: const [
              BoxShadow(color: kShadow, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(children: _withDividers(children)),
        ),
      ],
    );
  }

  static List<Widget> _withDividers(List<Widget> rows) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        out.add(
          const Padding(
            padding: EdgeInsets.only(left: 62),
            child: Divider(height: 1, color: kRule),
          ),
        );
      }
      out.add(rows[i]);
    }
    return out;
  }
}

/// A tappable "chip · label · value ›" row inside a [SettingsSection].
class SettingsRow extends StatelessWidget {
  /// Creates a row labelled [label] showing [value] on the right.
  const SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  /// Glyph for the leading chip.
  final IconData icon;

  /// What the row configures.
  final String label;

  /// The current setting. Rendered as data — heavier than the label's own
  /// weight would suggest — because it is what the user came to read.
  final String value;

  /// Opens the row's picker.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        // 44pt minimum touch height.
        padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: kGreenWash,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 19, color: kGreenDeep),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: kMute,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: kMute2),
          ],
        ),
      ),
    );
  }
}
