import 'dart:math';

import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'repeat_series.dart';

/// The recurrence engine (FR-10, PRD §8.4). Pure date arithmetic on local
/// calendar dates, so time zones and daylight saving never shift a series.
extension Recurrence on RepeatSeries {
  /// Every occurrence date in order, starting on or after [startDate] and
  /// honouring [endDate] and [maxCount]. Infinite when neither is set.
  Iterable<LocalDate> get occurrences {
    final all = switch (freq) {
      RepeatFrequency.daily => _daily(),
      RepeatFrequency.weekly => _weekly(),
      RepeatFrequency.monthly => _monthly(),
    };
    final end = endDate;
    final bounded = end == null ? all : all.takeWhile((d) => !d.isAfter(end));
    final max = maxCount;
    return max == null ? bounded : bounded.take(max);
  }

  /// The first occurrence on or after [onOrAfter] and, when given, strictly
  /// after [after]. Null once the series has ended.
  ///
  /// Advancing with `onOrAfter: today` is what keeps missed days from
  /// becoming a backlog: past dates are never produced.
  LocalDate? nextOccurrence({required LocalDate onOrAfter, LocalDate? after}) {
    for (final date in occurrences) {
      if (date.isBefore(onOrAfter)) continue;
      if (after != null && !date.isAfter(after)) continue;
      return date;
    }
    return null;
  }

  /// For an after-completion series: the next date, [interval] units after
  /// the day the last occurrence was closed. Null once [endDate] or
  /// [maxCount] ([countSoFar] occurrences so far) is reached.
  LocalDate? nextAfterCompletion({
    required LocalDate closedOn,
    required int countSoFar,
  }) {
    if (maxCount case final max? when countSoFar >= max) return null;
    final next = switch (freq) {
      RepeatFrequency.daily => closedOn.addDays(interval),
      RepeatFrequency.weekly => closedOn.addDays(7 * interval),
      RepeatFrequency.monthly => closedOn.addMonths(interval),
    };
    final end = endDate;
    return end != null && next.isAfter(end) ? null : next;
  }

  /// A new open occurrence on [date], filled in from the template. Its
  /// subtasks and reminders are created alongside it by the caller.
  Item occurrenceOn(
    LocalDate date, {
    required String id,
    required DateTime now,
  }) => Item(
    id: id,
    title: template.title,
    status: ItemStatus.active,
    doneMeans: template.doneMeans,
    doDate: date,
    doTime: template.doTime,
    listId: template.listId,
    seriesId: this.id,
    occurrenceDate: date,
    sortOrder: now.millisecondsSinceEpoch.toDouble(),
    createdAt: now,
    updatedAt: now,
  );

  Iterable<LocalDate> _daily() sync* {
    for (var k = 0; ; k++) {
      yield startDate.addDays(k * interval);
    }
  }

  Iterable<LocalDate> _weekly() sync* {
    final days = (weekdays.isEmpty ? {startDate.weekday} : weekdays).toList()
      ..sort();
    final anchor = startDate.startOfWeek(DateTime.monday);
    for (var week = 0; ; week += interval) {
      for (final weekday in days) {
        final date = anchor.addDays(week * 7 + weekday - 1);
        if (!date.isBefore(startDate)) yield date;
      }
    }
  }

  Iterable<LocalDate> _monthly() sync* {
    final day = monthDay ?? startDate.day;
    for (var k = 0; ; k++) {
      final monthIndex = startDate.month - 1 + k * interval;
      final first = LocalDate(
        startDate.year + monthIndex ~/ 12,
        monthIndex % 12 + 1,
        1,
      );
      final date = LocalDate(
        first.year,
        first.month,
        min(day, first.daysInMonth),
      );
      if (!date.isBefore(startDate)) yield date;
    }
  }
}
