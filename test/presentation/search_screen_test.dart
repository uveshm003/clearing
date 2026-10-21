import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 20, 9);

  setUp(() => db = memoryDatabase(now: () => now));

  testWidgets('searches from Today and narrows by status', (tester) async {
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [passport, bank, idea] = await actions.capture(
      'Renew passport\nCall the bank\nPassport photo booth idea',
    );
    await actions.planToday(passport);
    await actions.complete(await actions.planToday(bank));
    await actions.moveToSomeday(idea);

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

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pass');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Renew passport'), findsOneWidget);
    expect(find.text('Passport photo booth idea'), findsOneWidget);
    expect(find.text('Call the bank'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Someday'));
    await tester.pumpAndSettle();
    expect(find.text('Renew passport'), findsNothing);
    expect(find.text('Passport photo booth idea'), findsOneWidget);

    // Done items are searchable too.
    await tester.enterText(find.byType(TextField).first, 'bank');
    await tester.tap(find.widgetWithText(FilterChip, 'Someday'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Call the bank'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
