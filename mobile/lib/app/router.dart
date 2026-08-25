import 'package:go_router/go_router.dart';
import 'package:gps_control/features/bluetooth/view/bluetooth_page.dart';
import 'package:gps_control/features/settings/view/settings_page.dart';
import 'package:gps_control/features/sms/view/sms_chat_page.dart';
import 'package:gps_control/features/sms/view/sms_threads_page.dart';
import 'package:gps_control/shell/shell_page.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/ble',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellPage(shell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ble',
              builder: (context, state) => const BluetoothPage(isActive: true),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sms',
              builder: (context, state) => const SmsThreadsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Outside the shell on purpose: a chat takes the whole screen, so the
    // floating tab bar does not sit on top of its compose bar.
    GoRoute(
      path: '/sms/:trackerId',
      builder: (context, state) =>
          SmsChatPage(trackerId: state.pathParameters['trackerId']!),
    ),
  ],
);
