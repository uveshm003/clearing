import 'package:drift/drift.dart';

import '../domain/day_record.dart';
import '../domain/local_date.dart';
import 'db/database.dart';

/// How each finished day went (written once, at the day's end).
class DayRecordRepository {
  DayRecordRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static DayRecord _toDomain(DayRecordRow row) => DayRecord(
    date: LocalDate.parse(row.id),
    mustDoPlanned: row.mustDoPlanned,
    mustDoDone: row.mustDoDone,
    closed: row.closed,
    allClear: row.allClear,
  );

  /// Oldest first.
  Stream<List<DayRecord>> watchAll() {
    final query = _db.select(_db.dayRecords)
      ..orderBy([(t) => OrderingTerm(expression: t.id)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Future<DayRecord?> get(LocalDate date) async {
    final row = await (_db.select(
      _db.dayRecords,
    )..where((t) => t.id.equals(date.toIso()))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<void> save(DayRecord record) => _db
      .into(_db.dayRecords)
      .insertOnConflictUpdate(
        DayRecordsCompanion.insert(
          id: record.date.toIso(),
          mustDoPlanned: Value(record.mustDoPlanned),
          mustDoDone: Value(record.mustDoDone),
          closed: Value(record.closed),
          allClear: Value(record.allClear),
          updatedAt: _now(),
        ),
      );
}
