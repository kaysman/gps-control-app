import 'package:bariox_tracker/src/ble/tracker_connection.dart';
import 'package:bariox_tracker/src/models/broadcast_packet.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A Bariox e-lock found during a BLE scan.
///
/// Captures the BLE device handle, the advertised local name (e.g.
/// `"HB_2500000016"`), and signal strength. [packet] is populated only when
/// the unit's advertisement matches the docx broadcast format — HB-series
/// firmware shipping today does not, so callers should treat [packet] as a
/// hint, not a requirement, and read [deviceId] / [advName] for identity.
class DiscoveredTracker {
  /// Creates a [DiscoveredTracker].
  const DiscoveredTracker({
    required this.device,
    required this.advName,
    required this.rssi,
    this.packet,
  });

  /// The underlying BLE device (holds the MAC address / remote ID).
  final BluetoothDevice device;

  /// Local Name advertised by the device, e.g. `"HB_2500000016"`. Empty if
  /// the device didn't advertise one.
  final String advName;

  /// Signal strength at the time of discovery.
  final int rssi;

  /// Parsed broadcast data — null on HB-series units running the legacy
  /// firmware family, since their advertisements don't carry the docx-format
  /// broadcast payload.
  final BroadcastPacket? packet;

  /// 10-digit decimal device serial number, parsed from [advName] when it
  /// follows the `HB_<digits>` convention. Falls back to [packet]'s deviceId,
  /// then to the MAC address as last resort.
  String get deviceId {
    if (advName.startsWith('HB_')) {
      final tail = advName.substring(3);
      if (RegExp(r'^\d+$').hasMatch(tail)) return tail;
    }
    return packet?.deviceId ?? device.remoteId.str;
  }

  /// Connects to this device and returns an active [TrackerConnection].
  Future<TrackerConnection> connect() => TrackerConnection.connect(device);
}
