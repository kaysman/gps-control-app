import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/router.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/features/sms/cubit/conversation_cubit.dart';
import 'package:gps_control/features/sms/cubit/tracker_password_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Root widget. Receives the repositories it should run against, so swapping
/// real hardware for canned data is a decision made once, in `main`.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({
    required this.trackers,
    required this.sms,
    required this.sims,
    super.key,
  });

  /// Source of lock data over Bluetooth.
  final TrackerRepository trackers;

  /// Source of the SMS conversation with the trackers.
  final SmsRepository sms;

  /// Source of the device's SIM list.
  final SimRepository sims;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TrackerRepository>.value(value: trackers),
        RepositoryProvider<SmsRepository>.value(value: sms),
        RepositoryProvider<SimRepository>.value(value: sims),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(create: (_) => BrandCubit()),
          BlocProvider(create: (_) => TrackerPasswordCubit()),
          // Restored by the thread list, which is also what triggers the SMS
          // permission prompt.
          BlocProvider(
            create: (ctx) => ConversationCubit(ctx.read<SmsRepository>()),
          ),
          BlocProvider(
            create: (ctx) {
              final cubit = SimCubit(ctx.read<SimRepository>());
              // The first load races the UI on purpose: the SIM chip
              // fills in when the platform answers.
              unawaited(cubit.load());
              return cubit;
            },
          ),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              onGenerateTitle: (ctx) => ctx.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: LocaleCubit.supported,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: kCanvas,
                fontFamily: kSans,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: kGreenDeep,
                  surface: kCanvas,
                ),
              ),
              routerConfig: goRouter,
            );
          },
        ),
      ),
    );
  }
}
