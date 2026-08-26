import 'package:flutter_bloc/flutter_bloc.dart';

/// The tracker family the app is pointed at.
///
/// The SMS command catalogue is Teltonika's — see `mock_data.dart` and
/// `sms_command_text.dart`. BLE is the other way round: `packages/
/// bariox_tracker` speaks the Bariox protocol and nothing else, so the
/// Bluetooth tab only reaches Bariox hardware.
enum TrackerBrand {
  /// Teltonika FMB-series trackers, configured over SMS.
  teltonika,

  /// Bariox master locks and sub-locks, configured over BLE.
  bariox
  ;

  /// Whether the Bluetooth tab can talk to this brand.
  bool get hasBleSupport => this == TrackerBrand.bariox;
}

/// Holds the selected [TrackerBrand].
class BrandCubit extends Cubit<TrackerBrand> {
  /// Starts in [initial], defaulting to Teltonika.
  BrandCubit({TrackerBrand initial = TrackerBrand.teltonika}) : super(initial);

  /// Switches the active brand. No-op if [brand] is already active.
  void setBrand(TrackerBrand brand) {
    if (brand == state) return;
    emit(brand);
  }
}
