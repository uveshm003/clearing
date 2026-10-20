import 'package:clearing/app.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 20, 9);

  setUp(() => db = memoryDatabase(now: () => now));

  Future<void> pumpApp(WidgetTester tester) async {
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
  }

  Future<void> capture(WidgetTester tester, List<String> thoughts) async {
    await tester.tap(find.byTooltip('Capture'));
    await tester.pumpAndSettle();
    for (final thought in thoughts) {
      await tester.enterText(find.byType(TextField), thought);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Saved ${thoughts.length}'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('capture → clarify → Today → complete', (tester) async {
    await pumpApp(tester);

    // Burst capture: the sheet stays open between thoughts.
    await capture(tester, ['Renew passport', 'Learn the cello']);

    await tapTab(tester, 'Inbox');
    expect(find.text('Renew passport'), findsOneWidget);
    expect(find.text('Learn the cello'), findsOneWidget);

    // Clarify the first into Today.
    await tester.tap(find.text('Renew passport'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, there’s something to do'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Book passport photo');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No, I’ll do it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Must-do today'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    // Clarify the second as an idea.
    await tester.tap(find.text('Learn the cello'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No, keep it as an idea'));
    await tester.pumpAndSettle();
    expect(find.text('Inbox is empty'), findsOneWidget);

    await tapTab(tester, 'Today');
    expect(find.text('Must-do'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Book passport photo'), findsOneWidget);
    expect(find.text('Learn the cello'), findsNothing);

    // Complete it, then undo, then complete again.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('A clear day'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Book passport photo'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final items = await tester.runAsync(() => db.select(db.items).get());
    final byTitle = {for (final i in items!) i.title: i.status};
    expect(byTitle, {
      'Book passport photo': ItemStatus.done,
      'Learn the cello': ItemStatus.someday,
    });

    await closeDatabase(tester, db);
  });

  testWidgets('skipping every optional step still places the item', (
    tester,
  ) async {
    await pumpApp(tester);
    await capture(tester, ['Call the bank']);
    await tapTab(tester, 'Inbox');

    await tester.tap(find.text('Call the bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, there’s something to do'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox is empty'), findsOneWidget);
    final [row] = (await tester.runAsync(() => db.select(db.items).get()))!;
    expect(row.status, ItemStatus.active);
    expect(row.whenHorizon, WhenHorizon.anytime);

    await closeDatabase(tester, db);
  });

  testWidgets('a hardware Enter saves; Shift+Enter adds a line', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Capture'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Water plants');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved 1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Buy soil');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved 1'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
