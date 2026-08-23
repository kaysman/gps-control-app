import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sms/sms_command_labels.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:flutter/material.dart';

class SmsCommandPickerSheet extends StatelessWidget {
  const SmsCommandPickerSheet({super.key, required this.onPick});
  final ValueChanged<SmsCommand> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grouped = {
      CmdGroup.read: allCommands
          .where((c) => c.group == CmdGroup.read)
          .toList(),
      CmdGroup.set: allCommands.where((c) => c.group == CmdGroup.set).toList(),
      CmdGroup.action: allCommands
          .where((c) => c.group == CmdGroup.action)
          .toList(),
    };
    final labels = {
      CmdGroup.read: l10n.commandGroupRead,
      CmdGroup.set: l10n.commandGroupSet,
      CmdGroup.action: l10n.commandGroupAction,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: kPaper,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kRuleS,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.commandPickerHeading,
                        style: TextStyle(
                          fontFamily: kMono,
                          fontSize: 10.5,
                          color: kMute,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.commandPickerTitle,
                        style: TextStyle(
                          fontFamily: kSans,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kNavy,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: kBone,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: kNavy),
                    ),
                  ),
                ],
              ),
            ),
            ...grouped.entries.map((entry) {
              final group = entry.key;
              final list = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
                    child: Row(
                      children: [
                        Text(
                          labels[group]!,
                          style: TextStyle(
                            fontFamily: kSans,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kMute,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (group == CmdGroup.set) ...[
                          const SizedBox(width: 6),
                          Text(
                            l10n.commandGroupSetNeedsInput,
                            style: TextStyle(
                              fontFamily: kSans,
                              fontSize: 11,
                              color: kOrangeD,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kRule),
                    ),
                    child: Column(
                      children: list.asMap().entries.map((e) {
                        final i = e.key;
                        final cmd = e.value;
                        final iconBg = group == CmdGroup.read
                            ? kBone
                            : group == CmdGroup.set
                            ? kOrange.withValues(alpha: 0.14)
                            : cmd.danger
                            ? kBad.withValues(alpha: 0.10)
                            : kOk.withValues(alpha: 0.10);
                        final sub = smsCommandSub(l10n, cmd.id);
                        return GestureDetector(
                          onTap: () => onPick(cmd),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: i == list.length - 1
                                    ? BorderSide.none
                                    : BorderSide(color: kRule),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      group == CmdGroup.read
                                          ? '↓'
                                          : group == CmdGroup.set
                                          ? '⇄'
                                          : '!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: cmd.danger ? kBad : kNavy,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        smsCommandName(l10n, cmd.id),
                                        style: TextStyle(
                                          fontFamily: kSans,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: cmd.danger ? kBad : kNavy,
                                        ),
                                      ),
                                      if (sub.isNotEmpty)
                                        Text(
                                          sub,
                                          style: TextStyle(
                                            fontFamily: kSans,
                                            fontSize: 11.5,
                                            color: kMute,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (cmd.input != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kOrange.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      l10n.commandPickerInputBadge,
                                      style: TextStyle(
                                        fontFamily: kSans,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: kOrangeD,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: kMute2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
