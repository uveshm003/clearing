import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/clarify/clarify_screen.dart';
import '../presentation/focus/focus_screen.dart';
import '../presentation/grove/cairn_screen.dart';
import '../presentation/grove/field_notes_screen.dart';
import '../presentation/grove/grove_screen.dart';
import '../presentation/grove/insights_screen.dart';
import '../presentation/grove/season_album_screen.dart';
import '../presentation/settings/changes_screen.dart';
import '../presentation/settings/contexts_screen.dart';
import '../presentation/settings/developer_screen.dart';
import '../presentation/settings/review_prompts_screen.dart';
import '../presentation/settings/style_screen.dart';
import '../presentation/today/decide_screen.dart';
import '../presentation/widgets/reorder_screen.dart';
import '../presentation/inbox/cards_screen.dart';
import '../presentation/inbox/inbox_screen.dart';
import '../presentation/item/item_screen.dart';
import '../presentation/lists/archive_screen.dart';
import '../presentation/lists/list_screen.dart';
import '../presentation/lists/saved_search_screen.dart';
import '../presentation/lists/lists_screen.dart';
import '../presentation/lists/someday_screen.dart';
import '../presentation/lists/trash_screen.dart';
import '../presentation/reset/reset_screen.dart';
import '../presentation/review/review_screen.dart';
import '../presentation/search/search_screen.dart';
import '../presentation/settings/about_screen.dart';
import '../presentation/settings/backup_screen.dart';
import '../presentation/settings/faq_screen.dart';
import '../presentation/guidance/guides.dart';
import '../presentation/guidance/help_screen.dart';
import '../presentation/guidance/onboarding_screen.dart';
import '../presentation/settings/reminders_help_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/suggestions_screen.dart';
import '../presentation/shell/home_shell.dart';
import '../presentation/templates/template_screen.dart';
import '../presentation/templates/templates_screen.dart';
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
  static const templates = '/lists/templates';

  static String template(String id) => '/lists/templates/$id';
  static const settings = '/settings';
  static const search = '/search';
  static const reset = '/reset';
  static const review = '/review';
  static const suggestions = '/settings/suggestions';
  static const remindersHelp = '/settings/reminders-help';
  static const backup = '/settings/backup';
  static const about = '/settings/about';
  static const faq = '/settings/faq';
  static const intro = '/intro';
  static const welcome = '/welcome';
  static const help = '/settings/help';
  static const contexts = '/settings/contexts';
  static const style = '/settings/style';
  static const developer = '/settings/developer';
  static const reviewPrompts = '/settings/review-checks';

  static String guide(String topic) => '/settings/help/$topic';
  static const recent = '/recent';
  static const grove = '/grove';
  static const fieldNotes = '/grove/notes';
  static const cairn = '/grove/cairn';
  static const seasons = '/grove/seasons';
  static const insights = '/grove/rhythm';
  static const reorderToday = '/reorder';
  static String reorderList(String id) => '/reorder/$id';
  static const decide = '/decide';
  static const inboxCards = '/cards';

  static String list(String id) => '/lists/$id';
  static String savedSearch(String id) => '/lists/saved/$id';
  static String item(String id) => '/item/$id';
  static String clarify(String id) => '/clarify/$id';

  /// Clarifies [ids] one after another; [done] counts those already done.
  static String clarifyAll(List<String> ids, {int done = 0}) =>
      '/clarify/${ids.first}?next=${ids.skip(1).join(',')}&done=$done';
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
                  path: 'templates',
                  builder: (context, state) => const TemplatesScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => TemplateScreen(
                        templateId: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'saved/:id',
                  builder: (context, state) =>
                      SavedSearchScreen(id: state.pathParameters['id']!),
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
        child: ClarifyScreen(
          itemId: state.pathParameters['id']!,
          next: [
            for (final id in (state.uri.queryParameters['next'] ?? '').split(
              ',',
            ))
              if (id.isNotEmpty) id,
          ],
          done: int.tryParse(state.uri.queryParameters['done'] ?? '') ?? 0,
        ),
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
      path: Routes.intro,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: OnboardingScreen(tourOnly: true),
      ),
    ),
    GoRoute(
      path: Routes.welcome,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: OnboardingScreen()),
    ),
    GoRoute(
      path: Routes.review,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: ReviewScreen()),
    ),
    GoRoute(
      path: Routes.reset,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: ResetScreen()),
    ),
    GoRoute(
      path: Routes.reorderToday,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ReorderScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              ReorderScreen(listId: state.pathParameters['id']),
        ),
      ],
    ),
    GoRoute(
      path: Routes.inboxCards,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: CardsScreen()),
    ),
    GoRoute(
      path: Routes.decide,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: DecideScreen()),
    ),
    GoRoute(
      path: Routes.recent,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ChangesScreen(),
    ),
    GoRoute(
      path: Routes.grove,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const GroveScreen(),
      routes: [
        GoRoute(
          path: 'notes',
          builder: (context, state) => const FieldNotesScreen(),
        ),
        GoRoute(
          path: 'cairn',
          builder: (context, state) => const CairnScreen(),
        ),
        GoRoute(
          path: 'seasons',
          builder: (context, state) => const SeasonAlbumScreen(),
        ),
        GoRoute(
          path: 'rhythm',
          builder: (context, state) => const InsightsScreen(),
        ),
      ],
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
          path: 'help',
          builder: (context, state) => const HelpScreen(),
          routes: [
            GoRoute(
              path: ':topic',
              builder: (context, state) => GuideScreen(
                topic: GuideTopic.values.byName(state.pathParameters['topic']!),
              ),
            ),
          ],
        ),
        GoRoute(path: 'faq', builder: (context, state) => const FaqScreen()),
        GoRoute(
          path: 'contexts',
          builder: (context, state) => const ContextsScreen(),
        ),
        GoRoute(
          path: 'style',
          builder: (context, state) => const StyleScreen(),
        ),
        GoRoute(
          path: 'developer',
          builder: (context, state) => const DeveloperScreen(),
        ),
        GoRoute(
          path: 'review-checks',
          builder: (context, state) => const ReviewPromptsScreen(),
        ),
        GoRoute(
          path: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
        GoRoute(
          path: 'reminders-help',
          builder: (context, state) => const RemindersHelpScreen(),
        ),
      ],
    ),
  ],
);
