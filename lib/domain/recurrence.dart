import 'dart:math';

import 'enums.dart';
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
