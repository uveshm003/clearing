import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 21, 9); // Wednesday
  final today = LocalDate.fromDateTime(now);

  setUp(() => db = memoryDatabase(now: () => now));

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith((ref) => Stream.value(today)),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Upcoming switches to the week timeline', (tester) async {
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [a, b] = await actions.capture('Dentist\nAnything');
    await actions.planOnDate(a, today.addDays(2), time: 15 * 60);
    await actions.planThisWeek(b);
    await pump(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Upcoming'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Week view'));
    await tester.pumpAndSettle();

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Any day this week'), findsOneWidget);
    expect(find.text('Anything'), findsOneWidget);
    await scrollTo(tester, find.text('Dentist'), within: find.text('Anything'));
    expect(find.text('Dentist'), findsOneWidget);
    await scrollTo(
      tester,
      find.byTooltip('Next week'),
      within: find.text('Dentist'),
      delta: -200,
    );
    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    expect(find.text('Next week'), findsOneWidget);
    expect(find.text('Dentist'), findsNothing);

    await closeDatabase(tester, db);
  });

  testWidgets('a repeating item opens its calendar', (tester) async {
    final items = ItemRepository(db, now: () => now);
    final series = SeriesActions(
      db,
      SeriesRepository(db, now: () => now),
      items,
      ReminderRepository(db, now: () => now),
      now: () => now,
    );
    final actions = ItemActions(items, now: () => now, series: series);
    final [gym] = await actions.capture('Gym');
    final planned = await actions.planOnDate(gym, today);
    await series.startRepeating(
      planned,
      RepeatSeries(
        id: 's1',
        freq: RepeatFrequency.weekly,
        weekdays: const {DateTime.monday, DateTime.wednesday},
        startDate: today,
        onMissed: OnMissed.skip,
        template: const SeriesTemplate(title: ''),
      ),
    );
    await pump(tester);
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).push(Routes.item(gym.id));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('See all dates'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(
      find.bySemanticsLabel('21 October, open now, today'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('26 October, coming up'), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('2 November, coming up'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
