import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/item_list.dart';
import '../domain/starter_suggestion.dart';
import 'db/database.dart';
import 'mappers.dart';

class ListRepository {
  ListRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// All lists, hidden ones included, in display order.
  Stream<List<ItemList>> watchAll() {
    final query = _db.select(_db.lists)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  Future<ItemList> create(String name) async {
    final now = _now();
    final list = ItemList(
      id: newId(),
      name: name.trim(),
      kind: ListKind.user,
      sortOrder: now.millisecondsSinceEpoch.toDouble(),
    );
    await _db
        .into(_db.lists)
        .insert(
          ListsCompanion.insert(
            id: list.id,
            name: list.name,
            kind: list.kind,
            sortOrder: Value(list.sortOrder),
            updatedAt: now,
          ),
        );
    return list;
  }

  Future<void> save(ItemList list) =>
      (_db.update(_db.lists)..where((t) => t.id.equals(list.id))).write(
        ListsCompanion(
          name: Value(list.name),
          icon: Value(list.icon),
          sortOrder: Value(list.sortOrder),
          archived: Value(list.archived),
          updatedAt: Value(_now()),
        ),
      );

  /// Deletes a user list; its items stay, unfiled. System lists can only be
  /// hidden (FR-05).
  Future<void> delete(ItemList list) async {
    if (list.isSystem) {
      throw ArgumentError.value(
        list.kind,
        'list',
        'System lists cannot be deleted',
      );
    }
    await (_db.delete(_db.lists)..where((t) => t.id.equals(list.id))).go();
  }

  // Starter suggestions (FR-06)

  Stream<List<StarterSuggestion>> watchSuggestions() {
    final query = _db.select(_db.starterSuggestions)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  Future<void> addSuggestion(String title) async {
    final now = _now();
    await _db
        .into(_db.starterSuggestions)
        .insert(
          StarterSuggestionsCompanion.insert(
            id: newId(),
            title: title.trim(),
            userCreated: const Value(true),
            sortOrder: Value(now.millisecondsSinceEpoch.toDouble()),
            updatedAt: now,
          ),
        );
  }

  Future<void> saveSuggestion(StarterSuggestion suggestion) =>
      (_db.update(
        _db.starterSuggestions,
      )..where((t) => t.id.equals(suggestion.id))).write(
        StarterSuggestionsCompanion(
          title: Value(suggestion.title),
          enabled: Value(suggestion.enabled),
          updatedAt: Value(_now()),
        ),
      );

  Future<void> deleteSuggestion(String id) =>
      (_db.delete(_db.starterSuggestions)..where((t) => t.id.equals(id))).go();
}
