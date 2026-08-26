import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/data/sim/fake_sim_repository.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/features/settings/view/settings_page.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Stands in for the app shell: a branch [Navigator] holding the page, with a
/// bottom bar stacked *over* it — the arrangement that used to swallow the
/// pickers. Anything a picker pushes onto the branch navigator lands inside
/// [_branchKey] and therefore under the bar.
const _branchKey = Key('branch');

Widget _harness() {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => LocaleCubit()),
      BlocProvider(create: (_) => BrandCubit()),
      BlocProvider(
        create: (_) {
          final cubit = SimCubit(FakeSimRepository());
          unawaited(cubit.load());
          return cubit;
        },
      ),
    ],
    child: BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          locale: locale,
          supportedLocales: LocaleCubit.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Stack(
            children: [
              Positioned.fill(
                child: KeyedSubtree(
                  key: _branchKey,
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: SettingsPage()),
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Color(0xFFFFFFFF),
                  child: SizedBox(height: 60, width: double.infinity),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<void> _openRow(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsPage', () {
    testWidgets('starts in English', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('pickers open outside the branch navigator, above the bar', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();
      await _openRow(tester, 'Language');

      expect(find.byType(PickerSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(_branchKey),
          matching: find.byType(PickerSheet),
        ),
        findsNothing,
        reason: 'a sheet inside the branch navigator renders under the tab bar',
      );
    });

    testWidgets('picking Turkish re-renders the app in Turkish', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();
      await _openRow(tester, 'Language');

      await tester.tap(find.text('Turkish'));
      await tester.pumpAndSettle();

      expect(find.byType(PickerSheet), findsNothing);
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Türkçe'), findsOneWidget);
    });

    testWidgets('brand defaults to Teltonika and switches to Bariox', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Teltonika'), findsOneWidget);

      await _openRow(tester, 'Tracker brand');

      await tester.tap(find.text('Bariox'));
      await tester.pumpAndSettle();

      expect(find.byType(PickerSheet), findsNothing);
      expect(find.text('Bariox'), findsOneWidget);
      expect(find.text('Teltonika'), findsNothing);
    });

    testWidgets('the SIM picker is a sheet and switches the active SIM', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('TM Cell (Slot 1)'), findsOneWidget);

      await _openRow(tester, 'Active SIM');
      expect(find.byType(PickerSheet), findsOneWidget);

      await tester.tap(find.text('Ashgabat City'));
      await tester.pumpAndSettle();

      expect(find.byType(PickerSheet), findsNothing);
      expect(find.text('Ashgabat City (Slot 2)'), findsOneWidget);
    });
  });
}
