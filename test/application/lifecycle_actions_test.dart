import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/lifecycle_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/lifecycle.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late SettingsRepository settings;
  late ItemActions actions;
  late LifecycleActions lifecycle;
  var now = DateTime(2026, 10, 1, 9);

  setUp(() {
    now = DateTime(2026, 10, 1, 9);
    DateTime clock() => now;
    db = memoryDatabase(now: clock);
    items = ItemRepository(db, now: clock);
    settings = SettingsRepository(db, now: clock);
    actions = ItemActions(items, now: clock);
    lifecycle = LifecycleActions(items, settings, now: clock);
  });
  tearDown(() => db.close());

  test('done items are archived after the configured days', () async {
    final [a, b] = await actions.capture('Old\nRecent');
    await actions.complete(a);
    now = DateTime(2026, 10, 6, 9);
    await actions.complete(b);
    now = DateTime(2026, 10, 8, 10);
    await lifecycle.tidy();

    expect((await items.getItem(a.id))!.archived, isTrue);
    expect((await items.getItem(b.id))!.archived, isFalse);
  });

  test('archiving can be turned off', () async {
    await settings.save(const AppSettings(autoArchiveDays: archiveNever));
    final [a] = await actions.capture('Old');
    await actions.complete(a);
    now = DateTime(2027, 1, 1);
    await lifecycle.tidy();
    expect((await items.getItem(a.id))!.archived, isFalse);
  });

  test('Trash keeps items for 30 days, then purges them', () async {
    final [a] = await actions.capture('Mistake');
    await actions.trash(a);
    now = DateTime(2026, 10, 30, 9);
    await lifecycle.tidy();
    expect(await items.getItem(a.id), isNotNull);

    now = DateTime(2026, 10, 31, 9, 1);
    await lifecycle.tidy();
    expect(await items.getItem(a.id), isNull);
  });

  test('restore puts items back where their placement says', () async {
    final [inbox, dated, waiting] = await actions.capture('A\nB\nC');
    final plannedB = await actions.planOnDate(dated, LocalDate(2026, 10, 3));
    final waitingC = await actions.waitFor(waiting, 'Sam');
    for (final item in [inbox, plannedB, waitingC]) {
      await actions.trash(item);
    }
    for (final id in [inbox.id, dated.id, waiting.id]) {
      await lifecycle.restore((await items.getItem(id))!);
    }
    expect((await items.getItem(inbox.id))!.status, ItemStatus.inbox);
    expect((await items.getItem(dated.id))!.status, ItemStatus.active);
    expect((await items.getItem(dated.id))!.doDate, LocalDate(2026, 10, 3));
    expect((await items.getItem(waiting.id))!.status, ItemStatus.waiting);
    expect((await items.getItem(inbox.id))!.trashedAt, isNull);
  });

  test('emptying Trash deletes only trashed items', () async {
    final [a, b] = await actions.capture('Gone\nKept');
    await actions.trash(a);
    expect(await lifecycle.emptyTrash(), 1);
    expect(await items.getItem(a.id), isNull);
    expect(await items.getItem(b.id), isNotNull);
  });

  test('days until purge', () {
    final trashed = DateTime(2026, 10, 1, 9);
    expect(daysUntilPurge(trashed, trashed), 30);
    expect(daysUntilPurge(trashed, DateTime(2026, 10, 30, 10)), 1);
    expect(daysUntilPurge(trashed, DateTime(2026, 11, 2)), 0);
  });
}
