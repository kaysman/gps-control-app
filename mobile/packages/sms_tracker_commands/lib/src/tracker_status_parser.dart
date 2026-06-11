import 'package:sms_tracker_commands/src/tracker_status.dart';

/// Parses a tracker SMS status report into a [TrackerStatus].
///
/// Throws [FormatException] if [sms] is not a well-formed report.
/// See [TrackerStatus] for the wire format.
TrackerStatus parseTrackerStatus(String sms) {
  final trimmed = sms.trim();
  if (!trimmed.startsWith('*') || !trimmed.endsWith('#')) {
    throw FormatException('tracker status must be framed by * ... #', sms);
  }

  final parts = trimmed
      .substring(1, trimmed.length - 1)
      .split(',')
      .map((p) => p.trim())
      .toList();

  if (parts.length != 17) {
    throw FormatException(
      'expected 17 comma-delimited fields, got ${parts.length}',
      sms,
    );
  }
  if (parts[9] != '&') {
    throw FormatException(
      "expected '&' separator at field 10, got '${parts[9]}'",
      sms,
    );
  }

  final latDir = parts[4];
  if (latDir != 'N' && latDir != 'S') {
    throw FormatException("latitude direction must be N or S, got '$latDir'");
  }
  final lonDir = parts[6];
  if (lonDir != 'E' && lonDir != 'W') {
    throw FormatException("longitude direction must be E or W, got '$lonDir'");
  }

  final latMagnitude = double.parse(parts[3]);
  final lonMagnitude = double.parse(parts[5]);

  return TrackerStatus(
    timestamp: _parseTimestamp(parts[0], parts[1]),
    serialNumber: parts[2],
    latitude: latDir == 'S' ? -latMagnitude : latMagnitude,
    longitude: lonDir == 'W' ? -lonMagnitude : lonMagnitude,
    speedKmh: int.parse(parts[7]),
    altitudeMeters: int.parse(parts[8]),
    batteryPercent: int.parse(parts[10]),
    charging: _parseFlag(parts[11], 'charging'),
    unlocked: _parseFlag(parts[12], 'unlock'),
    chainBreakAlarm: _parseFlag(parts[13], 'chain break'),
    simCoverOpen: _parseFlag(parts[14], 'SIM cover'),
    topCoverOpen: _parseFlag(parts[15], 'top cover'),
    motorFault: _parseFlag(parts[16], 'motor fault'),
  );
}

/// Parses a tracker SMS status report, returning null on any parse error.
TrackerStatus? tryParseTrackerStatus(String sms) {
  try {
    return parseTrackerStatus(sms);
  } on FormatException {
    return null;
  }
}

DateTime _parseTimestamp(String date, String time) {
  final dateParts = date.split('/');
  final timeParts = time.split(':');
  if (dateParts.length != 3 || timeParts.length != 3) {
    throw FormatException('bad date/time: $date $time');
  }
  final month = int.parse(dateParts[0]);
  final day = int.parse(dateParts[1]);
  var year = int.parse(dateParts[2]);
  if (year < 100) year += 2000;
  return DateTime.utc(
    year,
    month,
    day,
    int.parse(timeParts[0]),
    int.parse(timeParts[1]),
    int.parse(timeParts[2]),
  );
}

bool _parseFlag(String value, String name) {
  if (value == '0') return false;
  if (value == '1') return true;
  throw FormatException("$name flag must be 0 or 1, got '$value'");
}
