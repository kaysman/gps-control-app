import 'package:bariox_control/app/app.dart';
import 'package:bariox_control/services/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Register the SMS broadcast receiver early so background messages
  // can reach onBackgroundSms even before the SMS tab is opened.
  SmsService.instance.startListening();
  runApp(const App());
}
