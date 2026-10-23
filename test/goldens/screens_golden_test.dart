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
  late String rentId;
  late String inboxId;

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
    rentId = rent.id;
    inboxId = inbox.first.id;
    await actions.planOnDate(
      (await actions.capture('Gym'))[0],
      today.addDays(1),
      time: 7 * 60,
    );
    await actions.planOnDate(
      (await actions.capture('Dinner with Priya'))[0],
      today.addDays(3),
      time: 19 * 60 + 30,
    );
    await actions.waitFor(
      (await actions.capture('Quote from builder'))[0],
      'Ana',
    );
    return db;
  }

  Future<void> pump(
    WidgetTester tester,
    AppDatabase db, {
    required ThemePreference theme,
    double textScale = 1,
    String? route,
    Size size = const Size(1080, 2340),
    double pixelRatio = 2.625,
    bool tips = false,
  }) async {
    phoneSurface(tester, size: size);
    tester.view.devicePixelRatio = pixelRatio;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith((ref) => Stream.value(today)),
          settingsProvider.overrideWith(
            (ref) => Stream.value(AppSettings(theme: theme, showTips: tips)),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
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

  final screens = <(String, ThemePreference, String Function())>[
    ('item', ThemePreference.light, () => Routes.item(rentId)),
    ('clarify', ThemePreference.dark, () => Routes.clarify(inboxId)),
    ('upcoming', ThemePreference.light, () => Routes.upcoming),
    ('lists', ThemePreference.dark, () => Routes.lists),
    ('settings', ThemePreference.light, () => Routes.settings),
    ('focus', ThemePreference.light, () => Routes.focus(rentId)),
    ('review', ThemePreference.dark, () => Routes.review),
  ];
  for (final (name, theme, route) in screens) {
    testWidgets('$name screen', (tester) async {
      final db = await seeded();
      await pump(tester, db, theme: theme);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route());
      await tester.pumpAndSettle();
      await shoot(tester, name);
      await closeDatabase(tester, db);
    });
  }

  testWidgets('a tip on Today', (tester) async {
    final db = await seeded();
    await pump(tester, db, theme: ThemePreference.light, tips: true);
    await shoot(tester, 'tip');
    await closeDatabase(tester, db);
  });

  for (final (name, theme, route, nexts) in [
    ('welcome', ThemePreference.light, Routes.welcome, 0),
    ('welcome_today', ThemePreference.dark, Routes.welcome, 3),
    ('welcome_setup', ThemePreference.light, Routes.welcome, 6),
    ('help', ThemePreference.light, Routes.help, 0),
    ('guide', ThemePreference.dark, Routes.guide('time'), 0),
  ]) {
    testWidgets('$name screen', (tester) async {
      final db = memoryDatabase(now: () => now);
      await pump(tester, db, theme: theme);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route);
      await tester.pumpAndSettle();
      for (var i = 0; i < nexts; i++) {
        await tester.tap(
          find.widgetWithText(FilledButton, i == 0 ? 'Show me around' : 'Next'),
        );
        await tester.pumpAndSettle();
      }
      await shoot(tester, name);
      await closeDatabase(tester, db);
    });
  }

  testWidgets('tablet, two panes', (tester) async {
    final db = await seeded();
    await pump(
      tester,
      db,
      theme: ThemePreference.light,
      size: const Size(2560, 1600),
      pixelRatio: 2,
    );
    await tester.tap(find.text('Pay rent'));
    await tester.pumpAndSettle();
    await shoot(tester, 'tablet');
    await closeDatabase(tester, db);
  });

  testWidgets('Today at 200% text', (tester) async {
    final db = await seeded();
    await pump(tester, db, theme: ThemePreference.light, textScale: 2);
    await shoot(tester, 'today_large_text');
    await closeDatabase(tester, db);
  });
}
