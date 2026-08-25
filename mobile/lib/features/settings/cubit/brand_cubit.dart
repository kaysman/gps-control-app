import 'package:flutter_bloc/flutter_bloc.dart';

/// The tracker family the app is pointed at.
///
/// Only [bariox] has a command implementation today — `packages/bariox_tracker`
/// for BLE and `packages/sms_tracker_commands` for SMS. [teltonika] is exposed
/// so the choice is visible in the UI ahead of that protocol landing, and is
/// flagged as such wherever it is offered.
enum TrackerBrand {
  /// Bariox master locks and sub-locks.
  bariox,

  /// Teltonika FMB-series trackers.
  teltonika
  ;

  /// Whether a command implementation for this brand ships in the app.
  bool get isImplemented => this == TrackerBrand.bariox;
}

/// Holds the selected [TrackerBrand].
class BrandCubit extends Cubit<TrackerBrand> {
  /// Starts in [initial], defaulting to Bariox — the only implemented brand.
  BrandCubit({TrackerBrand initial = TrackerBrand.bariox}) : super(initial);

  /// Switches the active brand. No-op if [brand] is already active.
  void setBrand(TrackerBrand brand) {
    if (brand == state) return;
    emit(brand);
  }
}
