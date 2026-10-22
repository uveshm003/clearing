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
  final now = DateTime(2026, 10, 20, 9);

  setUp(() => db = memoryDatabase(now: () => now));

  testWidgets('reset ends on the focus view with one item', (tester) async {
    final repo = ItemRepository(db, now: () => now);
    final actions = ItemActions(repo, now: () => now);
    await actions.capture('Pay rent\nSort photos\nReply to Sam');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate.fromDateTime(now)),
          ),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overwhelm reset'));
    await tester.pumpAndSettle();
    expect(find.text('Everything on your mind'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Call the vet');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('What must happen today?'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Pay rent'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Reply to Sam'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Let go of the rest?'), findsOneWidget);
    await tester.tap(find.text('Move to Someday'));
    await tester.pumpAndSettle();

    expect(find.text('Smallest next action'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Open banking app');
    await tester.tap(find.text('Focus on it'));
    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text('Open banking app'), findsOneWidget);

    final statuses = {
      for (final row in (await tester.runAsync(
        () => db.select(db.items).get(),
      ))!)
        row.title: (row.status, row.mustDo),
    };
    expect(statuses, {
      'Pay rent': (ItemStatus.active, true),
      'Reply to Sam': (ItemStatus.active, false),
      'Sort photos': (ItemStatus.someday, false),
      'Call the vet': (ItemStatus.someday, false),
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('One less thing'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
