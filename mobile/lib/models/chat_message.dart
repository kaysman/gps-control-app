sealed class ChatMessage {
  DateTime get timestamp;
}

final class SentChatMessage extends ChatMessage {
  SentChatMessage({
    required this.timestamp,
    required this.recipientShorts,
    required this.commandId,
    this.commandValue,
    required this.smsText,
  });

  @override
  final DateTime timestamp;
  final List<String> recipientShorts;

  /// Identifier of the command (see SmsCommand.id). Display strings are
  /// resolved at render time so they re-localize on locale changes.
  final String commandId;

  /// Identifier of the chosen value (e.g. 'low' for segmented, '30' for
  /// duration, 'on'/'off' for toggles). Same re-localization rationale.
  final String? commandValue;
  final String smsText;
}

final class ReceivedChatMessage extends ChatMessage {
  ReceivedChatMessage({
    required this.timestamp,
    required this.from,
    required this.body,
  });

  @override
  final DateTime timestamp;

  /// Phone number of the sending SIM (the tracker).
  final String from;
  final String body;
}
