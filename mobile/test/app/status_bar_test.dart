import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/app/app.dart';
import 'package:gps_control/data/sim/fake_sim_repository.dart';
import 'package:gps_control/data/sms/fake_sms_repository.dart';
import 'package:gps_control/data/tracker/fake_tracker_repository.dart';

/// The status bar sits on the page, not on chrome of its own, so its glyphs
/// have to follow whatever surface is behind them: light over the ink radar,
/// dark over the mist canvas everywhere else. Neither page declares a colour
/// for the glyphs themselves — iOS falls back to `.default`, which is white in
/// dark appearance and therefore invisible on mist — so both styles are
/// declared, and this pins the pair.
void main() {
  testWidgets('status bar glyphs follow the surface behind them', (
    tester,
  ) async {
    await tester.pumpWidget(
      App(
        trackers: FakeTrackerRepository(),
        sms: FakeSmsRepository(),
        sims: FakeSimRepository(),
      ),
    );
    // The radar animates forever, so settling is not an option.
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      SystemChrome.latestStyle?.statusBarIconBrightness,
      Brightness.light,
      reason: 'the radar screen is ink, so the glyphs must be light',
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      SystemChrome.latestStyle?.statusBarIconBrightness,
      Brightness.dark,
      reason: 'settings is mist, so the glyphs must be dark',
    );

    // The BLE tab starts a scan on entry, which runs on timers for as long as
    // the scan window. Let it expire rather than tearing the tree down under
    // it, which the test binding reports as pending timers.
    await tester.pump(const Duration(seconds: 20));
  });
}
