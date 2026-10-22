import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/reminder.dart';
import 'db/database.dart';
import 'mappers.dart';

class ReminderRepository {
  ReminderRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<List<Reminder>> watchForItem(String itemId) {
    final query = _db.select(_db.reminders)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.fireAt),
        (t) => OrderingTerm(expression: t.offsetMinutes),
      ]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  Future<List<Reminder>> forItem(String itemId) async => [
    for (final row in await (_db.select(
      _db.reminders,
    )..where((t) => t.itemId.equals(itemId))).get())
      row.toDomain(),
  ];

  Future<Reminder?> get(String id) async => (await (_db.select(
    _db.reminders,
  )..where((t) => t.id.equals(id))).getSingleOrNull())?.toDomain();

  /// Every enabled reminder whose item is still open, with that item: the
  /// input to the notification scheduler.
  Future<List<(Item, Reminder)>> enabledWithOpenItems() async {
    final query =
        _db.select(_db.reminders).join([
          innerJoin(_db.items, _db.items.id.equalsExp(_db.reminders.itemId)),
        ])..where(
          _db.reminders.enabled.equals(true) &
              _db.items.status.isNotInValues([
                ItemStatus.done,
                ItemStatus.trashed,
              ]),
        );
    return [
      for (final row in await query.get())
        (
          row.readTable(_db.items).toDomain(),
          row.readTable(_db.reminders).toDomain(),
        ),
    ];
  }

  /// Adds a reminder unless the item already has [maxRemindersPerItem].
  /// Returns null at the limit.
  Future<Reminder?> add(
    String itemId, {
    int? offsetMinutes,
    DateTime? fireAt,
  }) => _db.transaction(() async {
    final existing = await forItem(itemId);
    if (existing.length >= maxRemindersPerItem) return null;
    final reminder = Reminder(
      id: newId(),
      itemId: itemId,
      offsetMinutes: offsetMinutes,
      fireAt: fireAt,
    );
    await _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: reminder.id,
            itemId: itemId,
            offsetMinutes: Value(offsetMinutes),
            fireAt: Value(fireAt),
            updatedAt: _now(),
          ),
        );
    return reminder;
  });

  Future<void> delete(String id) =>
      (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();

  Future<void> snooze(String id, DateTime until) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          snoozedUntil: Value(until),
          updatedAt: Value(_now()),
        ),
      );
}
