import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

/// The subset of [history] that belongs to [tracker]'s thread.
///
/// The conversation is stored flat — one list for the whole fleet — because
/// that is how it arrives: sends name their recipients, replies name their
/// sender. Threading is a read-time concern, so it lives here rather than in
/// the store.
List<ChatMessage> threadFor(List<ChatMessage> history, MockTracker tracker) {
  return [
    for (final msg in history)
      if (switch (msg) {
        final SentChatMessage m => m.recipientShorts.contains(tracker.short),
        final ReceivedChatMessage m => samePhone(m.from, tracker.phone),
      })
        msg,
  ];
}

/// The most recent message in [tracker]'s thread, or null if it has none.
ChatMessage? lastMessageFor(List<ChatMessage> history, MockTracker tracker) {
  ChatMessage? last;
  for (final msg in threadFor(history, tracker)) {
    if (last == null || msg.timestamp.isAfter(last.timestamp)) last = msg;
  }
  return last;
}

/// Whether two numbers reach the same SIM.
///
/// Compares the last nine digits: a tracker's reply can arrive with or without
/// the country code, spaces, or a leading `+`, and all of those are the same
/// phone.
bool samePhone(String a, String b) {
  final x = _digits(a);
  final y = _digits(b);
  if (x.isEmpty || y.isEmpty) return false;
  final n = [9, x.length, y.length].reduce((p, q) => p < q ? p : q);
  return x.substring(x.length - n) == y.substring(y.length - n);
}

String _digits(String s) => s.replaceAll(RegExp('[^0-9]'), '');
