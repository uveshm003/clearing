import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/item.dart';
import '../domain/repeat_series.dart';
import 'db/database.dart';
import 'mappers.dart';

class SeriesRepository {
  SeriesRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<RepeatSeries?> watch(String id) =>
      (_db.select(_db.series)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row?.toDomain());

  Future<RepeatSeries?> get(String id) async => (await (_db.select(
    _db.series,
  )..where((t) => t.id.equals(id))).getSingleOrNull())?.toDomain();

  Future<List<RepeatSeries>> getAll() async => [
    for (final row in await _db.select(_db.series).get()) row.toDomain(),
  ];

  Future<RepeatSeries> save(RepeatSeries series) async {
    await _db
        .into(_db.series)
        .insertOnConflictUpdate(series.toCompanion(_now()));
    return series;
  }

  /// Deletes the rule; its items stay as ordinary items.
  Future<void> delete(String id) =>
      (_db.delete(_db.series)..where((t) => t.id.equals(id))).go();

  /// Every item of the series, in any status, oldest occurrence first.
  Future<List<Item>> occurrences(String seriesId) async {
    final query = _db.select(_db.items)
      ..where((t) => t.seriesId.equals(seriesId))
      ..orderBy([(t) => OrderingTerm(expression: t.occurrenceDate)]);
    return [for (final row in await query.get()) row.toDomain()];
  }

  /// Writes a new occurrence with the template's subtasks and reminders.
  Future<void> insertOccurrence(Item item, SeriesTemplate template) =>
      _db.transaction(() async {
        final now = _now();
        await _db.into(_db.items).insert(item.toCompanion());
        for (final (i, title) in template.subtasks.indexed) {
          await _db
              .into(_db.subtasks)
              .insert(
                SubtasksCompanion.insert(
                  id: newId(),
                  itemId: item.id,
                  title: title,
                  sortOrder: Value(i.toDouble()),
                  updatedAt: now,
                ),
              );
        }
        for (final offset in template.reminderOffsets.toSet()) {
          await _db
              .into(_db.reminders)
              .insert(
                RemindersCompanion.insert(
                  id: newId(),
                  itemId: item.id,
                  offsetMinutes: Value(offset),
                  updatedAt: now,
                ),
              );
        }
      });
}
