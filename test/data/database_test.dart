import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/starter_suggestion.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;

  setUp(() {
    db = memoryDatabase();
    items = ItemRepository(db);
  });
  tearDown(() => db.close());

  test('schema matches the Drift table definitions', () async {
    await db.validateDatabaseSchema();
  });

  test('foreign keys are enforced', () async {
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(result.data.values.single, 1);
  });

  test('seeds the system lists and starter suggestions', () async {
    final lists = await db.select(db.lists).get();
    expect(lists.map((l) => (l.name, l.kind)), [
      ('Life Admin', ListKind.lifeAdmin),
      ('Errands', ListKind.errands),
    ]);
    final suggestions = await db.select(db.starterSuggestions).get();
    expect(suggestions, hasLength(defaultStarterSuggestions.length));
  });

  test('deleting an item cascades to subtasks and reminders', () async {
    final item = await items.capture('Pay rent');
    await items.addSubtask(item.id, 'Find invoice');
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: 'r1',
            itemId: item.id,
            offsetMinutes: const Value(0),
            updatedAt: DateTime(2026),
          ),
        );

    await items.deleteForever(item.id);

    expect(await db.select(db.subtasks).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
  });

  test('a reminder needs exactly one of offset or absolute time', () async {
    final item = await items.capture('Call dentist');
    expect(
      () => db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              id: 'r1',
              itemId: item.id,
              updatedAt: DateTime(2026),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  group('search index', () {
    Future<List<String>> search(String query) async {
      final rows = await db
          .customSelect(
            'SELECT item_id FROM search_fts WHERE search_fts MATCH ? ORDER BY rank',
            variables: [Variable(query)],
          )
          .get();
      return [for (final r in rows) r.read<String>('item_id')];
    }

    test('indexes title, notes and done-means, and follows edits', () async {
      final item = await items.capture('Renew passport');
      expect(await search('passport'), [item.id]);

      await items.save(
        item.copyWith(
          title: 'Renew travel document',
          notes: () => 'photos needed',
          doneMeans: () => 'application posted',
        ),
      );
      expect(await search('passport'), isEmpty);
      expect(await search('photos'), [item.id]);
      expect(await search('posted'), [item.id]);
    });

    test('indexes subtasks', () async {
      final item = await items.capture('Tax return');
      final subtask = await items.addSubtask(item.id, 'Gather receipts');
      expect(await search('receipts'), [item.id]);

      await items.saveSubtask(subtask.copyWith(title: 'Gather payslips'));
      expect(await search('receipts'), isEmpty);
      expect(await search('payslips'), [item.id]);

      await items.deleteSubtask(subtask.id);
      expect(await search('payslips'), isEmpty);
    });

    test('ignores diacritics and removes deleted items', () async {
      final item = await items.capture('Café receipt');
      expect(await search('cafe'), [item.id]);
      await items.deleteForever(item.id);
      expect(await search('cafe'), isEmpty);
    });
  });
}
