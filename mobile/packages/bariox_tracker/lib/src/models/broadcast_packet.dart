import 'package:bariox_tracker/src/models/tracker_device_type.dart';

/// Parsed representation of the 18-byte BLE advertisement broadcast emitted
/// periodically by the Bariox e-lock device.
class BroadcastPacket {
  /// Creates a [BroadcastPacket] with all status fields.
  const BroadcastPacket({
    required this.deviceType,
    required this.deviceId,
    required this.hardwareVersion,
    required this.softwareVersion,
    required this.batteryLevel,
    required this.temperature,
    required this.isCharging,
    required this.isFullyCharged,
    required this.hasChargingFault,
    required this.hasBatteryFault,
    required this.isUnlocked,
    required this.hasChainIssue,
    required this.isCoverOpen,
    required this.hasRfModuleFault,
    required this.isRearCoverOpen,
    required this.isLockStuck,
  });

  /// Device model; null if the device type byte is not recognised.
  final TrackerDeviceType? deviceType;

  /// 12-digit BCD device identifier (e.g. "000123456789").
  final String deviceId;

  /// Human-readable hardware version (e.g. "1.0").
  final String hardwareVersion;

  /// Numeric software version (e.g. 10001 for V1.0.0.01).
  final int softwareVersion;

  /// Battery charge level as a percentage (0–100).
  final int batteryLevel;

  /// Ambient temperature in °C, or null when not available (device reports
  /// 0xFF for the temperature byte).
  final int? temperature;

  // ── Charging status bits (broadcast byte 16) ────────────────────────────

  /// bit0: external charger is connected and actively charging.
  final bool isCharging;

  /// bit1: battery is fully charged.
  final bool isFullyCharged;

  /// bit2: charging fault detected.
  final bool hasChargingFault;

  /// bit3: battery fault detected.
  final bool hasBatteryFault;

  // ── E-seal status bits (broadcast byte 17) ──────────────────────────────

  /// bit0: device is in the unlocked state.
  final bool isUnlocked;

  /// bit1: lock-chain anomaly detected.
  final bool hasChainIssue;

  /// bit2: front cover is open.
  final bool isCoverOpen;

  /// bit3: RF module fault.
  final bool hasRfModuleFault;

  /// bit4: rear cover is open.
  final bool isRearCoverOpen;

  /// bit5: motor/lock mechanism is stuck.
  final bool isLockStuck;

  @override
  String toString() =>
      'BroadcastPacket(id: $deviceId, battery: $batteryLevel%, '
      'unlocked: $isUnlocked, charging: $isCharging)';
}
