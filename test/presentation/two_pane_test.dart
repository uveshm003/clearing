import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/presentation/item/item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 10, 21, 9);

  testWidgets('on a tablet the item opens beside the list', (tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final db = memoryDatabase(now: () => now);
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [rent, stamps] = await actions.capture('Pay rent\nBuy stamps');
    await actions.planToday(rent);
    await actions.planToday(stamps);

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

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(ItemScreen), findsNothing);

    await tester.tap(find.text('Pay rent'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.text('Buy stamps'), findsOneWidget, reason: 'list still shown');

    await tester.tap(find.text('Buy stamps'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(ItemScreen),
        matching: find.text('Buy stamps'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsNothing);

    await closeDatabase(tester, db);
  });
}
