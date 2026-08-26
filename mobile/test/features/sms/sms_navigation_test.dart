import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_control/data/sim/fake_sim_repository.dart';
import 'package:gps_control/data/sms/fake_sms_repository.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/features/sms/cubit/conversation_cubit.dart';
import 'package:gps_control/features/sms/cubit/tracker_password_cubit.dart';
import 'package:gps_control/features/sms/view/sms_chat_page.dart';
import 'package:gps_control/features/sms/view/sms_threads_page.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';

Widget _harness() {
  final router = GoRouter(
    routes: [
      // Wrapped the way the shell wraps it, so the page finds a Material.
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: SmsThreadsPage()),
      ),
      GoRoute(
        path: '/sms/:trackerId',
        builder: (_, state) =>
            SmsChatPage(trackerId: state.pathParameters['trackerId']!),
      ),
    ],
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => LocaleCubit()),
      BlocProvider(create: (_) => TrackerPasswordCubit()),
      BlocProvider(create: (_) => SimCubit(FakeSimRepository())),
      BlocProvider(create: (_) => ConversationCubit(FakeSmsRepository())),
    ],
    child: MaterialApp.router(
      supportedLocales: LocaleCubit.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    ),
  );
}

void main() {
  group('SMS tab', () {
    testWidgets('lists the fleet with a preview of each thread', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);
      // Every tracker gets a row, messaged or not.
      expect(find.text(smsTrackers.first.short), findsOneWidget);
      expect(find.text(smsTrackers.last.short), findsOneWidget);
      // Each messaged thread previews its newest message — here, the
      // tracker's own reply.
      expect(find.text('IO ID:67 Value:4102'), findsOneWidget);
      // A tracker nobody has messaged says so instead of showing nothing.
      expect(find.text('No messages yet'), findsWidgets);
    });

    testWidgets('search narrows the list and clears back to the full fleet', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'fmb-002');
      await tester.pumpAndSettle();
      expect(find.text(smsTrackers[1].short), findsOneWidget);
      expect(find.text(smsTrackers[0].short), findsNothing);

      await tester.enterText(find.byType(TextField), 'nothing here');
      await tester.pumpAndSettle();
      expect(find.textContaining('No tracker matches that'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text(smsTrackers[0].short), findsOneWidget);
      expect(find.text(smsTrackers.last.short), findsOneWidget);
    });

    testWidgets('opens one tracker chat, with a static single recipient', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final tracker = smsTrackers.first;
      await tester.tap(find.text(tracker.short));
      await tester.pumpAndSettle();

      // The chat names exactly one recipient and offers no way to add another.
      expect(find.text('To: ${tracker.phone}'), findsOneWidget);
      expect(find.text('+ Add'), findsNothing);
      expect(find.text('Pick a command to send'), findsOneWidget);
    });

    testWidgets('a chat shows only its own tracker messages', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // The 4102 reading came from the first tracker only.
      await tester.tap(find.text(smsTrackers[2].short));
      await tester.pumpAndSettle();
      expect(find.textContaining('Value:4102'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      await tester.tap(find.text(smsTrackers.first.short));
      await tester.pumpAndSettle();
      expect(find.textContaining('Value:4102'), findsOneWidget);
    });

    testWidgets('sending in a chat moves that thread preview in the list', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final quiet = smsTrackers[2];
      await tester.tap(find.text(quiet.short));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick a command to send'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Battery voltage'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // The list and the chat read one conversation, so the row updates
      // without reloading anything.
      expect(find.text('You: Battery voltage'), findsOneWidget);

      // The canned device answers a moment later; the preview follows.
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();
      expect(find.text('IO ID:67 Value:4021'), findsOneWidget);
    });
  });
}
