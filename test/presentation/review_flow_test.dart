import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 25, 18);
  final today = LocalDate.fromDateTime(now);

  setUp(() => db = memoryDatabase(now: () => now));

  Future<void> pumpApp(WidgetTester tester) async {
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

  Future<void> openReview(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly review'));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }

  testWidgets('a review walks every step and resumes where it was left', (
    tester,
  ) async {
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [_, _, week, waiting, soon] = await actions.capture(
      'Book flights\nOld magazine\nClean gutters\nQuote from builder\nDentist',
    );
    await actions.planThisWeek(week);
    await actions.waitFor(waiting, 'Ana');
    await actions.planOnDate(soon, today.addDays(2), time: 9 * 60);

    await pumpApp(tester);
    await openReview(tester);
    // Quick or full: this one is full.
    expect(find.text('How long have you got?'), findsOneWidget);
    await tester.tap(find.text('Full'));
    await tester.pumpAndSettle();
    expect(find.text('Empty your head'), findsOneWidget);
    await next(tester);

    // Inbox: one planned, one skipped.
    expect(find.text('Book flights'), findsOneWidget);
    expect(
      find.text('2 left in the inbox. Where does this one go?'),
      findsOneWidget,
    );
    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();
    expect(find.text('Old magazine'), findsOneWidget);
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Inbox clear'), findsOneWidget);
    await next(tester);

    expect(find.text('Last week’s open items'), findsOneWidget);
    expect(find.text('Clean gutters'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Clean gutters'),
        matching: find.byTooltip('Let go to Someday'),
      ),
    );
    await tester.pumpAndSettle();
    await next(tester);

    // Leave mid-way, then come back.
    expect(find.text('Waiting on'), findsOneWidget);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await openReview(tester);
    expect(find.text('Picking up where you left off.'), findsOneWidget);
    expect(find.text('Waiting on'), findsOneWidget);
    expect(find.text('Quote from builder'), findsOneWidget);
    await next(tester);

    expect(find.text('The next 7 days'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
    await next(tester);

    expect(find.text('Someday'), findsOneWidget);
    await next(tester);

    expect(find.text('1 cleared · 1 planned'), findsOneWidget);
    expect(find.text('1 skipped for another time.'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    // Finished reviews start fresh.
    await openReview(tester);
    expect(find.text('How long have you got?'), findsOneWidget);
    expect(find.text('Picking up where you left off.'), findsNothing);

    final rows = (await tester.runAsync(() => db.select(db.items).get()))!;
    final byTitle = {for (final r in rows) r.title: r.status};
    expect(byTitle['Clean gutters'], ItemStatus.someday);
    expect(byTitle['Old magazine'], ItemStatus.inbox);

    await closeDatabase(tester, db);
  });

  testWidgets('a quick review is just the inbox and next week', (tester) async {
    await pumpApp(tester);
    await openReview(tester);
    await tester.tap(find.text('Quick (about 5 minutes)'));
    await tester.pumpAndSettle();
    expect(find.text('Inbox clear'), findsOneWidget);
    await next(tester);
    expect(find.text('The next 7 days'), findsOneWidget);
    await next(tester);
    expect(find.text('Look back'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await closeDatabase(tester, db);
  });
}
