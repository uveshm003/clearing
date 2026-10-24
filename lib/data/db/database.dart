import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/ids.dart';
import '../../domain/enums.dart';
import '../../domain/local_date.dart';
import '../../domain/starter_suggestion.dart';
import 'converters.dart';
import 'database.steps.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Items,
    Subtasks,
    Lists,
    Series,
    Reminders,
    Templates,
    StarterSuggestions,
    ReviewSessions,
    Settings,
    BatchBlocks,
    Contexts,
    ItemContexts,
    DayRecords,
    ItemEvents,
    Attachments,
    SavedSearches,
    JournalEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Opens the on-device database file.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'clearing',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ),
  );

  final DateTime Function() _now;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createSearchIndex(this);
      await _seed();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.reminders, schema.reminders.snoozedUntil);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.batchBlocks);
      },
      from3To4: (m, schema) async {
        await m.addColumn(schema.items, schema.items.effort);
        await m.addColumn(schema.items, schema.items.firstStep);
        await m.addColumn(schema.lists, schema.lists.colour);
        await m.addColumn(schema.lists, schema.lists.pinned);
        await m.addColumn(schema.lists, schema.lists.isProject);
        await m.addColumn(schema.lists, schema.lists.outcome);
        await m.addColumn(schema.lists, schema.lists.targetDate);
        await m.addColumn(schema.series, schema.series.weeklyTarget);
        await m.createTable(schema.contexts);
        await m.createTable(schema.itemContexts);
        await m.createIndex(schema.itemContextsItemIdx);
        await m.createTable(schema.dayRecords);
        await m.createTable(schema.itemEvents);
        await m.createIndex(schema.itemEventsItemIdx);
        await m.createTable(schema.attachments);
        await m.createIndex(schema.attachmentsItemIdx);
        await m.createTable(schema.savedSearches);
        await m.createTable(schema.journalEntries);
        await _seedContexts();
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seed() async {
    final now = _now();
    await batch((b) {
      b.insertAll(lists, [
        ListsCompanion.insert(
          id: newId(),
          name: 'Life Admin',
          kind: ListKind.lifeAdmin,
          icon: const Value('receipt_long'),
          sortOrder: const Value(0),
          updatedAt: now,
        ),
        ListsCompanion.insert(
          id: newId(),
          name: 'Errands',
          kind: ListKind.errands,
          icon: const Value('shopping_bag'),
          sortOrder: const Value(1),
          updatedAt: now,
        ),
      ]);
      b.insertAll(starterSuggestions, [
        for (final (i, (title, kind)) in defaultStarterSuggestions.indexed)
          StarterSuggestionsCompanion.insert(
            id: newId(),
            title: title,
            listKind: Value(kind),
            sortOrder: Value(i.toDouble()),
            updatedAt: now,
          ),
      ]);
    });
    await _seedContexts();
  }

  /// The built-in contexts (FR-22); names are shown translated by kind.
  Future<void> _seedContexts() async {
    final now = _now();
    await batch((b) {
      b.insertAll(contexts, [
        for (final (i, (kind, name)) in const [
          (ContextKind.home, 'Home'),
          (ContextKind.out, 'Out'),
          (ContextKind.computer, 'Computer'),
          (ContextKind.phone, 'Phone'),
          (ContextKind.lowEnergy, 'Low energy'),
        ].indexed)
          ContextsCompanion.insert(
            id: newId(),
            name: name,
            kind: kind,
            sortOrder: Value(i.toDouble()),
            updatedAt: now,
          ),
      ]);
    });
  }
}

/// Creates the FTS5 index over item text and subtasks (FR-16), kept in sync by
/// triggers so no Dart code can forget to update it.
Future<void> createSearchIndex(GeneratedDatabase db) async {
  const subtaskText =
      "(SELECT coalesce(group_concat(title, ' '), '') "
      'FROM subtasks WHERE item_id = %s)';
  for (final statement in [
    '''
CREATE VIRTUAL TABLE search_fts USING fts5(
  item_id UNINDEXED, title, notes, done_means, subtasks,
  tokenize = 'unicode61 remove_diacritics 2'
)''',
    '''
CREATE TRIGGER items_search_insert AFTER INSERT ON items BEGIN
  INSERT INTO search_fts (item_id, title, notes, done_means, subtasks)
  VALUES (new.id, new.title, coalesce(new.notes, ''),
          coalesce(new.done_means, ''), '');
END''',
    '''
CREATE TRIGGER items_search_update
AFTER UPDATE OF title, notes, done_means ON items BEGIN
  UPDATE search_fts SET title = new.title, notes = coalesce(new.notes, ''),
    done_means = coalesce(new.done_means, '')
  WHERE item_id = new.id;
END''',
    '''
CREATE TRIGGER items_search_delete AFTER DELETE ON items BEGIN
  DELETE FROM search_fts WHERE item_id = old.id;
END''',
    for (final (event, row) in [
      ('INSERT', 'new'),
      ('UPDATE', 'new'),
      ('DELETE', 'old'),
    ])
      '''
CREATE TRIGGER subtasks_search_${event.toLowerCase()}
AFTER $event ON subtasks BEGIN
  UPDATE search_fts SET subtasks = ${subtaskText.replaceFirst('%s', '$row.item_id')}
  WHERE item_id = $row.item_id;
END''',
  ]) {
    await db.customStatement(statement);
  }
}
