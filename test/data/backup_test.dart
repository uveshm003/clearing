import 'dart:convert';

import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/data/backup.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/review_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:clearing/domain/search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<Map<String, List<Map<String, Object?>>>> dump(AppDatabase db) async => {
  for (final table in backupTables)
    table: [
      for (final row
          in await db.customSelect('SELECT * FROM $table ORDER BY rowid').get())
        row.data,
    ],
};

void main() {
  final now = DateTime(2026, 10, 20, 9);
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    source = memoryDatabase(now: () => now);
    target = memoryDatabase(now: () => now);

    final items = ItemRepository(source, now: () => now);
    final reminders = ReminderRepository(source, now: () => now);
    final series = SeriesActions(
      source,
      SeriesRepository(source, now: () => now),
      items,
      reminders,
      now: () => now,
    );
    final actions = ItemActions(items, now: () => now, series: series);
    final lifeAdmin = (await source.select(source.lists).get()).first;

    final [rent, idea, done] = await actions.capture(
      'Pay rent\nLearn cello\nOld task',
      listId: lifeAdmin.id,
    );
    final planned = await actions.planOnDate(
      rent,
      LocalDate(2026, 11, 1),
      time: 9 * 60,
    );
    await items.addSubtask(rent.id, 'Find invoice');
    await reminders.add(rent.id, offsetMinutes: 60);
    await series.startRepeating(
      planned,
      RepeatSeries(
        id: 's1',
        freq: RepeatFrequency.monthly,
        startDate: LocalDate(2026, 11, 1),
        onMissed: OnMissed.carryOver,
        template: const SeriesTemplate(title: ''),
      ),
    );
    await actions.moveToSomeday(idea);
    await actions.complete(done);
    await SettingsRepository(
      source,
      now: () => now,
    ).save(const AppSettings(mustDoCap: 4, theme: ThemePreference.dark));
    await ReviewRepository(source, now: () => now).start(ReviewKind.weekly);
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('export → replace import restores everything exactly', () async {
    final text = await BackupService(source, now: () => now).export();
    final service = BackupService(target, now: () => now);
    await service.import(service.parse(text), ImportMode.replace);

    expect(await dump(target), await dump(source));
  });

  test('imported items are searchable', () async {
    final text = await BackupService(source).export();
    final service = BackupService(target);
    await service.import(service.parse(text), ImportMode.replace);
    final found = await ItemRepository(
      target,
    ).search(const SearchFilter(text: 'invoice'));
    expect(found.single.title, 'Pay rent');
  });

  test('merge keeps local items and doesn’t duplicate system rows', () async {
    final local = await ItemRepository(
      target,
      now: () => now,
    ).capture('Local only');
    final text = await BackupService(source).export();
    final service = BackupService(target);
    await service.import(service.parse(text), ImportMode.merge);

    final titles = {
      for (final row in await target.select(target.items).get()) row.title,
    };
    expect(titles, {'Pay rent', 'Learn cello', 'Old task', 'Local only'});
    expect(await ItemRepository(target).getItem(local.id), isNotNull);

    final lists = await target.select(target.lists).get();
    expect(lists.map((l) => l.kind), [ListKind.lifeAdmin, ListKind.errands]);
    final rent = (await target.select(target.items).get()).firstWhere(
      (i) => i.title == 'Pay rent',
    );
    expect(rent.listId, lists.first.id, reason: 'pointed at the local list');

    final suggestions = await target.select(target.starterSuggestions).get();
    expect(
      suggestions.map((s) => s.title).toSet(),
      hasLength(suggestions.length),
    );
  });

  test('merge keeps whichever copy changed last', () async {
    final text = await BackupService(source).export();
    final service = BackupService(target);
    await service.import(service.parse(text), ImportMode.replace);

    // Edited on this device after the backup was made.
    final later = DateTime(2026, 10, 21);
    final items = ItemRepository(target, now: () => later);
    final rent = (await target.select(target.items).get()).firstWhere(
      (i) => i.title == 'Pay rent',
    );
    await items.save(
      (await items.getItem(rent.id))!.copyWith(title: 'Pay rent and bills'),
    );
    await items.addSubtask(rent.id, 'Added here');

    await service.import(service.parse(text), ImportMode.merge);
    final kept = await items.getItem(rent.id);
    expect(kept!.title, 'Pay rent and bills');
    expect(
      (await items.subtasksOf(rent.id)).map((s) => s.title),
      containsAll(['Find invoice', 'Added here']),
    );
  });

  group('parse', () {
    BackupService service() => BackupService(target);

    test('rejects other files', () {
      expect(
        () => service().parse('hello'),
        throwsA(isA<BackupFormatException>()),
      );
      expect(
        () => service().parse('{"format": "something-else"}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects backups from a newer app', () {
      final newer = jsonEncode({
        'format': backupFormat,
        'version': backupVersion,
        'schemaVersion': 99,
        'tables': {},
      });
      expect(
        () => service().parse(newer),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.message,
            'message',
            contains('newer version'),
          ),
        ),
      );
    });

    test('previews counts', () async {
      final backup = service().parse(
        await BackupService(source, now: () => now).export(),
      );
      expect(backup.count('items'), 3);
      expect(backup.itemsByStatus, {'active': 1, 'someday': 1, 'done': 1});
      expect(backup.exportedAt, now);
    });
  });

  test('file name', () {
    expect(
      backupFileName(DateTime(2026, 3, 7)),
      'clearing-backup-20260307.json',
    );
  });
}
