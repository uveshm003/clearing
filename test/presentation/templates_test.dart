import 'package:clearing/app.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 20, 9);

  setUp(() => db = memoryDatabase(now: () => now));

  testWidgets('an example template becomes a checklist on Today', (
    tester,
  ) async {
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
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).push(Routes.templates);
    await tester.pumpAndSettle();

    expect(find.text('No templates yet'), findsOneWidget);
    await tester.tap(find.text('Packing list'));
    await tester.pumpAndSettle();
    expect(find.text('Template'), findsOneWidget);
    expect(find.text('Toothbrush'), findsOneWidget);

    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();

    await scrollTo(
      tester,
      find.text('Start now'),
      within: find.text('Toothbrush'),
    );
    await tester.tap(find.text('Start now'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Today'));
    await tester.pumpAndSettle();

    final rows = (await tester.runAsync(() => db.select(db.items).get()))!;
    expect(rows.single.title, 'Packing list');
    expect(rows.single.status, ItemStatus.active);
    final subtasks = (await tester.runAsync(
      () => db.select(db.subtasks).get(),
    ))!;
    expect(subtasks, hasLength(5));

    await closeDatabase(tester, db);
  });
}
