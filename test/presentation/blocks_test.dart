import 'package:clearing/app.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/lifecycle_actions.dart';
import 'package:clearing/application/notification_scheduler.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/block_repository.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/list_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/batch_block.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/notification_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

class _Gateway extends NoNotifications {
  final scheduled = <int, PlannedNotification>{};

  @override
  Future<Map<int, String?>> pending() async => {
    for (final e in scheduled.entries) e.key: e.value.payload,
  };

  @override
  Future<void> schedule(PlannedNotification n) async => scheduled[n.id] = n;

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}

void main() {
  final now = DateTime(2026, 10, 20, 9); // Tuesday
  final today = LocalDate.fromDateTime(now);
  late AppDatabase db;
  late BlockRepository blocks;
  late ItemActions actions;
  late String errands;

  setUp(() async {
    db = memoryDatabase(now: () => now);
    blocks = BlockRepository(db, now: () => now);
    actions = ItemActions(ItemRepository(db, now: () => now), now: () => now);
    errands = (await db.select(db.lists).get())
        .firstWhere((l) => l.kind == ListKind.errands)
        .id;
  });

  test('blocks fall on their date or weekday', () {
    const weekly = BatchBlock(
      id: 'b',
      listId: 'l',
      weekday: DateTime.saturday,
      time: 600,
    );
    final once = BatchBlock(id: 'c', listId: 'l', date: today, time: 600);
    expect(weekly.datesBetween(today, today.addDays(13)), [
      LocalDate(2026, 10, 24),
      LocalDate(2026, 10, 31),
    ]);
    expect(once.occursOn(today), isTrue);
    expect(once.occursOn(today.addDays(7)), isFalse);
  });

  test('a block nudges at its time when its list has things to do', () async {
    final gateway = _Gateway();
    final scheduler = NotificationScheduler(
      gateway,
      ReminderRepository(db, now: () => now),
      SettingsRepository(db, now: () => now),
      ItemRepository(db, now: () => now),
      now: () => now,
      blocks: blocks,
      lists: ListRepository(db, now: () => now),
    );
    await SettingsRepository(
      db,
      now: () => now,
    ).save(const AppSettings(reviewReminder: false, exportReminderDays: null));
    await blocks.add(errands, weekday: DateTime.saturday, time: 10 * 60);

    await scheduler.reconcile();
    expect(gateway.scheduled, isEmpty, reason: 'nothing to do in Errands');

    final [stamps] = await actions.capture('Buy stamps', listId: errands);
    await actions.planAnytime(stamps);
    await scheduler.reconcile();
    final nudges = gateway.scheduled.values.toList()
      ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
    expect(
      [for (final n in nudges) n.fireAt],
      [DateTime(2026, 10, 24, 10), DateTime(2026, 10, 31, 10)],
    );
    expect(nudges.first.title, 'Errands time');
    expect(payloadKind(nudges.first.payload), NotificationKind.block);
    expect(payloadListId(nudges.first.payload), errands);
  });

  test('a one-off block goes once its day has passed', () async {
    await blocks.add(errands, date: today.addDays(-1), time: 600);
    await blocks.add(errands, date: today, time: 600);
    await blocks.add(errands, weekday: DateTime.monday, time: 600);
    await LifecycleActions(
      ItemRepository(db, now: () => now),
      SettingsRepository(db, now: () => now),
      now: () => now,
      blocks: blocks,
    ).tidy();
    expect(await blocks.getAll(), hasLength(2));
  });

  testWidgets('Today and Upcoming show a block as one entry', (tester) async {
    for (final title in ['Stamps', 'Pharmacy']) {
      final [item] = await actions.capture(title, listId: errands);
      await actions.planAnytime(item);
    }
    await blocks.add(errands, weekday: DateTime.tuesday, time: 10 * 60);

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

    expect(find.text('Blocks'), findsOneWidget);
    expect(find.text('Errands · 10:00 AM'), findsOneWidget);
    expect(find.text('2 to do, in one go'), findsOneWidget);
    expect(find.text('Stamps'), findsNothing, reason: 'one entry, not each');

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Upcoming'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Errands · 10:00 AM'), findsWidgets);

    await tester.tap(find.text('Errands · 10:00 AM').first);
    await tester.pumpAndSettle();
    expect(find.text('Stamps'), findsOneWidget);
    expect(find.text('Every Tuesday at 10:00 AM'), findsOneWidget);

    await closeDatabase(tester, db);
  });
}
