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
      expect(searchTrackers(smsTrackers, 'FMB-001').single, smsTrackers[0]);
      expect(searchTrackers(smsTrackers, 'fmb-001').single, smsTrackers[0]);
      expect(searchTrackers(smsTrackers, 'fmb001').single, smsTrackers[0]);
    });

    test('matches an IMEI fragment', () {
      expect(
        searchTrackers(smsTrackers, smsTrackers[1].id).single,
        smsTrackers[1],
      );
      expect(searchTrackers(smsTrackers, '001'), contains(smsTrackers[0]));
    });

    test('matches the model printed on the case', () {
      final matches = searchTrackers(smsTrackers, 'fmb640');
      expect(matches, isNotEmpty);
      expect(matches.every((t) => t.name.contains('FMB640')), isTrue);
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

    test('a query every unit shares keeps the whole fleet', () {
      expect(
        searchTrackers(smsTrackers, '35209408'),
        hasLength(smsTrackers.length),
      );
    });
  });
}
