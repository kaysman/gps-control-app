import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/features/sms/sms_command_text.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

/// The whole SMS conversation with the fleet, flat.
@immutable
class ConversationState {
  /// Creates a [ConversationState].
  const ConversationState({this.messages = const [], this.ready = false});

  /// Every message, in arrival order, across every tracker.
  final List<ChatMessage> messages;

  /// Whether the platform granted SMS and the receiver is registered.
  final bool ready;

  /// Returns a copy with the given fields replaced.
  ConversationState copyWith({List<ChatMessage>? messages, bool? ready}) {
    return ConversationState(
      messages: messages ?? this.messages,
      ready: ready ?? this.ready,
    );
  }
}

/// Owns the conversation for the whole app.
///
/// It sits above the routes on purpose: the thread list and an open chat are
/// two views of one conversation, so a reply that arrives while a chat is open
/// has to move the list's preview too. Two screens each holding their own
/// message list could not do that.
class ConversationCubit extends Cubit<ConversationState> {
  /// Creates a [ConversationCubit] reading and writing through [_sms].
  ConversationCubit(this._sms) : super(const ConversationState());

  final SmsRepository _sms;
  StreamSubscription<IncomingSms>? _sub;

  /// Loads the stored conversation, then opens the line for new replies.
  ///
  /// Safe to call again: the subscription is only ever opened once.
  Future<void> restore() async {
    final history = await _sms.loadHistory();
    if (isClosed) return;
    if (history.isNotEmpty) emit(state.copyWith(messages: history));

    final ready = await _sms.ensureReady();
    debugPrint('[ConversationCubit] restore: sms ready=$ready');
    if (isClosed || !ready) return;
    _sub ??= _sms.incoming.listen(_onIncoming);
    emit(state.copyWith(ready: true));
  }

  void _onIncoming(IncomingSms msg) {
    debugPrint('[ConversationCubit] incoming from=${msg.from}');
    if (isClosed) return;
    _append(
      ReceivedChatMessage(
        timestamp: DateTime.now(),
        from: msg.from,
        body: msg.body,
      ),
    );
  }

  /// Sends [cmd] to [tracker] and returns whether the platform confirmed it.
  ///
  /// The message appears in the thread before the send resolves — the user
  /// asked for it, so the conversation should show it. A failure surfaces to
  /// the caller, which is the screen that can put it in front of the user.
  Future<bool> send({
    required MockTracker tracker,
    required SmsCommand cmd,
    required String password,
    required int subscriptionId,
    Object? value,
  }) async {
    final text = buildSmsText(cmd, password, value);
    debugPrint(
      '[ConversationCubit] send: cmd=${cmd.id} value=$value '
      'to=${tracker.short}(${tracker.phone}) subId=$subscriptionId',
    );
    _append(
      SentChatMessage(
        timestamp: DateTime.now(),
        recipientShorts: [tracker.short],
        commandId: cmd.id,
        commandValue: value?.toString(),
        smsText: text,
      ),
    );
    return _sms.send(
      to: tracker.phone,
      body: text,
      subscriptionId: subscriptionId,
    );
  }

  void _append(ChatMessage msg) {
    emit(state.copyWith(messages: [...state.messages, msg]));
  }

  @override
  Future<void> close() {
    _sub?.cancel().ignore();
    return super.close();
  }
}
