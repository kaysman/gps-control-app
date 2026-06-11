/// A status report parsed from an SMS message sent by the tracker.
///
/// Wire format (barioX iS-Lock SMS protocol V1.00, comma-delimited, framed
/// by `*` and `#`):
///
///     *MM/DD/YY,HH:MM:SS,SN,lat,latDir,lon,lonDir,speed,height,&,
///      battery,charging,unlock,chainBreak,simCover,topCover,motorFault#
///
/// Example:
///     *10/25/25,13:09:45,2025000025,22.592856,N,113.997493,E,0,80,&,
///      42,0,1,0,0,0,1#
class TrackerStatus {
  /// Creates a tracker status report.
  const TrackerStatus({
    required this.timestamp,
    required this.serialNumber,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.altitudeMeters,
    required this.batteryPercent,
    required this.charging,
    required this.unlocked,
    required this.chainBreakAlarm,
    required this.simCoverOpen,
    required this.topCoverOpen,
    required this.motorFault,
  });

  /// Tracker-reported UTC timestamp.
  final DateTime timestamp;

  /// Device serial number (e.g. `2025000025`).
  final String serialNumber;

  /// Signed latitude in decimal degrees — negative for southern hemisphere.
  final double latitude;

  /// Signed longitude in decimal degrees — negative for western hemisphere.
  final double longitude;

  /// Ground speed in km/h.
  final int speedKmh;

  /// Altitude above sea level in metres.
  final int altitudeMeters;

  /// Battery charge percentage, 0–100.
  final int batteryPercent;

  /// True while the device is on external power.
  final bool charging;

  /// True when the lock is open.
  final bool unlocked;

  /// True when the chain/cable has been cut.
  final bool chainBreakAlarm;

  /// True when the SIM card cover is open.
  final bool simCoverOpen;

  /// True when the device's top cover is open.
  final bool topCoverOpen;

  /// True when the lock motor reports a fault.
  final bool motorFault;
}
