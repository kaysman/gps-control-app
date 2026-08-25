import 'package:flutter/foundation.dart';

/// One active SIM in the host device.
@immutable
class SimCard {
  /// Creates a [SimCard].
  const SimCard({
    required this.subscriptionId,
    required this.slotIndex,
    required this.carrierName,
    required this.displayName,
    required this.countryIso,
    required this.number,
  });

  /// Stable per-SIM identifier used when choosing which SIM sends an SMS.
  final int subscriptionId;

  /// 0-based physical slot (or eSIM slot).
  final int slotIndex;

  /// Carrier/operator name (e.g. "TM Cell").
  final String carrierName;

  /// User-visible display name set in the system settings.
  final String displayName;

  /// Lowercase ISO 3166-1 alpha-2 country code (may be empty).
  final String countryIso;

  /// Phone number stored on the SIM — usually empty on modern Android.
  final String number;

  /// A short label suitable for chips and list rows.
  String get label => carrierName.isNotEmpty
      ? carrierName
      : (displayName.isNotEmpty ? displayName : 'SIM ${slotIndex + 1}');
}

/// The app's source of truth for which SIMs can send commands.
//
// One member today, but this is a dependency-injection seam with two
// implementations (platform channel and fake), not a function in disguise.
// ignore: one_member_abstracts
abstract interface class SimRepository {
  /// The SIMs currently active in the device. Empty when none are readable.
  Future<List<SimCard>> getActiveSims();
}
