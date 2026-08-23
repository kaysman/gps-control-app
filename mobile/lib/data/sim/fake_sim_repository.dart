import 'package:gps_control/data/sim/sim_repository.dart';

/// [SimRepository] reporting a canned dual-SIM device.
class FakeSimRepository implements SimRepository {
  @override
  Future<List<SimCard>> getActiveSims() async => const [
    SimCard(
      subscriptionId: 1,
      slotIndex: 0,
      carrierName: 'TM Cell',
      displayName: 'TM Cell',
      countryIso: 'tm',
      number: '',
    ),
    SimCard(
      subscriptionId: 2,
      slotIndex: 1,
      carrierName: 'Ashgabat City',
      displayName: 'Ashgabat City',
      countryIso: 'tm',
      number: '',
    ),
  ];
}
