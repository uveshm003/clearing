import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/item_event.dart';
import 'db/database.dart';

/// Items' activity lines.
class EventRepository {
  EventRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static ItemEvent _toDomain(ItemEventRow row) =>
      ItemEvent(id: row.id, itemId: row.itemId, kind: row.kind, at: row.at);

  Future<void> log(String itemId, ItemEventKind kind) async {
    final now = _now();
    await _db
        .into(_db.itemEvents)
        .insert(
          ItemEventsCompanion.insert(
            id: newId(),
            itemId: itemId,
            kind: kind,
            at: now,
            updatedAt: now,
          ),
        );
  }

  /// Oldest first.
  Stream<List<ItemEvent>> watchForItem(String itemId) {
    final query = _db.select(_db.itemEvents)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm(expression: t.at)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  /// Every event since [since], oldest first.
  Future<List<ItemEvent>> since(DateTime since) async {
    final query = _db.select(_db.itemEvents)
      ..where((t) => t.at.isBiggerOrEqualValue(since))
      ..orderBy([(t) => OrderingTerm(expression: t.at)]);
    return [for (final row in await query.get()) _toDomain(row)];
  }

  /// Every event of [kind], oldest first.
  Stream<List<ItemEvent>> watchKind(ItemEventKind kind) {
    final query = _db.select(_db.itemEvents)
      ..where((t) => t.kind.equalsValue(kind))
      ..orderBy([(t) => OrderingTerm(expression: t.at)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }
}
