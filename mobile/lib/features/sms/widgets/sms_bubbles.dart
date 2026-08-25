import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sms/sms_command_labels.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

class SmsEmptyConversation extends StatelessWidget {
  const SmsEmptyConversation({required this.onPickCommand, super.key});
  final VoidCallback onPickCommand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 40, color: kMute2),
          const SizedBox(height: 12),
          Text(
            l10n.smsEmptyTitle,
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kMute,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.smsEmptySub,
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 12,
              color: kMute2,
            ),
          ),
        ],
      ),
    );
  }
}

class SmsSentBubble extends StatelessWidget {
  const SmsSentBubble({required this.msg, required this.showDate, super.key});
  final SentChatMessage msg;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final commandLabel = smsCommandName(l10n, msg.commandId);
    final valueLabel = msg.commandValue == null
        ? null
        : smsOptionLabel(l10n, msg.commandValue!);
    return Column(
      children: [
        if (showDate) SmsDateChip(timestamp: msg.timestamp),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.smsBubbleYouTo(msg.recipientShorts.length),
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 10.5,
                    color: kMute,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: kNavy,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: commandLabel,
                          style: const TextStyle(
                            fontFamily: kSans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kWhite,
                          ),
                        ),
                        if (valueLabel != null)
                          TextSpan(
                            text: ' → $valueLabel',
                            style: const TextStyle(
                              fontFamily: kSans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  msg.smsText,
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 9.5,
                    color: kMute2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SmsReceivedBubble extends StatelessWidget {
  const SmsReceivedBubble({
    required this.msg,
    required this.showDate,
    super.key,
  });
  final ReceivedChatMessage msg;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDate) SmsDateChip(timestamp: msg.timestamp),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.from,
                  style: const TextStyle(
                    fontFamily: kMono,
                    fontSize: 10.5,
                    color: kMute,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: kRule),
                  ),
                  child: Text(
                    msg.body,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SmsDateChip extends StatelessWidget {
  const SmsDateChip({required this.timestamp, super.key});
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = timestamp;
    final now = DateTime.now();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final label =
        (d.year == now.year && d.month == now.month && d.day == now.day)
        ? l10n.smsDateToday(hh, mm)
        : l10n.smsDateFull(
            d.day.toString().padLeft(2, '0'),
            d.month.toString().padLeft(2, '0'),
            d.year.toString(),
            hh,
            mm,
          );
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: kBone,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kMono,
            fontSize: 10.5,
            color: kMute,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class SmsRecipientChip extends StatelessWidget {
  const SmsRecipientChip({
    required this.tracker,
    required this.onRemove,
    super.key,
  });
  final MockTracker tracker;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kRule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(tracker.tone),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            tracker.short,
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: kNavy,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              color: Colors.transparent,
              child: const Icon(Icons.close, size: 13, color: kMute),
            ),
          ),
        ],
      ),
    );
  }
}
