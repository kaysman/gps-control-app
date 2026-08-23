import 'dart:async';

import 'package:gps_control/app/app.dart';
import 'package:gps_control/data/sim/fake_sim_repository.dart';
import 'package:gps_control/data/sim/platform_sim_repository.dart';
import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:gps_control/data/sms/fake_sms_repository.dart';
import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/data/sms/telephony_sms_repository.dart';
import 'package:gps_control/data/tracker/ble_tracker_repository.dart';
import 'package:gps_control/data/tracker/fake_tracker_repository.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:gps_control/shell/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Run against canned data instead of hardware — no BLE, no SMS, no SIM, no
/// permission prompts:
///
/// ```sh
/// flutter run --dart-define=DEMO=true
/// ```
///
/// This is the only place in the app that knows demo mode exists. Everything
/// downstream is handed a repository and cannot tell the difference.
const _demo = bool.fromEnvironment('DEMO');

/// Demo-only conveniences: which tab to open on (`ble` | `sms` | `settings`)
/// and which language to start in (`tr` | `en`).
const _demoTab = String.fromEnvironment('DEMO_TAB', defaultValue: 'ble');
const _demoLocale = String.fromEnvironment('DEMO_LOCALE', defaultValue: 'tr');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final TrackerRepository trackers = _demo
      ? FakeTrackerRepository()
      : BleTrackerRepository();
  final SmsRepository sms = _demo
      ? FakeSmsRepository()
      : TelephonySmsRepository();
  final SimRepository sims = _demo
      ? FakeSimRepository()
      : PlatformSimRepository();

  // Grant permissions and register the SMS receiver early so background
  // messages can reach onBackgroundSms even before the SMS tab is opened.
  // Deliberately not awaited: the first run shows a permission dialog and the
  // UI should already be up behind it. SmsPage joins this same request rather
  // than starting a second one — see TelephonySmsRepository.ensureReady.
  unawaited(sms.ensureReady());

  runApp(
    App(
      trackers: trackers,
      sms: sms,
      sims: sims,
      initialTab: _tabNamed(_demoTab),
      initialLocale: Locale(_demoLocale),
    ),
  );
}

AppTab _tabNamed(String name) => switch (name) {
  'sms' => AppTab.sms,
  'settings' => AppTab.settings,
  _ => AppTab.ble,
};
