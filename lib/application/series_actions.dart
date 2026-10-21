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
  });

  final AppDatabase _db;
  final SeriesRepository _series;
  final ItemRepository _items;
  final ReminderRepository _reminders;
  final DateTime Function() _now;

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

    bool skippable(Item item) =>
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
    final next = series.nextOccurrence(onOrAfter: today, after: last);
    if (next == null) return null;
    final item = series.occurrenceOn(next, id: newId(), now: _now());
    await _series.insertOccurrence(item, series.template);
    return item;
  });

  /// Makes [item] the first occurrence of a new series built from [draft],
  /// whose template is taken from the item as it is now.
  Future<RepeatSeries> startRepeating(Item item, RepeatSeries draft) =>
      _db.transaction(() async {
        final series = await _series.save(
          draft.copyWith(template: await _templateOf(item)),
        );
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
    final next = series.nextOccurrence(onOrAfter: _today, after: lastClosed);
    if (next == null || next == open.occurrenceDate) return;
    await _items.save(
      open
          .planOnDate(next, time: open.doTime)
          .copyWith(occurrenceDate: () => next),
    );
  });

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
