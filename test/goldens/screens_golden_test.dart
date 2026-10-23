@Tags(['golden'])
library;

import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';
import 'golden_helpers.dart';

/// Screenshots of each main screen in Morning and Dusk, and at 200% text.
/// Update with `flutter test --tags golden --update-goldens` (on macOS).
void main() {
  setUpAll(loadGladeFonts);

  final now = DateTime(2026, 10, 21, 9);
  final today = LocalDate.fromDateTime(now);

  /// A realistic day: must-dos, other items, one carried over, a few in the
  /// Inbox and one done already.
  Future<AppDatabase> seeded() async {
    final db = memoryDatabase(now: () => now);
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    final [rent, dentist, stamps, reply, photo, done, ...inbox] = await actions
        .capture(
          'Pay rent\nCall the dentist about Thursday\nBuy stamps\n'
          'Reply to Sam’s email\nBook passport photo\nWater the plants\n'
          'Plan Ana’s birthday\nFix the bike light\nLook into a new phone plan',
        );
    await actions.save((await actions.planToday(rent)).copyWith(mustDo: true));
    await actions.save(
      (await actions.planOnDate(
        dentist,
        today,
        time: 14 * 60,
      )).copyWith(mustDo: true),
    );
    await actions.planToday(stamps);
    await actions.planToday(reply);
    await actions.planOnDate(photo, today.addDays(-2));
    await actions.complete(await actions.planToday(done));
    expect(inbox, hasLength(3));
    return db;
  }

  Future<void> pump(
    WidgetTester tester,
    AppDatabase db, {
    required ThemePreference theme,
    double textScale = 1,
    String? route,
  }) async {
    phoneSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith((ref) => Stream.value(today)),
          settingsProvider.overrideWith(
            (ref) => Stream.value(AppSettings(theme: theme)),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const ClearingApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (route != null) {
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
      await tester.pumpAndSettle();
    }
  }

  Future<void> shoot(WidgetTester tester, String name) => expectLater(
    find.byType(ClearingApp),
    matchesGoldenFile('images/$name.png'),
  );

  for (final (mode, theme) in [
    ('morning', ThemePreference.light),
    ('dusk', ThemePreference.dark),
  ]) {
    testWidgets('Today, $mode', (tester) async {
      final db = await seeded();
      await pump(tester, db, theme: theme);
      await shoot(tester, 'today_$mode');
      await closeDatabase(tester, db);
    });

    testWidgets('Inbox, $mode', (tester) async {
      final db = await seeded();
      await pump(tester, db, theme: theme, route: Routes.inbox);
      await shoot(tester, 'inbox_$mode');
      await closeDatabase(tester, db);
    });

    testWidgets('Capture, $mode', (tester) async {
      final db = await seeded();
      await pump(tester, db, theme: theme);
      await tester.tap(find.byTooltip('Capture'));
      await tester.pumpAndSettle();
      for (final thought in ['Renew library card', 'Text Priya back']) {
        await tester.enterText(find.byType(TextField), thought);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }
      await shoot(tester, 'capture_$mode');
      await closeDatabase(tester, db);
    });

    testWidgets('Empty Today, $mode', (tester) async {
      final db = memoryDatabase(now: () => now);
      await pump(tester, db, theme: theme);
      await shoot(tester, 'today_empty_$mode');
      await closeDatabase(tester, db);
    });
  }

  testWidgets('Today at 200% text', (tester) async {
    final db = await seeded();
    await pump(tester, db, theme: ThemePreference.light, textScale: 2);
    await shoot(tester, 'today_large_text');
    await closeDatabase(tester, db);
  });
}
