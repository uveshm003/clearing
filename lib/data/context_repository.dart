import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/item_context.dart';
import 'db/database.dart';

/// Contexts and which items have them (FR-22).
class ContextRepository {
  ContextRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static ItemContext _toDomain(ContextRow row) => ItemContext(
    id: row.id,
    name: row.name,
    kind: row.kind,
    sortOrder: row.sortOrder,
  );

  Stream<List<ItemContext>> watchAll() {
    final query = _db.select(_db.contexts)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Future<ItemContext> create(String name) async {
    final now = _now();
    final context = ItemContext(
      id: newId(),
      name: name.trim(),
      kind: ContextKind.user,
      sortOrder: now.millisecondsSinceEpoch.toDouble(),
    );
    await _db
        .into(_db.contexts)
        .insert(
          ContextsCompanion.insert(
            id: context.id,
            name: context.name,
            kind: context.kind,
            sortOrder: Value(context.sortOrder),
            updatedAt: now,
          ),
        );
    return context;
  }

  Future<void> rename(ItemContext context, String name) =>
      (_db.update(_db.contexts)..where((t) => t.id.equals(context.id))).write(
        ContextsCompanion(name: Value(name.trim()), updatedAt: Value(_now())),
      );

  /// Deletes a context; items keep everything else.
  Future<void> delete(String id) =>
      (_db.delete(_db.contexts)..where((t) => t.id.equals(id))).go();

  /// Context ids per item id, for every item that has any.
  Stream<Map<String, Set<String>>> watchByItem() =>
      _db.select(_db.itemContexts).watch().map((rows) {
        final byItem = <String, Set<String>>{};
        for (final row in rows) {
          (byItem[row.itemId] ??= {}).add(row.contextId);
        }
        return byItem;
      });

  Future<Set<String>> forItem(String itemId) async => {
    for (final row in await (_db.select(
      _db.itemContexts,
    )..where((t) => t.itemId.equals(itemId))).get())
      row.contextId,
  };

  /// Makes [contextIds] exactly the item's contexts.
  Future<void> setForItem(String itemId, Set<String> contextIds) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.itemContexts,
        )..where((t) => t.itemId.equals(itemId))).go();
        final now = _now();
        for (final contextId in contextIds) {
          await _db
              .into(_db.itemContexts)
              .insert(
                ItemContextsCompanion.insert(
                  id: '$itemId|$contextId',
                  itemId: itemId,
                  contextId: contextId,
                  updatedAt: now,
                ),
              );
        }
      });
}
