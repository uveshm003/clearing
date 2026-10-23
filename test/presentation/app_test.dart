import 'package:clearing/app.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/presentation/widgets/glade_header.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate(2026, 10, 20)),
          ),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('launches to an empty Today with four tabs', (tester) async {
    await pumpApp(tester);

    expect(find.widgetWithText(GladeHeader, 'Today'), findsOneWidget);
    expect(find.text('A clear day'), findsOneWidget);
    for (final tab in ['Today', 'Inbox', 'Upcoming', 'Lists']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
        findsOneWidget,
      );
    }

    await closeDatabase(tester, db);
  });

  testWidgets('switches tabs and opens settings from Lists', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.text('Inbox is empty'), findsOneWidget);

    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
