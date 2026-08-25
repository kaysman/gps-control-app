import 'dart:typed_data';

int _toBcd(int value) => ((value ~/ 10) << 4) | (value % 10);
int _fromBcd(int bcd) => ((bcd >> 4) & 0x0F) * 10 + (bcd & 0x0F);

/// Device clock value encoded as 6-byte BCD (YYMMDDhhmmss).
class TrackerTime {
  /// Creates a [TrackerTime] with explicit date/time components.
  ///
  /// [year] is the last two digits of the calendar year (0–99).
  const TrackerTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });

  /// Creates a [TrackerTime] from a [DateTime].
  factory TrackerTime.fromDateTime(DateTime dt) => TrackerTime(
    year: dt.year % 100,
    month: dt.month,
    day: dt.day,
    hour: dt.hour,
    minute: dt.minute,
    second: dt.second,
  );

  /// Decodes a [TrackerTime] from the 6-byte BCD representation used in
  /// protocol frames (YY MM DD hh mm ss).
  factory TrackerTime.fromBytes(Uint8List bytes) {
    assert(bytes.length >= 6, 'TrackerTime requires at least 6 bytes');
    return TrackerTime(
      year: _fromBcd(bytes[0]),
      month: _fromBcd(bytes[1]),
      day: _fromBcd(bytes[2]),
      hour: _fromBcd(bytes[3]),
      minute: _fromBcd(bytes[4]),
      second: _fromBcd(bytes[5]),
    );
  }

  /// Last two digits of the year (e.g. 25 for 2025).
  final int year;

  /// Month (1–12).
  final int month;

  /// Day of month (1–31).
  final int day;

  /// Hour (0–23).
  final int hour;

  /// Minute (0–59).
  final int minute;

  /// Second (0–59).
  final int second;

  /// Encodes this time as the 6-byte BCD array expected by the protocol.
  Uint8List toBytes() => Uint8List.fromList([
    _toBcd(year),
    _toBcd(month),
    _toBcd(day),
    _toBcd(hour),
    _toBcd(minute),
    _toBcd(second),
  ]);

  /// Converts to a [DateTime], interpreting [year] as 2000+.
  DateTime toDateTime() =>
      DateTime(2000 + year, month, day, hour, minute, second);

  @override
  String toString() =>
      '20$year-${_pad(month)}-${_pad(day)} '
      '${_pad(hour)}:${_pad(minute)}:${_pad(second)}';

  static String _pad(int v) => v.toString().padLeft(2, '0');
}
