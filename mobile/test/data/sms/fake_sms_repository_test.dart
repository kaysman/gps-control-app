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
      // Empty login and empty password still take their separators.
      expect(firstSent.smsText, '  readio 67');

      // The seeded GPS answer is the documented getgps shape.
      final report = history
          .whereType<ReceivedChatMessage>()
          .map((m) => m.body)
          .firstWhere((b) => b.startsWith('GPS:'));
      expect(report, contains('Lat:37.960077'));
      expect(report, contains('Sat:9'));
    });

    test('answers each command it is sent', () async {
      final replies = <String>[];
      final sub = sms.incoming.listen((msg) => replies.add(msg.body));

      for (final body in [
        '  readio 67',
        '  getgps',
        '  getver',
        '  setparam 10050:30',
        '  setdigout 1',
        // A password in the credential slot must not be read as the verb.
        ' 1234 cpureset',
      ]) {
        expect(await sms.send(to: '+99371061259', body: body), isTrue);
      }

      // Replies are delivered on a delay, as a real device would.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await sub.cancel();

      expect(replies, hasLength(6));
      expect(replies[0], 'IO ID:67 Value:4021');
      expect(replies[1], startsWith('GPS:'));
      expect(replies[2], startsWith('Ver:'));
      expect(replies[3], '10050:30 OK');
      expect(replies[4], 'DOUT1:1 OK');
      expect(replies[5], 'CPU reset in progress');
    });
  });
}
