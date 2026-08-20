import 'dart:async';

import 'package:bariox_control/app/app.dart';
import 'package:bariox_control/services/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Grant permissions and register the SMS broadcast receiver early so
  // background messages can reach onBackgroundSms even before the SMS tab is
  // opened. Deliberately not awaited: the first run shows a permission dialog
  // and the UI should already be up behind it. SmsPage joins this same
  // request rather than starting a second one — see SmsService.ensureReady.
  unawaited(SmsService.instance.ensureReady());
  runApp(const App());
}
