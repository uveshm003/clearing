import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/list_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/subtask.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  var clock = DateTime(2026, 10, 20, 9);
  DateTime now() => clock;

  setUp(() {
    clock = DateTime(2026, 10, 20, 9);
    db = memoryDatabase(now: now);
  });
  tearDown(() => db.close());

  group('ItemRepository', () {
    late ItemRepository items;
    setUp(() => items = ItemRepository(db, now: now));

    test('capture saves a trimmed title to the inbox', () async {
      final item = await items.capture('  Buy stamps \n');
      expect(item.title, 'Buy stamps');
      expect(item.status, ItemStatus.inbox);
      expect(await items.getItem(item.id), item);
      expect(await items.watchCount(ItemStatus.inbox).first, 1);
    });

    test('save round-trips every field and stamps updatedAt', () async {
      final item = await items.capture('Book MOT');
      clock = clock.add(const Duration(hours: 1));
      final edited = item.copyWith(
        status: ItemStatus.active,
        notes: () => 'Garage on Elm St',
        doneMeans: () => 'Booking confirmed',
        horizon: () => WhenHorizon.today,
        horizonSetOn: () => LocalDate(2026, 10, 20),
        doDate: () => LocalDate(2026, 10, 22),
        doTime: () => 9 * 60 + 30,
        deadline: () => LocalDate(2026, 10, 31),
        mustDo: true,
        waitingOn: () => 'Sam',
        followUpDate: () => LocalDate(2026, 10, 25),
      );
      final saved = await items.save(edited);
      expect(saved.updatedAt, clock);
      expect(await items.getItem(item.id), saved);
    });

    test('watchOpen excludes done and trashed items', () async {
      final a = await items.capture('a');
      final b = await items.capture('b');
      final c = await items.capture('c');
      await items.save(b.copyWith(status: ItemStatus.done));
      await items.save(c.copyWith(status: ItemStatus.trashed));
      expect((await items.watchOpen().first).map((i) => i.id), [a.id]);
    });

    test('tracks subtask progress per item', () async {
      final item = await items.capture('Pack');
      final s1 = await items.addSubtask(item.id, 'Passport');
      await items.addSubtask(item.id, 'Charger');
      await items.saveSubtask(s1.copyWith(done: true));
      final progress = await items.watchSubtaskProgress().first;
      expect(progress[item.id].toString(), '1 of 2');
      expect((await items.watchSubtasks(item.id).first).map((s) => s.title), [
        'Passport',
        'Charger',
      ]);
    });
  });

  group('ListRepository', () {
    late ListRepository lists;
    setUp(() => lists = ListRepository(db, now: now));

    test('creates user lists after the system lists', () async {
      await lists.create('Garden');
      final all = await lists.watchAll().first;
      expect(all.map((l) => l.name), ['Life Admin', 'Errands', 'Garden']);
    });

    test('system lists can be renamed and hidden but not deleted', () async {
      final lifeAdmin = (await lists.watchAll().first).first;
      await lists.save(lifeAdmin.copyWith(name: 'Paperwork', archived: true));
      final updated = (await lists.watchAll().first).first;
      expect((updated.name, updated.archived), ('Paperwork', true));
      expect(() => lists.delete(updated), throwsArgumentError);
    });

    test('deleting a user list keeps its items, unfiled', () async {
      final items = ItemRepository(db, now: now);
      final garden = await lists.create('Garden');
      final item = await items.capture('Mow lawn', listId: garden.id);
      await lists.delete(garden);
      expect((await items.getItem(item.id))!.listId, isNull);
    });
  });

  group('SettingsRepository', () {
    test('returns defaults when empty and persists changes', () async {
      final settings = SettingsRepository(db, now: now);
      expect(await settings.watch().first, const AppSettings());
      final changed = const AppSettings().copyWith(mustDoCap: 2);
      await settings.save(changed);
      expect(await settings.watch().first, changed);
    });
  });

  test('SubtaskProgress reports completion', () {
    expect(const SubtaskProgress(0, 0).isComplete, isFalse);
    expect(const SubtaskProgress(2, 2).isComplete, isTrue);
  });
}
