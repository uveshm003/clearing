import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

/// Every main screen in Hindi, and laid out right to left, without errors
/// or overflow (the framework fails the test on either).
void main() {
  final now = DateTime(2026, 10, 21, 9);
  final today = LocalDate.fromDateTime(now);
  late AppDatabase db;
  late Item rent;
  late Item inboxItem;

  setUp(() async {
    db = memoryDatabase(now: () => now);
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [a, b, c] = await actions.capture(
      'Pay rent\nBuy stamps\nReply to Sam',
    );
    rent = await actions.save(
      (await actions.planToday(a)).copyWith(mustDo: true),
    );
    await actions.planOnDate(b, today.addDays(2), time: 9 * 60);
    inboxItem = c;
  });

  final routes = <String, String Function()>{
    'Today': () => Routes.today,
    'Inbox': () => Routes.inbox,
    'Upcoming': () => Routes.upcoming,
    'Lists': () => Routes.lists,
    'Item': () => Routes.item(rent.id),
    'Clarify': () => Routes.clarify(inboxItem.id),
    'Settings': () => Routes.settings,
    'Backup': () => Routes.backup,
    'FAQ': () => Routes.faq,
    'Review': () => Routes.review,
    'Reset': () => Routes.reset,
    'Search': () => Routes.search,
  };

  Future<void> pump(
    WidgetTester tester, {
    Locale? locale,
    TextDirection? direction,
    required String route,
  }) async {
    phone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith((ref) => Stream.value(today)),
        ],
        child: ClearingApp(locale: locale, debugTextDirection: direction),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route);
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: name, value: route) in routes.entries) {
    testWidgets('$name in Hindi', (tester) async {
      await pump(tester, locale: const Locale('hi'), route: route());
      expect(tester.takeException(), isNull);
      expect(find.text('Today'), findsNothing, reason: 'no English left');
      await closeDatabase(tester, db);
    });

    testWidgets('$name right to left', (tester) async {
      await pump(tester, direction: TextDirection.rtl, route: route());
      expect(tester.takeException(), isNull);
      await closeDatabase(tester, db);
    });
  }

  testWidgets('dates follow the language', (tester) async {
    await pump(tester, locale: const Locale('hi'), route: Routes.today);
    expect(find.text('आज'), findsWidgets);
    expect(find.textContaining('बुधवार'), findsOneWidget, reason: 'Wednesday');
    await closeDatabase(tester, db);
  });
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}
