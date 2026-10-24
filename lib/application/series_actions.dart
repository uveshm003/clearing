import 'package:collection/collection.dart';

import '../core/ids.dart';
import '../data/db/database.dart';
import '../data/item_repository.dart';
import '../data/reminder_repository.dart';
import '../data/series_repository.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/item_transitions.dart';
import '../domain/local_date.dart';
import '../domain/recurrence.dart';
import '../domain/repeat_series.dart';

/// Use cases for repeating items (FR-10, PRD §8.4).
///
/// The invariant is one open occurrence per series: the next one is only
/// created once the current one is completed, deleted or skipped, so missed
/// days never turn into a backlog.
class SeriesActions {
  SeriesActions(
    this._db,
    this._series,
    this._items,
    this._reminders, {
    required this._now,
    this._weekStart,
  });

  final AppDatabase _db;
  final SeriesRepository _series;
  final ItemRepository _items;
  final ReminderRepository _reminders;
  final DateTime Function() _now;

  /// The first day of the week, for flexible routines; Monday if absent.
  final Future<int> Function()? _weekStart;

  LocalDate get _today => LocalDate.fromDateTime(_now());

  static bool _isOpen(Item item) =>
      item.status != ItemStatus.done && item.status != ItemStatus.trashed;

  /// AdvanceSeries: runs at app start, at local midnight and on boot.
  Future<void> advanceAll() async {
    for (final series in await _series.getAll()) {
      await advance(series.id);
    }
  }

  /// Applies the on-missed rule to the open occurrence and creates the next
  /// one if none is open. Returns the created occurrence, if any.
  Future<Item?> advance(String seriesId) => _db.transaction(() async {
    final series = await _series.get(seriesId);
    if (series == null || series.paused) return null;
    final today = _today;
    final all = await _series.occurrences(seriesId);
    final open = all.where(_isOpen).toList();
    if (series.isFlexible) return _advanceFlexible(series, all, open, today);

    // An after-completion series has no fixed dates to miss: its open
    // occurrence just waits until done.
    bool skippable(Item item) =>
        !series.isAfterCompletion &&
        series.onMissed == OnMissed.skip &&
        (item.doDate?.isBefore(today) ?? false);
    if (open.isNotEmpty) {
      if (!open.every(skippable)) return null;
      // Skipped quietly, but into Trash rather than gone, so nothing is
      // permanently deleted without an explicit action (FR-18).
      for (final item in open) {
        await _items.save(item.trash(_now()));
      }
    }

    final last = all.map((i) => i.occurrenceDate).nonNulls.maxOrNull;
    final next = series.isAfterCompletion
        ? _nextAfterCompletion(series, all) ??
              (all.isEmpty ? series.nextOccurrence(onOrAfter: today) : null)
        : series.nextOccurrence(onOrAfter: today, after: last);
    if (next == null) return null;
    final item = series.occurrenceOn(next, id: newId(), now: _now());
    await _series.insertOccurrence(item, series.template);
    return item;
  });

  /// A flexible routine (FR-10b): "3 times a week, any days". While this
  /// week's target isn't met, the next occurrence waits in This week; once
  /// it is, the next starts on the first day of next week. A week that
  /// falls short is simply a new week: nothing is carried as a debt.
  Future<Item?> _advanceFlexible(
    RepeatSeries series,
    List<Item> all,
    List<Item> open,
    LocalDate today,
  ) async {
    if (open.isNotEmpty) return null;
    final weekStart = await _weekStart?.call() ?? DateTime.monday;
    final thisWeek = today.startOfWeek(weekStart);
    final doneThisWeek = all
        .where(
          (i) =>
              i.status == ItemStatus.done &&
              i.completedAt != null &&
              !LocalDate.fromDateTime(i.completedAt!).isBefore(thisWeek),
        )
        .length;
    if (series.maxCount case final max?
        when all.where((i) => i.status == ItemStatus.done).length >= max) {
      return null;
    }
    final Item item;
    if (doneThisWeek < series.weeklyTarget!) {
      item = series
          .occurrenceOn(today, id: newId(), now: _now())
          .planThisWeek(today)
          .copyWith(occurrenceDate: () => today);
    } else {
      final next = thisWeek.addDays(7);
      if (series.endDate case final end? when next.isAfter(end)) return null;
      item = series.occurrenceOn(next, id: newId(), now: _now());
    }
    await _series.insertOccurrence(item, series.template);
    return item;
  }

  /// Makes [item] the first occurrence of a new series built from [draft],
  /// whose template is taken from the item as it is now.
  Future<RepeatSeries> startRepeating(Item item, RepeatSeries draft) =>
      _db.transaction(() async {
        final series = await _series.save(
          draft.copyWith(template: await _templateOf(item)),
        );
        if (series.isFlexible) {
          // A flexible routine starts in This week, not on a date.
          return _items
              .save(
                item
                    .planThisWeek(_today)
                    .copyWith(
                      seriesId: () => series.id,
                      occurrenceDate: () => _today,
                    ),
              )
              .then((_) => series);
        }
        final first = series.nextOccurrence(onOrAfter: series.startDate);
        await _items.save(
          (first == null ? item : item.planOnDate(first, time: item.doTime))
              .copyWith(seriesId: () => series.id, occurrenceDate: () => first),
        );
        return series;
      });

  /// Saves a changed rule and moves the open occurrence onto the new
  /// schedule. A rule change always applies to this and future occurrences.
  Future<void> changeRule(RepeatSeries updated) => _db.transaction(() async {
    final series = await _series.save(updated);
    final all = await _series.occurrences(series.id);
    final open = all.where(_isOpen).firstOrNull;
    if (open == null) return;
    final lastClosed = all
        .whereNot(_isOpen)
        .map((i) => i.occurrenceDate)
        .nonNulls
        .maxOrNull;
    final next = series.isAfterCompletion
        ? _nextAfterCompletion(series, all)
        : series.nextOccurrence(onOrAfter: _today, after: lastClosed);
    if (next == null || next == open.occurrenceDate) return;
    await _items.save(
      open
          .planOnDate(next, time: open.doTime)
          .copyWith(occurrenceDate: () => next),
    );
  });

  /// Pausing keeps the open occurrence where it is and creates no new ones;
  /// resuming picks up from today.
  Future<void> setPaused(RepeatSeries series, {required bool paused}) async {
    await _series.save(series.copyWith(paused: paused));
    if (!paused) await advance(series.id);
  }

  /// "This and future": future occurrences start from [occurrence] as it is
  /// now. Its own date stays where it is.
  Future<void> applyToFuture(Item occurrence) async {
    final seriesId = occurrence.seriesId;
    if (seriesId == null) return;
    final series = await _series.get(seriesId);
    if (series == null) return;
    await _series.save(
      series.copyWith(template: await _templateOf(occurrence)),
    );
  }

  /// Ends the series. Its items, including [occurrence], stay as ordinary
  /// items.
  Future<Item> stopRepeating(Item occurrence) => _db.transaction(() async {
    final seriesId = occurrence.seriesId;
    if (seriesId != null) await _series.delete(seriesId);
    return _items.save(
      occurrence.copyWith(seriesId: () => null, occurrenceDate: () => null),
    );
  });

  /// After undoing a completion, removes the occurrence that completion
  /// created, so the series is back to one open occurrence.
  Future<void> removeOccurrencesAfter(Item restored) async {
    final seriesId = restored.seriesId;
    final date = restored.occurrenceDate;
    if (seriesId == null || date == null) return;
    for (final item in await _series.occurrences(seriesId)) {
      if (item.id != restored.id &&
          _isOpen(item) &&
          (item.occurrenceDate?.isAfter(date) ?? false)) {
        await _items.deleteForever(item.id);
      }
    }
  }

  /// [interval] units after the last occurrence was done (or deleted);
  /// null before any has been, or once the series has ended.
  LocalDate? _nextAfterCompletion(RepeatSeries series, List<Item> all) {
    final closedOn = all
        .whereNot(_isOpen)
        .map((i) => i.completedAt ?? i.trashedAt ?? i.updatedAt)
        .maxOrNull;
    if (closedOn == null) return null;
    return series.nextAfterCompletion(
      closedOn: LocalDate.fromDateTime(closedOn),
      // Only occurrences actually done count towards the maximum.
      countSoFar: all.where((i) => i.status == ItemStatus.done).length,
    );
  }

  Future<SeriesTemplate> _templateOf(Item item) async {
    final subtasks = await _items.subtasksOf(item.id);
    final reminders = await _reminders.forItem(item.id);
    return SeriesTemplate(
      title: item.title,
      listId: item.listId,
      doTime: item.doTime,
      doneMeans: item.doneMeans,
      subtasks: [for (final s in subtasks) s.title],
      reminderOffsets: [for (final r in reminders) ?r.offsetMinutes],
    );
  }
}
