import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/features/sms/cubit/conversation_cubit.dart';
import 'package:gps_control/features/sms/sms_command_labels.dart';
import 'package:gps_control/features/sms/sms_thread.dart';
import 'package:gps_control/features/sms/tracker_search.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

/// The SMS tab: one row per tracker, newest word first. Tapping a row opens
/// that tracker's chat.
class SmsThreadsPage extends StatefulWidget {
  /// Creates the thread list.
  const SmsThreadsPage({super.key});

  @override
  State<SmsThreadsPage> createState() => _SmsThreadsPageState();
}

class _SmsThreadsPageState extends State<SmsThreadsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Restoring is what asks for the SMS permissions, so SIM enumeration —
  /// which needs READ_PHONE_STATE from the same grant — retries afterwards.
  Future<void> _restore() async {
    await context.read<ConversationCubit>().restore();
    if (!mounted) return;
    unawaited(context.read<SimCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    final history = context.watch<ConversationCubit>().state.messages;
    final visible = searchTrackers(smsTrackers, _query);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.smsThreadsTitle,
                  style: const TextStyle(
                    fontFamily: kSans,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -1.4,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _SearchField(
              controller: _searchCtrl,
              onChanged: (q) => setState(() => _query = q),
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
            child: visible.isEmpty
                ? _NoMatches(query: _query)
                : Column(
                    children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        if (i > 0)
                          const Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Divider(height: 1, color: kRule),
                          ),
                        _ThreadRow(
                          tracker: visible[i],
                          last: lastMessageFor(history, visible[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Filters the fleet as you type. No submit button and no results screen —
/// the list below *is* the result.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontFamily: kSans,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: kInk,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: context.l10n.smsSearchHint,
        hintStyle: const TextStyle(
          fontFamily: kSans,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: kMute2,
        ),
        prefixIcon: const Icon(Icons.search, size: 20, color: kMute),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.close, size: 18, color: kMute),
                  ),
                ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: kWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kR22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kR22),
          borderSide: const BorderSide(color: kGreen, width: 2),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Row(
        children: [
          const Icon(Icons.search_off, size: 20, color: kMute2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${context.l10n.smsSearchEmpty} \u201C$query\u201D',
              style: const TextStyle(
                fontFamily: kSans,
                fontSize: 13.5,
                color: kMute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.tracker, required this.last});

  final MockTracker tracker;
  final ChatMessage? last;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/sms/${tracker.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tracker.short,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _preview(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: last is ReceivedChatMessage ? kTech : kSans,
                      fontSize: 12,
                      color: last == null ? kMute2 : kMute,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (last != null)
              Text(
                _clock(last!.timestamp),
                style: const TextStyle(
                  fontFamily: kTech,
                  fontSize: 10.5,
                  color: kMute2,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: kMute2),
          ],
        ),
      ),
    );
  }

  String _preview(AppLocalizations l10n) => switch (last) {
    null => l10n.smsThreadEmpty,
    final SentChatMessage m =>
      '${l10n.smsThreadYou}: ${smsCommandName(l10n, m.commandId)}',
    final ReceivedChatMessage m => m.body,
  };

  static String _clock(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
