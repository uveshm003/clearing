import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/presentation/guidance/onboarding_screen.dart';
import 'package:clearing/presentation/guidance/tip_card.dart';
import 'package:clearing/presentation/widgets/glade_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 10, 21, 9);
  late AppDatabase db;

  setUp(() => db = memoryDatabase(now: () => now));

  Future<void> pump(WidgetTester tester, {String start = Routes.today}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate.fromDateTime(now)),
          ),
          initialLocationProvider.overrideWithValue(start),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<AppSettings> settings(WidgetTester tester) async =>
      (await tester.runAsync(() => SettingsRepository(db).get()))!;

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('welcome', () {
    test('opens only on a fresh install', () async {
      Future<bool> check(AppSettings s, DateTime? first) =>
          shouldWelcome(Future.value(s), Future.value(first));
      expect(await check(const AppSettings(), null), isTrue);
      expect(
        await check(const AppSettings(onboardingDone: true), null),
        isFalse,
      );
      expect(
        await check(const AppSettings(), DateTime(2026)),
        isFalse,
        reason: 'people updating from an older version have items already',
      );
    });

    testWidgets('tour, then setup, then Today', (tester) async {
      await pump(tester, start: Routes.welcome);
      expect(find.text('Close your mental tabs.'), findsOneWidget);

      await tap(tester, find.text('Show me around'));
      for (final title in [
        'Capture it',
        'Decide what it means',
        'Keep Today small',
        'Look back once a week',
        'Private by design',
      ]) {
        expect(find.text(title), findsOneWidget);
        await tap(tester, find.widgetWithText(FilledButton, 'Next'));
      }

      expect(find.text('Make it yours'), findsOneWidget);
      await tap(
        tester,
        find.descendant(
          of: find.byType(SegmentedButton<int>),
          matching: find.text('2'),
        ),
      );
      await tap(
        tester,
        find.descendant(
          of: find.byType(SegmentedButton<int>),
          matching: find.text('Sunday'),
        ),
      );
      await tap(tester, find.text('Standard'));
      await tap(tester, find.text('Start using Clearing'));

      expect(find.text('You’re all set'), findsOneWidget);
      await tap(tester, find.text('Go to Today'));
      expect(find.widgetWithText(GladeHeader, 'Today'), findsOneWidget);

      final saved = await settings(tester);
      expect(saved.onboardingDone, isTrue);
      expect(saved.mustDoCap, 2);
      expect(saved.weekStart, DateTime.sunday);
      expect(saved.notificationIntensity, NotificationIntensity.standard);

      await closeDatabase(tester, db);
    });

    testWidgets('can be skipped straight away', (tester) async {
      await pump(tester, start: Routes.welcome);
      await tap(tester, find.text('Skip the tour'));
      expect(find.widgetWithText(GladeHeader, 'Today'), findsOneWidget);
      expect((await settings(tester)).onboardingDone, isTrue);
      await closeDatabase(tester, db);
    });

    testWidgets('the tour replays from Help without setup', (tester) async {
      await pump(tester);
      GoRouter.of(
        tester.element(find.byType(Scaffold).first),
      ).push(Routes.help);
      await tester.pumpAndSettle();
      await tap(tester, find.text('How Clearing works'));
      for (var i = 0; i < 5; i++) {
        await tap(tester, find.widgetWithText(FilledButton, 'Next'));
      }
      expect(find.text('Private by design'), findsOneWidget);
      expect(find.text('Make it yours'), findsNothing);
      await tap(tester, find.widgetWithText(FilledButton, 'Done'));
      expect(find.text('Help and guides'), findsOneWidget);
      await closeDatabase(tester, db);
    });
  });

  group('tips', () {
    testWidgets('show once, and come back when asked', (tester) async {
      final actions = ItemActions(
        ItemRepository(db, now: () => now),
        now: () => now,
      );
      final [rent] = await actions.capture('Pay rent');
      await actions.planToday(rent);
      await pump(tester);

      expect(find.byType(TipCard), findsOneWidget);
      expect(find.textContaining('Tap the ring'), findsOneWidget);
      await tap(tester, find.text('Got it'));
      expect(find.textContaining('Tap the ring'), findsNothing);
      expect((await settings(tester)).seenTips, contains(Tips.todayRing));

      GoRouter.of(
        tester.element(find.byType(Scaffold).first),
      ).push(Routes.settings);
      await tester.pumpAndSettle();
      await scrollTo(
        tester,
        find.text('Show all tips again'),
        within: find.text('Must-do items per day'),
      );
      await tap(tester, find.text('Show all tips again'));
      expect((await settings(tester)).seenTips, isEmpty);

      await tap(tester, find.text('Show tips as you go'));
      expect((await settings(tester)).showTips, isFalse);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.textContaining('Tap the ring'), findsNothing);

      await closeDatabase(tester, db);
    });
  });

  testWidgets('the help centre opens a guide', (tester) async {
    await pump(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push(Routes.help);
    await tester.pumpAndSettle();
    expect(find.text('Guides'), findsOneWidget);
    await tap(tester, find.text('Capturing thoughts'));
    expect(find.text('Paste a brain-dump'), findsOneWidget);
    await closeDatabase(tester, db);
  });
}
