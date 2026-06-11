import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One active SIM as reported by Android's [SubscriptionManager].
@immutable
class SimCard {
  const SimCard({
    required this.subscriptionId,
    required this.slotIndex,
    required this.carrierName,
    required this.displayName,
    required this.countryIso,
    required this.number,
  });

  /// Stable per-SIM identifier used by `SmsManager.getSmsManagerForSubscriptionId`.
  final int subscriptionId;

  /// 0-based physical slot (or eSIM slot).
  final int slotIndex;

  /// Carrier/operator name (e.g. "TM Cell").
  final String carrierName;

  /// User-visible display name set in Android settings.
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

/// Thin wrapper around the `bariox/sim` platform channel. Android-only;
/// returns an empty list on other platforms.
class SimCardService {
  SimCardService._();
  static final instance = SimCardService._();

  static const _channel = MethodChannel('bariox/sim');

  Future<List<SimCard>> getActiveSims() async {
    try {
      final raw = await _channel.invokeMethod<List<Object?>>('getActiveSims');
      if (raw == null) return const [];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(_fromMap)
          .toList(growable: false);
    } on MissingPluginException {
      // Non-Android platform or channel not attached yet.
      return const [];
    } on PlatformException catch (e) {
      debugPrint(
        '[SimCardService] getActiveSims failed: ${e.code} ${e.message}',
      );
      return const [];
    }
  }

  SimCard _fromMap(Map<Object?, Object?> map) {
    return SimCard(
      subscriptionId: (map['subscriptionId'] as int?) ?? -1,
      slotIndex: (map['slotIndex'] as int?) ?? -1,
      carrierName: (map['carrierName'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      countryIso: (map['countryIso'] as String?) ?? '',
      number: (map['number'] as String?) ?? '',
    );
  }
}
