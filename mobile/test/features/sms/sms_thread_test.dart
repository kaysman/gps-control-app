import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/features/sms/sms_thread.dart';
import 'package:gps_control/mock/mock_data.dart';
import 'package:gps_control/models/chat_message.dart';

void main() {
  final bx1 = smsTrackers[0];
  final bx2 = smsTrackers[1];

  group('samePhone', () {
    test('ignores formatting, spacing and the country code', () {
      expect(samePhone('+99371061287', '99371061287'), isTrue);
      expect(samePhone('+993 71 06-12-87', '+99371061287'), isTrue);
      expect(samePhone('71061287', '+99371061287'), isTrue);
    });

    test('separates different numbers', () {
      expect(samePhone(bx1.phone, bx2.phone), isFalse);
      expect(samePhone('', bx1.phone), isFalse);
    });
  });

  group('threadFor', () {
    final sentToBoth = SentChatMessage(
      timestamp: DateTime(2026, 8, 25, 9),
      recipientShorts: [bx1.short, bx2.short],
      commandId: 'battery',
      smsText: '#000000,RDBL',
    );
    final sentToOne = SentChatMessage(
      timestamp: DateTime(2026, 8, 25, 10),
      recipientShorts: [bx2.short],
      commandId: 'status',
      smsText: '#000000,RDLS',
    );
    final replyFromOne = ReceivedChatMessage(
      timestamp: DateTime(2026, 8, 25, 11),
      from: bx1.phone,
      body: 'BAT:86%,CHG:1',
    );
    final history = [sentToBoth, sentToOne, replyFromOne];

    test('keeps sends addressed to the tracker and its own replies', () {
      expect(threadFor(history, bx1), [sentToBoth, replyFromOne]);
      expect(threadFor(history, bx2), [sentToBoth, sentToOne]);
    });

    test('is empty for a tracker nobody has messaged', () {
      expect(threadFor(history, smsTrackers[2]), isEmpty);
    });

    test('lastMessageFor returns the newest message in that thread', () {
      expect(lastMessageFor(history, bx1), replyFromOne);
      expect(lastMessageFor(history, bx2), sentToOne);
      expect(lastMessageFor(history, smsTrackers[2]), isNull);
    });
  });
}
