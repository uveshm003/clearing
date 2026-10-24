import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/journal_entry.dart';
import '../domain/local_date.dart';
import 'db/database.dart';

/// Notes of things the user was glad they did.
class JournalRepository {
  JournalRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Newest first.
  Stream<List<JournalEntry>> watchAll() {
    final query = _db.select(_db.journalEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          JournalEntry(id: r.id, date: r.date, body: r.body),
      ],
    );
  }

  Future<void> add(LocalDate date, String body) => _db
      .into(_db.journalEntries)
      .insert(
        JournalEntriesCompanion.insert(
          id: newId(),
          date: date,
          body: body.trim(),
          updatedAt: _now(),
        ),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
}
