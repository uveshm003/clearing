import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/notification_scheduler.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Grants permission when asked and counts the asking.
class _PermissionGateway extends NoNotifications {
  var asked = 0;
  var granted = false;

  @override
  Future<bool> areEnabled() async => granted;

  @override
  Future<bool> requestPermission() async {
    asked++;
    return granted = true;
  }

  @override
  Future<bool> canScheduleExact() async => true;
}

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late SeriesRepository series;
  late ItemActions actions;
  late SeriesActions seriesActions;
  late _PermissionGateway gateway;
  final now = DateTime(2026, 10, 20, 9);
  final today = LocalDate.fromDateTime(now);

  setUp(() {
    DateTime clock() => now;
    db = memoryDatabase(now: clock);
    items = ItemRepository(db, now: clock);
    series = SeriesRepository(db, now: clock);
    seriesActions = SeriesActions(
      db,
      series,
      items,
      ReminderRepository(db, now: clock),
      now: clock,
    );
    actions = ItemActions(items, now: clock, series: seriesActions);
    gateway = _PermissionGateway();
  });

  Future<Item> planned(String title, {int? time}) async {
    final [item] = await actions.capture(title);
    return actions.planOnDate(item, today, time: time);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith((ref) => Stream.value(today)),
          notificationGatewayProvider.overrideWithValue(gateway),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  Future<List<Item>> openOccurrences() async => [
    for (final i in await db.select(db.items).get())
      if (i.seriesId != null && i.status == ItemStatus.active)
        await items.getItem(i.id).then((i) => i!),
  ];

  testWidgets('make an item repeat, complete it, and the next appears', (
    tester,
  ) async {
    await planned('Water plants');
    await pumpApp(tester);
    await open(tester, 'Water plants');

    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('Every week on Tue'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Every week on Tue'), findsOneWidget);

    await scrollTo(
      tester,
      find.widgetWithText(FilledButton, 'Done'),
      within: find.text('Repeat'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    final [next] = await openOccurrences();
    expect(next.title, 'Water plants');
    expect(next.doDate, today.addDays(7));

    await closeDatabase(tester, db);
  });

  testWidgets('adding a reminder asks for permission then', (tester) async {
    await planned('Call dentist', time: 14 * 60);
    await pumpApp(tester);
    await open(tester, 'Call dentist');
    expect(gateway.asked, 0, reason: 'never at launch');

    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 h before'));
    await tester.pumpAndSettle();

    expect(gateway.asked, 1);
    expect(find.text('1 h before'), findsOneWidget);
    expect(find.text('Add a reminder'), findsOneWidget);

    await closeDatabase(tester, db);
  });

  testWidgets('leaving an edited repeat asks about future ones', (
    tester,
  ) async {
    final item = await planned('Pay rent');
    await seriesActions.startRepeating(
      item,
      RepeatSeries(
        id: 's1',
        freq: RepeatFrequency.monthly,
        startDate: today,
        onMissed: OnMissed.carryOver,
        template: const SeriesTemplate(title: ''),
      ),
    );
    await pumpApp(tester);
    await open(tester, 'Pay rent');

    await tester.enterText(find.text('Pay rent'), 'Pay rent and bills');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Change future repeats too?'), findsOneWidget);

    await tester.tap(find.text('This and future'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Today'), findsOneWidget);
    expect((await series.get('s1'))!.template.title, 'Pay rent and bills');

    await closeDatabase(tester, db);
  });

  testWidgets('settings show reminder intensity and quiet hours', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Lists'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('Standard'), within: find.text('Today'));
    expect(find.text('Gentle'), findsOneWidget);
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Only reminders you set, with sound.'), findsOneWidget);

    await scrollTo(
      tester,
      find.text('Quiet hours'),
      within: find.text('Standard'),
    );
    expect(find.textContaining('10:00 PM – 7:00 AM'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
