import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/batch_block.dart';
import '../domain/local_date.dart';
import 'db/database.dart';

class BlockRepository {
  BlockRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static BatchBlock _toDomain(BatchBlockRow row) => BatchBlock(
    id: row.id,
    listId: row.listId,
    date: row.date,
    weekday: row.weekday,
    time: row.time,
  );

  Stream<List<BatchBlock>> watchAll() {
    final query = _db.select(_db.batchBlocks)
      ..orderBy([(t) => OrderingTerm(expression: t.time)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Future<List<BatchBlock>> getAll() async => [
    for (final row in await _db.select(_db.batchBlocks).get()) _toDomain(row),
  ];

  Future<BatchBlock> add(
    String listId, {
    LocalDate? date,
    int? weekday,
    required int time,
  }) async {
    final block = BatchBlock(
      id: newId(),
      listId: listId,
      date: date,
      weekday: weekday,
      time: time,
    );
    await _db
        .into(_db.batchBlocks)
        .insert(
          BatchBlocksCompanion.insert(
            id: block.id,
            listId: listId,
            date: Value(date),
            weekday: Value(weekday),
            time: time,
            updatedAt: _now(),
          ),
        );
    return block;
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.batchBlocks)..where((t) => t.id.equals(id))).go();

  /// One-off blocks whose day has passed.
  Future<void> deleteBefore(LocalDate day) => (_db.delete(
    _db.batchBlocks,
  )..where((t) => t.date.isSmallerThanValue(day.toIso()))).go();
}
