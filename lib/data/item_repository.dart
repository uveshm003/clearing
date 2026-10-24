import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';
import '../domain/search_filter.dart';
import '../domain/subtask.dart';
import 'db/database.dart';
import 'mappers.dart';

class ItemRepository {
  ItemRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// All items that are neither done nor trashed.
  Stream<List<Item>> watchOpen() {
    final query = _db.select(_db.items)
      ..where(
        (t) => t.status.isNotInValues([ItemStatus.done, ItemStatus.trashed]),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map(_toDomain);
  }

  /// What Today needs and nothing more (FR-04): active items dated on or
  /// before [today], and undated ones set to Today or This week. Filtering
  /// in the database keeps Today fast however many items exist.
  Stream<List<Item>> watchToday(LocalDate today) {
    final query = _db.select(_db.items)
      ..where(
        (t) =>
            t.status.equalsValue(ItemStatus.active) &
            ((t.doDate.isNotNull() &
                    t.doDate.isSmallerOrEqualValue(today.toIso())) |
                (t.doDate.isNull() &
                    t.whenHorizon.isInValues([
                      WhenHorizon.today,
                      WhenHorizon.thisWeek,
                    ]))),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map(_toDomain);
  }

  /// What Upcoming needs: active items dated after [from] up to [to], and
  /// everything Waiting.
  Stream<List<Item>> watchUpcoming(LocalDate from, LocalDate to) {
    final query = _db.select(_db.items)
      ..where(
        (t) =>
            (t.status.equalsValue(ItemStatus.active) &
                t.doDate.isBiggerThanValue(from.toIso()) &
                t.doDate.isSmallerOrEqualValue(to.toIso())) |
            t.status.equalsValue(ItemStatus.waiting),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map(_toDomain);
  }

  /// Open items per list, counted in the database. With [activeOnly], only
  /// planned ones (what a batch block works through).
  Stream<Map<String, int>> watchListCounts({bool activeOnly = false}) {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([_db.items.listId, count])
      ..where(
        _db.items.listId.isNotNull() &
            (activeOnly
                ? _db.items.status.equalsValue(ItemStatus.active)
                : _db.items.status.isNotInValues([
                    ItemStatus.done,
                    ItemStatus.trashed,
                  ])),
      )
      ..groupBy([_db.items.listId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(_db.items.listId)!: row.read(count) ?? 0,
      },
    );
  }

  Stream<List<Item>> watchByStatus(ItemStatus status) {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equalsValue(status))
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    return query.watch().map(_toDomain);
  }

  /// Open items filed under [listId], including Someday and Waiting ones.
  Stream<List<Item>> watchInList(String listId) {
    final query = _db.select(_db.items)
      ..where(
        (t) =>
            t.listId.equals(listId) &
            t.status.isNotInValues([ItemStatus.done, ItemStatus.trashed]),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map(_toDomain);
  }

  /// When the first item still in the database was captured.
  Future<DateTime?> firstCreatedAt() async {
    final first = _db.items.createdAt.min();
    final query = _db.selectOnly(_db.items)..addColumns([first]);
    return (await query.getSingle()).read(first);
  }

  /// Done items, most recently completed first; archived ones included.
  Stream<List<Item>> watchDone() {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equalsValue(ItemStatus.done))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(_toDomain);
  }

  /// Trashed items, most recently deleted first.
  Stream<List<Item>> watchTrash() {
    final query = _db.select(_db.items)
      ..where((t) => t.status.equalsValue(ItemStatus.trashed))
      ..orderBy([
        (t) => OrderingTerm(expression: t.trashedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(_toDomain);
  }

  /// Archives done items completed before [cutoff]. Returns how many.
  Future<int> archiveDoneBefore(DateTime cutoff) =>
      (_db.update(_db.items)..where(
            (t) =>
                t.status.equalsValue(ItemStatus.done) &
                t.archived.equals(false) &
                t.completedAt.isSmallerThanValue(cutoff),
          ))
          .write(
            ItemsCompanion(
              archived: const Value(true),
              updatedAt: Value(_now()),
            ),
          );

  /// Permanently deletes items trashed before [cutoff]; all of Trash when
  /// null. Returns how many.
  Future<int> purgeTrash({DateTime? before}) =>
      (_db.delete(_db.items)..where(
            (t) =>
                t.status.equalsValue(ItemStatus.trashed) &
                (before == null
                    ? const Constant(true)
                    : t.trashedAt.isSmallerThanValue(before)),
          ))
          .go();

  /// Items matching [filter] (FR-16): best text matches first, otherwise
  /// most recently changed first.
  Future<List<Item>> search(SearchFilter filter) async {
    final match = ftsQuery(filter.text);
    List<String>? ranked;
    if (match != null) {
      final rows = await _db
          .customSelect(
            'SELECT item_id FROM search_fts WHERE search_fts MATCH ? '
            'ORDER BY rank',
            variables: [Variable(match)],
            readsFrom: {_db.items, _db.subtasks},
          )
          .get();
      ranked = [for (final row in rows) row.read<String>('item_id')];
      if (ranked.isEmpty) return const [];
    }

    final query = _db.select(_db.items)
      ..where((t) {
        var where = t.status.isInValues(filter.statuses.toList());
        if (ranked != null) where &= t.id.isIn(ranked);
        if (filter.listId case final listId?) where &= t.listId.equals(listId);
        if (filter.from case final from?) {
          where &= t.doDate.isBiggerOrEqualValue(from.toIso());
        }
        if (filter.to case final to?) {
          where &= t.doDate.isSmallerOrEqualValue(to.toIso());
        }
        if (filter.repeating case final repeating?) {
          where &= repeating ? t.seriesId.isNotNull() : t.seriesId.isNull();
        }
        if (filter.contextId case final contextId?) {
          where &= t.id.isInQuery(
            _db.selectOnly(_db.itemContexts)
              ..addColumns([_db.itemContexts.itemId])
              ..where(_db.itemContexts.contextId.equals(contextId)),
          );
        }
        if (filter.maxEffort case final maxEffort?) {
          where &= t.effort.isSmallerOrEqualValue(maxEffort);
        }
        return where;
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    final items = _toDomain(await query.get());
    if (ranked == null) return items;
    final order = {for (final (i, id) in ranked.indexed) id: i};
    return items..sort((a, b) => order[a.id]!.compareTo(order[b.id]!));
  }

  /// For each item matching [text] in its notes, done-means or steps, a
  /// short excerpt around the match with it marked by ‹ and ›.
  Future<Map<String, String>> snippets(String text) async {
    final match = ftsQuery(text);
    if (match == null) return const {};
    final rows = await _db
        .customSelect(
          "SELECT item_id, snippet(search_fts, -1, '‹', '›', '…', 8) AS s "
          'FROM search_fts WHERE search_fts MATCH ?',
          variables: [Variable('{notes done_means subtasks} : ($match)')],
          readsFrom: {_db.items, _db.subtasks},
        )
        .get();
    return {
      for (final row in rows)
        row.read<String>('item_id'): row.read<String>('s'),
    };
  }

  /// How many items were completed at or after [since].
  Stream<int> watchCompletedSince(DateTime since) {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([count])
      ..where(
        _db.items.status.equalsValue(ItemStatus.done) &
            _db.items.completedAt.isBiggerOrEqualValue(since),
      );
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Stream<int> watchCount(ItemStatus status) {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)
      ..addColumns([count])
      ..where(_db.items.status.equalsValue(status));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Stream<Item?> watchItem(String id) =>
      (_db.select(_db.items)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row?.toDomain());

  Future<Item?> getItem(String id) async => (await (_db.select(
    _db.items,
  )..where((t) => t.id.equals(id))).getSingleOrNull())?.toDomain();

  /// Saves a new item to the Inbox. Only a title is required (FR-01).
  Future<Item> capture(String title, {String? listId}) async {
    final now = _now();
    final item = Item(
      id: newId(),
      title: title.trim(),
      status: ItemStatus.inbox,
      listId: listId,
      // Newest captures sort last, matching the order they were thought of.
      sortOrder: now.millisecondsSinceEpoch.toDouble(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.items).insert(item.toCompanion());
    return item;
  }

  /// Writes [item], stamping `updatedAt`.
  Future<Item> save(Item item) async {
    final saved = item.copyWith(updatedAt: _now());
    await _db.into(_db.items).insertOnConflictUpdate(saved.toCompanion());
    return saved;
  }

  /// Restores an exact previous version, e.g. for undo.
  Future<void> restore(Item item) =>
      _db.into(_db.items).insertOnConflictUpdate(item.toCompanion());

  /// Permanently deletes an item and, by cascade, its subtasks and reminders.
  Future<void> deleteForever(String id) =>
      (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();

  // Subtasks

  Stream<List<Subtask>> watchSubtasks(String itemId) {
    final query = _db.select(_db.subtasks)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  Future<List<Subtask>> subtasksOf(String itemId) async {
    final query = _db.select(_db.subtasks)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return [for (final row in await query.get()) row.toDomain()];
  }

  /// Subtask progress for every item that has subtasks, keyed by item id.
  Stream<Map<String, SubtaskProgress>> watchSubtaskProgress() {
    final total = _db.subtasks.id.count();
    final done = _db.subtasks.id.count(filter: _db.subtasks.done.equals(true));
    final query = _db.selectOnly(_db.subtasks)
      ..addColumns([_db.subtasks.itemId, total, done])
      ..groupBy([_db.subtasks.itemId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(_db.subtasks.itemId)!: SubtaskProgress(
            row.read(done) ?? 0,
            row.read(total) ?? 0,
          ),
      },
    );
  }

  Future<Subtask> addSubtask(String itemId, String title) async {
    final subtask = Subtask(
      id: newId(),
      itemId: itemId,
      title: title.trim(),
      sortOrder: _now().millisecondsSinceEpoch.toDouble(),
    );
    await _db
        .into(_db.subtasks)
        .insert(
          SubtasksCompanion.insert(
            id: subtask.id,
            itemId: itemId,
            title: subtask.title,
            sortOrder: Value(subtask.sortOrder),
            updatedAt: _now(),
          ),
        );
    return subtask;
  }

  Future<void> saveSubtask(Subtask subtask) =>
      (_db.update(_db.subtasks)..where((t) => t.id.equals(subtask.id))).write(
        SubtasksCompanion(
          title: Value(subtask.title),
          done: Value(subtask.done),
          sortOrder: Value(subtask.sortOrder),
          updatedAt: Value(_now()),
        ),
      );

  Future<void> deleteSubtask(String id) =>
      (_db.delete(_db.subtasks)..where((t) => t.id.equals(id))).go();

  static List<Item> _toDomain(List<ItemRow> rows) => [
    for (final row in rows) row.toDomain(),
  ];
}
