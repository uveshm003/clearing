import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

/// FR-20: 48 dp touch targets, labels on every control, AA contrast in both
/// themes, and layouts that hold at 200% text.
void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 20, 9);
  late Item rent;
  late Item inboxItem;

  setUp(() async {
    db = memoryDatabase(now: () => now);
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [a, b, c, d] = await actions.capture(
      'Pay rent\nBook the dentist for a check-up\nIdea\nReply to Sam',
    );
    rent = await actions.save(
      (await actions.planToday(
        a,
      )).copyWith(mustDo: true, doneMeans: () => 'Transfer sent'),
    );
    await actions.planOnDate(b, LocalDate(2026, 10, 18), time: 9 * 60);
    await actions.moveToSomeday(c);
    inboxItem = d;
  });

  Future<void> pump(
    WidgetTester tester, {
    ThemeMode theme = ThemeMode.light,
    double textScale = 1,
    String? route,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate.fromDateTime(now)),
          ),
          settingsProvider.overrideWith(
            (ref) => Stream.value(
              AppSettings(
                theme: theme == ThemeMode.dark
                    ? ThemePreference.dark
                    : ThemePreference.light,
              ),
            ),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const ClearingApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (route != null) {
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route);
      await tester.pumpAndSettle();
    }
  }

  Future<void> meetsAll(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  final screens = <String, String? Function()>{
    'Today': () => null,
    'Inbox': () => Routes.inbox,
    'Upcoming': () => Routes.upcoming,
    'Lists': () => Routes.lists,
    'Item': () => Routes.item(rent.id),
    'Clarify': () => Routes.clarify(inboxItem.id),
    'Focus': () => Routes.focus(rent.id),
    'Settings': () => Routes.settings,
    'Backup': () => Routes.backup,
    'Search': () => Routes.search,
    'This week': () => Routes.thisWeek,
    'Someday': () => Routes.someday,
    'Done': () => Routes.archive,
    'Trash': () => Routes.trash,
    'Weekly review': () => Routes.review,
    'Overwhelm reset': () => Routes.reset,
    'Reminders help': () => Routes.remindersHelp,
    'Intro': () => Routes.intro,
    'About': () => Routes.about,
  };

  testWidgets('the capture sheet meets the guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    await tester.tap(find.byTooltip('Capture'));
    await tester.pumpAndSettle();
    await meetsAll(tester);
    handle.dispose();
    await closeDatabase(tester, db);
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final MapEntry(key: name, value: route) in screens.entries) {
      testWidgets('$name meets the guidelines (${theme.name})', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, theme: theme, route: route());
        await meetsAll(tester);
        handle.dispose();
        await closeDatabase(tester, db);
      });
    }
  }

  for (final MapEntry(key: name, value: route) in screens.entries) {
    testWidgets('$name holds at 200% text', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await pump(tester, textScale: 2, route: route());
      // Layout overflow is reported as a test failure by the framework.
      expect(tester.takeException(), isNull);
      await closeDatabase(tester, db);
    });
  }
}
