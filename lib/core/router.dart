import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/clarify/clarify_screen.dart';
import '../presentation/focus/focus_screen.dart';
import '../presentation/inbox/inbox_screen.dart';
import '../presentation/item/item_screen.dart';
import '../presentation/lists/archive_screen.dart';
import '../presentation/lists/list_screen.dart';
import '../presentation/lists/lists_screen.dart';
import '../presentation/lists/someday_screen.dart';
import '../presentation/lists/trash_screen.dart';
import '../presentation/reset/reset_screen.dart';
import '../presentation/search/search_screen.dart';
import '../presentation/settings/reminders_help_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/suggestions_screen.dart';
import '../presentation/shell/home_shell.dart';
import '../presentation/today/this_week_screen.dart';
import '../presentation/today/today_screen.dart';
import '../presentation/upcoming/upcoming_screen.dart';

abstract final class Routes {
  static const today = '/today';
  static const thisWeek = '/today/week';
  static const inbox = '/inbox';
  static const upcoming = '/upcoming';
  static const lists = '/lists';
  static const someday = '/lists/someday';
  static const archive = '/lists/archive';
  static const trash = '/lists/trash';
  static const settings = '/settings';
  static const search = '/search';
  static const reset = '/reset';
  static const suggestions = '/settings/suggestions';
  static const remindersHelp = '/settings/reminders-help';

  static String list(String id) => '/lists/$id';
  static String item(String id) => '/item/$id';
  static String clarify(String id) => '/clarify/$id';
  static String focus(String id) => '/focus/$id';
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
              routes: [
                GoRoute(
                  path: 'week',
                  builder: (context, state) => const ThisWeekScreen(),
                ),
              ],
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
              routes: [
                GoRoute(
                  path: 'someday',
                  builder: (context, state) => const SomedayScreen(),
                ),
                GoRoute(
                  path: 'archive',
                  builder: (context, state) => const ArchiveScreen(),
                ),
                GoRoute(
                  path: 'trash',
                  builder: (context, state) => const TrashScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      ListScreen(listId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/item/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          ItemScreen(itemId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/clarify/:id',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: ClarifyScreen(itemId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/focus/:id',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: FocusScreen(itemId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: Routes.reset,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: ResetScreen()),
    ),
    GoRoute(
      path: Routes.search,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'suggestions',
          builder: (context, state) => const SuggestionsScreen(),
        ),
        GoRoute(
          path: 'reminders-help',
          builder: (context, state) => const RemindersHelpScreen(),
        ),
      ],
    ),
  ],
);
