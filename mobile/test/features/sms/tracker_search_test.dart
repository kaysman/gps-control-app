import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/features/sms/tracker_search.dart';
import 'package:gps_control/mock/mock_data.dart';

void main() {
  group('searchTrackers', () {
    test('an empty query keeps the whole fleet', () {
      expect(searchTrackers(smsTrackers, ''), smsTrackers);
      expect(searchTrackers(smsTrackers, '   '), smsTrackers);
    });

    test('matches the short name, either case, with or without the dash', () {
      expect(searchTrackers(smsTrackers, 'BX-001').single, smsTrackers[0]);
      expect(searchTrackers(smsTrackers, 'bx-001').single, smsTrackers[0]);
      expect(searchTrackers(smsTrackers, 'bx001').single, smsTrackers[0]);
    });

    test('matches a serial fragment', () {
      expect(searchTrackers(smsTrackers, '2500000002').single, smsTrackers[1]);
      expect(searchTrackers(smsTrackers, '001'), contains(smsTrackers[0]));
    });

    test('matches a phone number however it is punctuated', () {
      final t = smsTrackers[0];
      expect(searchTrackers(smsTrackers, t.phone).single, t);
      expect(searchTrackers(smsTrackers, '+993 71 06-12-87').single, t);
      expect(searchTrackers(smsTrackers, '1061287').single, t);
    });

    test('a query nothing matches returns nothing', () {
      expect(searchTrackers(smsTrackers, 'zzz'), isEmpty);
      expect(searchTrackers(smsTrackers, '999999999'), isEmpty);
    });

    test('a broad query keeps every tracker', () {
      expect(searchTrackers(smsTrackers, 'bx'), hasLength(smsTrackers.length));
    });
  });
}
