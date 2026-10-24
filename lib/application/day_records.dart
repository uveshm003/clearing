import '../data/day_record_repository.dart';
import '../data/item_repository.dart';
import '../domain/day_record.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';

/// Writes how each finished day went (§6.2, §5.9), once it's over: what was
/// closed, whether the must-dos were done, whether Today was all clear.
///
/// Worked out afterwards from the items themselves, so nothing needs to be
/// tracked as the day goes.
class DayRecordActions {
  DayRecordActions(this._items, this._records, {required this._now});

  final ItemRepository _items;
  final DayRecordRepository _records;
  final DateTime Function() _now;

  /// How far back a missing day is filled in.
  static const backfillDays = 7;

  /// Records every day up to yesterday that has no record yet, and
  /// refreshes yesterday's. An "all clear" seen live is never undone.
  Future<void> recordThrough() async {
    final today = LocalDate.fromDateTime(_now());
    final yesterday = today.addDays(-1);
    final existing = await _records.watchAll().first;
    final known = {for (final r in existing) r.date: r};
    final last = existing.isEmpty ? null : existing.last.date;
    var from = today.addDays(-backfillDays);
    if (last != null && last.isAfter(from)) from = last;
    if (from.isAfter(yesterday)) from = yesterday;

    final done = await _items.watchDone().first;
    final open = await _items.watchOpen().first;
    for (var day = from; !day.isAfter(yesterday); day = day.addDays(1)) {
      final record = recordFor(day, done: done, open: open);
      final before = known[day];
      await _records.save(
        DayRecord(
          date: day,
          mustDoPlanned: record.mustDoPlanned,
          mustDoDone: record.mustDoDone,
          closed: record.closed,
          allClear: record.allClear || (before?.allClear ?? false),
        ),
      );
    }
  }

  /// Notes that Today was cleared, as it happens.
  Future<void> markAllClear() async {
    final today = LocalDate.fromDateTime(_now());
    final done = await _items.watchDone().first;
    final open = await _items.watchOpen().first;
    final record = recordFor(today, done: done, open: open);
    await _records.save(
      DayRecord(
        date: today,
        mustDoPlanned: record.mustDoPlanned,
        mustDoDone: record.mustDoDone,
        closed: record.closed,
        allClear: true,
      ),
    );
  }
}

/// How [day] went, from the items as they are now.
DayRecord recordFor(
  LocalDate day, {
  required List<Item> done,
  required List<Item> open,
}) {
  final closed = [
    for (final item in done)
      if (item.completedAt case final at?
          when LocalDate.fromDateTime(at) == day)
        item,
  ];
  bool wasOnToday(Item item) {
    if (item.status != ItemStatus.active) return false;
    if (LocalDate.fromDateTime(item.createdAt).isAfter(day)) return false;
    if (item.doDate case final date?) return !date.isAfter(day);
    final setOn = item.horizonSetOn;
    return item.horizon == WhenHorizon.today &&
        setOn != null &&
        !setOn.isAfter(day);
  }

  final left = open.where(wasOnToday).toList();
  final mustDoDone = closed.where((i) => i.mustDo).length;
  return DayRecord(
    date: day,
    mustDoPlanned: mustDoDone + left.where((i) => i.mustDo).length,
    mustDoDone: mustDoDone,
    closed: closed.length,
    allClear: closed.isNotEmpty && left.isEmpty,
  );
}
