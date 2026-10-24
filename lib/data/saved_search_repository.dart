import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/saved_search.dart';
import '../domain/search_filter.dart';
import 'db/database.dart';

/// Searches kept as smart lists.
class SavedSearchRepository {
  SavedSearchRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static SavedSearch _toDomain(SavedSearchRow row) => SavedSearch(
    id: row.id,
    name: row.name,
    filter: SearchFilter.fromJson(row.filter),
    sortOrder: row.sortOrder,
  );

  Stream<List<SavedSearch>> watchAll() {
    final query = _db.select(_db.savedSearches)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Stream<SavedSearch?> watch(String id) =>
      (_db.select(_db.savedSearches)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toDomain(row));

  Future<SavedSearch> create(String name, SearchFilter filter) async {
    final now = _now();
    final saved = SavedSearch(
      id: newId(),
      name: name.trim(),
      filter: filter,
      sortOrder: now.millisecondsSinceEpoch.toDouble(),
    );
    await _db
        .into(_db.savedSearches)
        .insert(
          SavedSearchesCompanion.insert(
            id: saved.id,
            name: saved.name,
            filter: filter.toJson(),
            sortOrder: Value(saved.sortOrder),
            updatedAt: now,
          ),
        );
    return saved;
  }

  Future<void> rename(String id, String name) =>
      (_db.update(_db.savedSearches)..where((t) => t.id.equals(id))).write(
        SavedSearchesCompanion(
          name: Value(name.trim()),
          updatedAt: Value(_now()),
        ),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.savedSearches)..where((t) => t.id.equals(id))).go();
}
