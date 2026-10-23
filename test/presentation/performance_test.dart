import 'package:clearing/app.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/mappers.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/today_rules.dart';
import 'package:clearing/presentation/widgets/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// PRD §9: Today renders 500 items without jank. Rows are built lazily, and
/// Today loads only its own items, however many others exist.
void main() {
  final now = DateTime(2026, 10, 21, 9);
  final today = LocalDate.fromDateTime(now);

  List<Item> items({required int onToday, required int elsewhere}) => [
    for (var i = 0; i < onToday + elsewhere; i++)
      Item(
        id: 'i$i',
        title: 'Item $i',
        status: i < onToday ? ItemStatus.active : ItemStatus.someday,
        doDate: i < onToday ? today : null,
        sortOrder: i.toDouble(),
        createdAt: now,
        updatedAt: now,
      ),
  ];

  test('building Today from 5,500 items takes a few milliseconds', () {
    final all = items(onToday: 500, elsewhere: 5000);
    final watch = Stopwatch()..start();
    final view = buildTodayView(all, today);
    watch.stop();
    expect(view.alsoToday, hasLength(500));
    expect(watch.elapsedMilliseconds, lessThan(50));
  });

  testWidgets('Today with 500 items builds only the rows on screen', (
    tester,
  ) async {
    final db = memoryDatabase(now: () => now);
    await db.batch(
      (b) => b.insertAll(db.items, [
        for (final item in items(onToday: 500, elsewhere: 5000))
          item.toCompanion(),
      ]),
    );

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

    // "Also today" collapses after 5; show all 500, then count built rows.
    await tester.tap(find.text('Show 495 more'));
    await tester.pumpAndSettle();
    final built = find.byType(ItemTile, skipOffstage: false).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(40), reason: 'rows off screen must not be built');

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, -3000),
      3000,
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(ItemTile, skipOffstage: false).evaluate().length,
      lessThan(40),
    );

    await closeDatabase(tester, db);
  });
}
