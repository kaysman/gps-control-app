import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final trackers = _trackerRepository();
  final sms = _smsRepository();
  final sims = _simRepository();

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
    ),
  );
}

// The composition root. Return types are the interfaces on purpose: nothing
// downstream is allowed to know which implementation it was handed.
TrackerRepository _trackerRepository() =>
    _demo ? FakeTrackerRepository() : BleTrackerRepository();

SmsRepository _smsRepository() =>
    _demo ? FakeSmsRepository() : TelephonySmsRepository();

SimRepository _simRepository() =>
    _demo ? FakeSimRepository() : PlatformSimRepository();
