import 'package:sms_tracker_commands/sms_tracker_commands.dart';
import 'package:test/test.dart';

const _specExample =
    '*10/25/25,13:09:45,2025000025 ,22.592856,N,113.997493,E,0,80,&,42,0,1,0,0,0,1#';
const _fourDigitYear =
    '*05/12/2018,14:00:00,2545962485,22.592856,N,113.997493,E,0,80,&,42,0,1,0,0,0,1#';
const _southWest =
    '*10/25/25,13:09:45,2025000025,22.592856,S,113.997493,W,0,80,&,42,0,1,0,0,0,1#';
const _padded =
    '  *10/25/25,13:09:45,2025000025,22.592856,N,113.997493,E,0,80,&,42,0,1,0,0,0,1#  ';
const _unframed =
    '10/25/25,13:09:45,2025000025,22.592856,N,113.997493,E,0,80,&,42,0,1,0,0,0,1';
const _badSeparator =
    '*10/25/25,13:09:45,2025000025,22.592856,N,113.997493,E,0,80,X,42,0,1,0,0,0,1#';
const _badLatDir =
    '*10/25/25,13:09:45,2025000025,22.592856,X,113.997493,E,0,80,&,42,0,1,0,0,0,1#';
const _badFlag =
    '*10/25/25,13:09:45,2025000025,22.592856,N,113.997493,E,0,80,&,42,0,2,0,0,0,1#';

void main() {
  group('parseTrackerStatus', () {
    test('parses the spec example', () {
      final status = parseTrackerStatus(_specExample);

      expect(status.timestamp, DateTime.utc(2025, 10, 25, 13, 9, 45));
      expect(status.serialNumber, '2025000025');
      expect(status.latitude, closeTo(22.592856, 1e-9));
      expect(status.longitude, closeTo(113.997493, 1e-9));
      expect(status.speedKmh, 0);
      expect(status.altitudeMeters, 80);
      expect(status.batteryPercent, 42);
      expect(status.charging, isFalse);
      expect(status.unlocked, isTrue);
      expect(status.chainBreakAlarm, isFalse);
      expect(status.simCoverOpen, isFalse);
      expect(status.topCoverOpen, isFalse);
      expect(status.motorFault, isTrue);
    });

    test('parses 4-digit years', () {
      final status = parseTrackerStatus(_fourDigitYear);

      expect(status.timestamp, DateTime.utc(2018, 5, 12, 14));
      expect(status.serialNumber, '2545962485');
    });

    test('applies south/west sign to coordinates', () {
      final status = parseTrackerStatus(_southWest);

      expect(status.latitude, closeTo(-22.592856, 1e-9));
      expect(status.longitude, closeTo(-113.997493, 1e-9));
    });

    test('tolerates surrounding whitespace', () {
      expect(() => parseTrackerStatus(_padded), returnsNormally);
    });

    test('rejects missing frame', () {
      expect(() => parseTrackerStatus(_unframed), throwsFormatException);
    });

    test('rejects wrong field count', () {
      expect(
        () => parseTrackerStatus('*10/25/25,13:09:45,2025000025#'),
        throwsFormatException,
      );
    });

    test('rejects missing & separator', () {
      expect(() => parseTrackerStatus(_badSeparator), throwsFormatException);
    });

    test('rejects invalid latitude direction', () {
      expect(() => parseTrackerStatus(_badLatDir), throwsFormatException);
    });

    test('rejects non-binary flag', () {
      expect(() => parseTrackerStatus(_badFlag), throwsFormatException);
    });
  });

  group('tryParseTrackerStatus', () {
    test('returns a status on success', () {
      expect(tryParseTrackerStatus(_specExample), isA<TrackerStatus>());
    });

    test('returns null on failure', () {
      expect(tryParseTrackerStatus('not a tracker message'), isNull);
    });
  });
}
