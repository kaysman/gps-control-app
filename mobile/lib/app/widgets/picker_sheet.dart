import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';

/// Opens [builder] as a settings picker.
///
/// `useRootNavigator` is the point of this helper: the shell stacks its bottom
/// tab bar *over* the branch navigator, so a sheet pushed onto that navigator
/// comes up underneath the tab bar. Pushing onto the root navigator puts the
/// sheet above everything, tab bar included.
Future<T?> showPickerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    ),
    builder: builder,
  );
}

/// Fire-and-forget [showPickerSheet], for `onTap` callbacks.
void openPickerSheet({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  unawaited(showPickerSheet<void>(context: context, builder: builder));
}

/// The shared chrome every settings picker wears: grabber, title, optional
/// subtitle and heading action, then a card of [children].
class PickerSheet extends StatelessWidget {
  /// Creates a picker sheet titled [title].
  const PickerSheet({
    required this.title,
    required this.children,
    this.subtitle,
    this.action,
    super.key,
  });

  /// Sheet heading.
  final String title;

  /// One line of context under [title].
  final String? subtitle;

  /// Optional control on the heading row (e.g. a refresh button).
  final Widget? action;

  /// Option rows. Dividers are inserted between them.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: kCanvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kR30)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kRuleS,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 18, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: kSans,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                          letterSpacing: -1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontFamily: kSans,
                            fontSize: 12.5,
                            color: kMute,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) ...[const SizedBox(width: 10), action!],
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(kR22),
                  boxShadow: const [
                    BoxShadow(
                      color: kShadow,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(children: _withDividers(children)),
              ),
            ),
          ),
        ],
      ),
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

/// One selectable option inside a [PickerSheet].
class PickerRow extends StatelessWidget {
  /// Creates an option labelled [label].
  const PickerRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.mono,
    super.key,
  });

  /// The option's name.
  final String label;

  /// Whether this option is the active one.
  final bool selected;

  /// Picks this option.
  final VoidCallback onTap;

  /// Optional leading glyph.
  final IconData? icon;

  /// Optional supporting line under [label].
  final String? subtitle;

  /// Optional monospaced third line — phone numbers and the like.
  final String? mono;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? kGreenWash.withValues(alpha: 0.55) : null,
          borderRadius: BorderRadius.circular(kR22),
        ),
        padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? kGreen : kGreenWash,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? kInk : kGreenDeep,
                ),
              ),
              const SizedBox(width: 12),
            ],
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
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: kSans,
                        fontSize: 11.5,
                        color: kMute,
                      ),
                    ),
                  if (mono != null)
                    Text(
                      mono!,
                      style: const TextStyle(
                        fontFamily: kMono,
                        fontSize: 11,
                        color: kMute2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: kGreenDeep),
          ],
        ),
      ),
    );
  }
}

/// The small all-caps text button used for a [PickerSheet] heading action.
class PickerSheetAction extends StatelessWidget {
  /// Creates an action labelled [label].
  const PickerSheetAction({
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Button text.
  final String label;

  /// Tap handler.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kSans,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kGreenDeep,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
