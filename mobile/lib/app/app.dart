import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/features/sim/cubit/sim_cubit.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:bariox_control/shell/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => SimCubit()..load()),
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
            home: const ShellPage(),
          );
        },
      ),
    );
  }
}
