import 'package:gps_control/models/chat_message.dart';
import 'package:flutter/foundation.dart';

/// One SMS received from a tracker.
@immutable
class IncomingSms {
  /// Creates an [IncomingSms].
  const IncomingSms({required this.from, required this.body});

  /// Phone number of the sending SIM.
  final String from;

  /// Message text as the tracker sent it.
  final String body;
}

/// The app's source of truth for the SMS conversation with the trackers.
///
/// Callers send text and listen for replies; whether that goes through the
/// telephony stack or a canned device is not their concern.
abstract interface class SmsRepository {
  /// Grants the permissions and registers the receiver. Returns whether SMS is
  /// usable. Safe to call repeatedly.
  Future<bool> ensureReady();

  /// Replies arriving from trackers while the app is in the foreground.
  Stream<IncomingSms> get incoming;

  /// The conversation so far, restored when the screen opens.
  Future<List<ChatMessage>> loadHistory();

  /// Tracker ids that were selected as recipients last time.
  Future<Set<String>> loadRecipientSelection();

  /// Sends [body] to [to], returning whether the platform confirmed it.
  ///
  /// [subscriptionId] picks the sending SIM; `-1` leaves it to the system
  /// default.
  Future<bool> send({
    required String to,
    required String body,
    int subscriptionId,
  });
}
