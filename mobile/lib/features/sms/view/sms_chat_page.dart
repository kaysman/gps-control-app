import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/features/sms/cubit/conversation_cubit.dart';
import 'package:gps_control/features/sms/cubit/tracker_password_cubit.dart';
import 'package:gps_control/features/sms/sms_thread.dart';
import 'package:gps_control/features/sms/widgets/command_picker_sheet.dart';
import 'package:gps_control/features/sms/widgets/compose_dock.dart';
import 'package:gps_control/features/sms/widgets/password_sheet.dart';
import 'package:gps_control/features/sms/widgets/sms_bubbles.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

/// One tracker's conversation, pushed over the shell so the chat gets the
/// whole screen.
///
// TODO(recipients): one tracker per chat for now. Broadcasting to several at
// once is a thread-list level action, not something the "To:" line should
// grow back into.
class SmsChatPage extends StatefulWidget {
  /// Creates the chat for the tracker with id [trackerId].
  const SmsChatPage({required this.trackerId, super.key});

  /// Serial of the tracker this chat talks to.
  final String trackerId;

  @override
  State<SmsChatPage> createState() => _SmsChatPageState();
}

class _SmsChatPageState extends State<SmsChatPage> {
  final _scrollCtrl = ScrollController();
  late final MockTracker _tracker;
  int _seen = 0;

  @override
  void initState() {
    super.initState();
    _tracker = smsTrackers.firstWhere(
      (t) => t.id == widget.trackerId,
      orElse: () => smsTrackers.first,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        unawaited(
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  void _openCommandPicker() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) => SmsCommandPickerSheet(
          onPick: (cmd) {
            Navigator.pop(sheetCtx);
            _showCompose(cmd);
          },
        ),
      ),
    );
  }

  void _showCompose(SmsCommand cmd) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) => SmsComposeDock(
          cmd: cmd,
          onCancel: () => Navigator.pop(sheetCtx),
          onSend: (value) {
            Navigator.pop(sheetCtx);
            unawaited(_send(cmd, value));
          },
        ),
      ),
    );
  }

  Future<void> _send(SmsCommand cmd, Object? value) async {
    final sent = await context.read<ConversationCubit>().send(
      tracker: _tracker,
      cmd: cmd,
      value: value,
      password: context.read<TrackerPasswordCubit>().passwordFor(_tracker.id),
      subscriptionId:
          context.read<SimCubit>().state.selectedSubscriptionId ?? -1,
    );
    if (sent || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.smsSendFailed(_tracker.short)),
        backgroundColor: kBad,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = context.watch<ConversationCubit>().state.messages;
    final thread = threadFor(history, _tracker);
    // Any message added while this chat is open should bring itself into view.
    if (thread.length != _seen) {
      _seen = thread.length;
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: kCanvas,
      body: Column(
        children: [
          _ChatHeader(tracker: _tracker),
          Expanded(
            child: thread.isEmpty
                ? SmsEmptyConversation(onPickCommand: _openCommandPicker)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                    itemCount: thread.length,
                    itemBuilder: (_, i) {
                      final msg = thread[i];
                      final showDate =
                          i == 0 ||
                          thread[i - 1].timestamp.day != msg.timestamp.day;
                      return switch (msg) {
                        final SentChatMessage m => SmsSentBubble(
                          msg: m,
                          showDate: showDate,
                        ),
                        final ReceivedChatMessage m => SmsReceivedBubble(
                          msg: m,
                          showDate: showDate,
                        ),
                      };
                    },
                  ),
          ),
          // The one primary action on this screen, so the one ink-filled pill.
          Container(
            padding: EdgeInsets.fromLTRB(
              14,
              12,
              14,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border(top: BorderSide(color: kRule)),
            ),
            child: GestureDetector(
              onTap: _openCommandPicker,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 20, 6),
                decoration: BoxDecoration(
                  color: kInk,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: kShadow,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: kLime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 20, color: kInk),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.smsPickCommand,
                      style: const TextStyle(
                        fontFamily: kSans,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: kWhite,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Back, who you are talking to, and the password that goes with every
/// command sent from here.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.tracker});

  final MockTracker tracker;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topPad = MediaQuery.of(context).padding.top;
    final custom = context.watch<TrackerPasswordCubit>().state.containsKey(
      tracker.id,
    );

    return Container(
      color: kWhite,
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 12, 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: Navigator.of(context).pop,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left, size: 28, color: kInk),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tracker.short,
                  style: const TextStyle(
                    fontFamily: kSans,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${l10n.smsToLabel} ${tracker.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kTech,
                    fontSize: 11,
                    color: kMute,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openPasswordSheet(context: context, tracker: tracker),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: custom ? kGreen : kGreenWash,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key_outlined,
                    size: 17,
                    color: custom ? kInk : kGreenDeep,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
