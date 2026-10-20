import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../presentation/inbox/inbox_screen.dart';
import '../presentation/lists/lists_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/shell/home_shell.dart';
import '../presentation/today/today_screen.dart';
import '../presentation/upcoming/upcoming_screen.dart';

abstract final class Routes {
  static const today = '/today';
  static const inbox = '/inbox';
  static const upcoming = '/upcoming';
  static const lists = '/lists';
  static const settings = '/settings';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter({String initialLocation = Routes.today}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.today,
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.inbox,
              builder: (context, state) => const InboxScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.upcoming,
              builder: (context, state) => const UpcomingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.lists,
              builder: (context, state) => const ListsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.settings,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
