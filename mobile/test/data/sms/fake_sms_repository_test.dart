import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/data/sms/fake_sms_repository.dart';
import 'package:gps_control/models/chat_message.dart';

void main() {
  group('FakeSmsRepository', () {
    late FakeSmsRepository sms;

    setUp(() => sms = FakeSmsRepository());
    tearDown(() => sms.dispose());

    test('opens with a conversation whose replies match the senders', () async {
      final history = await sms.loadHistory();
      final selected = await sms.loadRecipientSelection();

      expect(history, isNotEmpty);
      expect(selected, hasLength(3));

      final firstSent = history.whereType<SentChatMessage>().first;
      expect(firstSent.commandId, 'battery');
      expect(firstSent.smsText, '#000000,RDBL');

      // The seeded position report is the documented wire format.
      final report = history
          .whereType<ReceivedChatMessage>()
          .map((m) => m.body)
          .firstWhere((b) => b.startsWith('*'));
      expect(report.split(',').length, 17);
      expect(report, endsWith('#'));
    });

    test('answers each command it is sent', () async {
      final replies = <String>[];
      final sub = sms.incoming.listen((msg) => replies.add(msg.body));

      for (final body in [
        '#000000,RDBL',
        '#000000,RDLO',
        '#000000,RDVE',
        '#000000,STIN:30',
        '(P43,000000)',
      ]) {
        expect(await sms.send(to: '+99371061259', body: body), isTrue);
      }

      // Replies are delivered on a delay, as a real device would.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await sub.cancel();

      expect(replies, hasLength(5));
      expect(replies[0], 'BAT:78%,CHG:0');
      expect(replies[1], startsWith('*'));
      expect(replies[2], startsWith('VER:'));
      expect(replies[3], 'STIN:30 OK');
      expect(replies[4], 'P43 OK');
    });
  });
}
