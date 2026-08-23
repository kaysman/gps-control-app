import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:gps_control/data/sms/sms_repository.dart';
import 'package:gps_control/data/tracker/tracker_repository.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/shell/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root widget. Receives the repositories it should run against, so swapping
/// real hardware for canned data is a decision made once, in `main`.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({
    super.key,
    required this.trackers,
    required this.sms,
    required this.sims,
    this.initialTab = AppTab.ble,
    this.initialLocale = const Locale('tr'),
  });

  /// Source of lock data over Bluetooth.
  final TrackerRepository trackers;

  /// Source of the SMS conversation with the trackers.
  final SmsRepository sms;

  /// Source of the device's SIM list.
  final SimRepository sims;

  /// Tab the app opens on.
  final AppTab initialTab;

  /// Language the app starts in.
  final Locale initialLocale;

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
          BlocProvider(create: (_) => LocaleCubit(initial: initialLocale)),
          BlocProvider(create: (ctx) => SimCubit(ctx.read<SimRepository>())..load()),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              onGenerateTitle: (ctx) => ctx.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: LocaleCubit.supported,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: kPaper,
                fontFamily: kSans,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: kNavy,
                  surface: kPaper,
                ),
              ),
              home: ShellPage(initialTab: initialTab),
            );
          },
        ),
      ),
    );
  }
}
