import 'dart:async';

import 'package:another_telephony/telephony.dart';
import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/app/widgets/beta_badge.dart';
import 'package:bariox_control/features/sim/cubit/sim_cubit.dart';
import 'package:bariox_control/features/sms/widgets/command_picker_sheet.dart';
import 'package:bariox_control/features/sms/widgets/compose_dock.dart';
import 'package:bariox_control/features/sms/widgets/sms_bubbles.dart';
import 'package:bariox_control/features/sms/widgets/tracker_picker_sheet.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:bariox_control/mock/mock_data.dart';
import 'package:bariox_control/models/chat_message.dart';
import 'package:bariox_control/services/sms_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

String _buildSmsText(SmsCommand cmd, String pw, Object? value) {
  final p = pw.isEmpty ? '000000' : pw;
  if (cmd.id == 'sensor') {
    final level = value == 'low'
        ? 1
        : value == 'high'
        ? 3
        : 2;
    return '#$p,STPF:SENSORVAL,$level';
  }
  return switch (cmd.id) {
    'battery' => '#$p,RDBL',
    'status' => '#$p,RDLS',
    'position' => '#$p,RDLO',
    'rfid' => '#$p,RDRF',
    'subs' => '#$p,SLRA',
    'fw' => '#$p,RDVE',
    'sleep' => '#$p,STPF:SLEEPEN,${(value as bool? ?? true) ? 1 : 0}',
    'interval' => '#$p,STIN:$value',
    'autolock' => '#$p,STPF:CTIME,$value',
    'addrfid' => '#$p,STRF:1,$value',
    'addphone' => '#$p,STPN:1,$value',
    'pwd' => '(P44,$value,$p)',
    'unlock' || 'lock' => '(P43,$p)',
    'reboot' => '#$p,REST',
    'clear' => '#$p,CLRD',
    'reset' => '#$p,INIT:INIT-SYS',
    _ => '#$p,${cmd.id.toUpperCase()}',
  };
}

class SmsPage extends StatefulWidget {
  const SmsPage({super.key});

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  final _recipients = <String>{};
  static const _maxVisible = 5;

  final _trackerPasswords = <String, String>{};
  String _password = '000000';

  final _messages = <ChatMessage>[];
  final _scrollCtrl = ScrollController();
  StreamSubscription<SmsMessage>? _smsSub;

  @override
  void initState() {
    super.initState();
    _requestAndListen();
  }

  Future<void> _requestAndListen() async {
    debugPrint('[SmsPage] _requestAndListen: requesting permissions');
    final granted = await SmsService.instance.requestPermissions();
    debugPrint(
      '[SmsPage] _requestAndListen: granted=$granted mounted=$mounted',
    );
    if (!granted || !mounted) return;
    SmsService.instance.startListening();
    _smsSub = SmsService.instance.incoming.listen(_onIncoming);
    debugPrint('[SmsPage] _requestAndListen: subscribed to incoming stream');
    // SIM enumeration also needs READ_PHONE_STATE — refresh now that the
    // user has granted it.
    if (mounted) unawaited(context.read<SimCubit>().load());
  }

  void _onIncoming(SmsMessage msg) {
    debugPrint('[SmsPage] _onIncoming: from=${msg.address} body=${msg.body}');
    if (!mounted) return;
    setState(() {
      _messages.add(
        ReceivedChatMessage(
          timestamp: DateTime.now(),
          from: msg.address ?? 'unknown',
          body: msg.body ?? '',
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _smsSub?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _removeRecipient(String id) => setState(() => _recipients.remove(id));

  void _openTrackerPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (_) => SmsTrackerPickerSheet(
        selected: Set.of(_recipients),
        passwords: Map.of(_trackerPasswords),
        onChanged: (sel, passwords) => setState(() {
          _recipients
            ..clear()
            ..addAll(sel);
          _trackerPasswords
            ..clear()
            ..addAll(passwords);
        }),
      ),
    );
  }

  void _openAllRecipients() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsAllRecipientsSheet(
        recipients: _recipients
            .map((id) => smsTrackers.firstWhere((t) => t.id == id))
            .toList(),
        onRemove: (id) => setState(() => _recipients.remove(id)),
      ),
    );
  }

  void _openCommandPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsCommandPickerSheet(
        onPick: (cmd) {
          Navigator.pop(context);
          _showCompose(cmd);
        },
      ),
    );
  }

  void _showCompose(SmsCommand cmd) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsComposeDock(
        cmd: cmd,
        recipientCount: _recipients.length,
        onCancel: () => Navigator.pop(context),
        onSend: (value) {
          Navigator.pop(context);
          _sendCommand(cmd, value);
        },
      ),
    );
  }

  void _sendCommand(SmsCommand cmd, Object? value) {
    final previewText = _buildSmsText(cmd, _password, value);
    final recDevs = _recipients
        .map((id) => smsTrackers.firstWhere((t) => t.id == id))
        .toList();
    final subscriptionId =
        context.read<SimCubit>().state.selectedSubscriptionId ?? -1;

    debugPrint(
      '[SmsPage] _sendCommand: cmd=${cmd.id} value=$value subId=$subscriptionId '
      'recipients=${recDevs.map((t) => '${t.short}(${t.id})').join(',')}',
    );

    setState(() {
      _messages.add(
        SentChatMessage(
          timestamp: DateTime.now(),
          recipientShorts: recDevs.map((t) => t.short).toList(),
          commandId: cmd.id,
          commandValue: value?.toString(),
          smsText: previewText,
        ),
      );
    });
    _scrollToBottom();

    for (final tracker in recDevs) {
      final password = _trackerPasswords[tracker.id]?.trim().isNotEmpty == true
          ? _trackerPasswords[tracker.id]!.trim()
          : _password;
      final smsText = _buildSmsText(cmd, password, value);
      debugPrint(
        '[SmsPage] _sendCommand: → ${tracker.short}(${tracker.id}) '
        'phone=${tracker.phone} smsText=$smsText',
      );
      SmsService.instance.send(
        to: tracker.phone,
        body: smsText,
        subscriptionId: subscriptionId,
        onStatus: (success) {
          if (!mounted) return;
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.smsSendFailed(tracker.short)),
                backgroundColor: kBad,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    final recDevs = _recipients
        .map((id) => smsTrackers.firstWhere((t) => t.id == id))
        .toList();

    return Column(
      children: [
        // Header
        Container(
          color: kWhite,
          padding: EdgeInsets.fromLTRB(18, topPad + 10, 18, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.smsHeader,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: kNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const BetaBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const _ActiveSimChip(),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.smsRecipientCount(recDevs.length),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kOrangeD,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Recipients bar
        Container(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          decoration: BoxDecoration(
            color: kWhite,
            border: Border(bottom: BorderSide(color: kRule)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.smsToLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kMute,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...recDevs
                        .take(_maxVisible)
                        .map(
                          (t) => SmsRecipientChip(
                            tracker: t,
                            onRemove: () => _removeRecipient(t.id),
                          ),
                        ),
                    if (recDevs.length > _maxVisible)
                      GestureDetector(
                        onTap: _openAllRecipients,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kNavy,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.smsOverflowCount(
                              recDevs.length - _maxVisible,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kWhite,
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _openTrackerPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kBone,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: kRuleS),
                        ),
                        child: Text(
                          l10n.smsAddRecipient,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Conversation
        Expanded(
          child: _messages.isEmpty
              ? SmsEmptyConversation(onPickCommand: _openCommandPicker)
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final msg = _messages[i];
                    final showDate =
                        i == 0 ||
                        _messages[i - 1].timestamp.day != msg.timestamp.day;
                    return switch (msg) {
                      SentChatMessage m => SmsSentBubble(
                        msg: m,
                        showDate: showDate,
                      ),
                      ReceivedChatMessage m => SmsReceivedBubble(
                        msg: m,
                        showDate: showDate,
                      ),
                    };
                  },
                ),
        ),

        // Compose bar
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: kWhite,
            border: Border(top: BorderSide(color: kRule)),
          ),
          child: GestureDetector(
            onTap: _openCommandPicker,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: kPaper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kRuleS),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: kOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.smsPickCommand,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 76),
      ],
    );
  }
}

class _ActiveSimChip extends StatelessWidget {
  const _ActiveSimChip();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SimCubit>().state;
    final sim = state.selected;
    final label = sim == null
        ? l10n.smsNoSimChip
        : l10n.smsActiveSimChip(sim.label, sim.slotIndex + 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kBone,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kRuleS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sim_card_outlined, size: 12, color: kMute),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kMute,
            ),
          ),
        ],
      ),
    );
  }
}
