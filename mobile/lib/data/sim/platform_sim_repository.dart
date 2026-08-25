import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gps_control/data/sim/sim_repository.dart';

/// [SimRepository] backed by the `gps_control/sim` platform channel, which wraps
/// Android's `SubscriptionManager`. Returns an empty list on other platforms.
class PlatformSimRepository implements SimRepository {
  static const _channel = MethodChannel('gps_control/sim');

  @override
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
      debugPrint('[SimRepo] getActiveSims failed: ${e.code} ${e.message}');
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
