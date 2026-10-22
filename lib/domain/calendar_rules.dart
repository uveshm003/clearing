import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'recurrence.dart';
import 'repeat_series.dart';
import 'today_rules.dart';

/// One day of the week timeline (FR-15).
typedef TimelineDay = ({LocalDate day, List<Item> items});

/// The seven days from [weekStart] (a date), with each day's active items:
/// dated ones on their day, and Today items on today. Timed items come first
/// by time. "This week" items have no day, so they're listed separately.
({List<TimelineDay> days, List<Item> anyDay}) weekTimeline(
  Iterable<Item> items, {
  required LocalDate weekStart,
  required LocalDate today,
}) {
  final days = [for (var i = 0; i < 7; i++) weekStart.addDays(i)];
  final byDay = {for (final day in days) day: <Item>[]};
  final anyDay = <Item>[];
  final thisWeek = today.startOfWeek(weekStart.weekday) == weekStart;
  for (final item in items) {
    if (item.status != ItemStatus.active) continue;
    final date = item.doDate;
    if (date != null) {
      byDay[date]?.add(item);
    } else if (item.horizon == WhenHorizon.today) {
      byDay[today]?.add(item);
    } else if (thisWeek && isThisWeek(item)) {
      anyDay.add(item);
    }
  }
  return (
    days: [
      for (final day in days)
        (day: day, items: byDay[day]!..sort(compareTodayOrder)),
    ],
    anyDay: anyDay..sort(compareTodayOrder),
  );
}

/// How a date looks on a series calendar.
enum OccurrenceMark {
  /// Completed.
  done,

  /// Missed and skipped, or deleted.
  skipped,

  /// The current open occurrence.
  open,

  /// A date the rule will produce later.
  planned,
}

/// Marks for every date of [month] (any day in it) that the series touches:
/// what happened to past occurrences, and the dates still to come (FR-15).
/// After-completion series have no fixed future dates, so only the open one
/// shows ahead.
Map<LocalDate, OccurrenceMark> seriesCalendar(
  RepeatSeries series,
  Iterable<Item> occurrences, {
  required LocalDate month,
  required LocalDate today,
}) {
  final first = LocalDate(month.year, month.month, 1);
  final last = LocalDate(month.year, month.month, first.daysInMonth);
  bool inMonth(LocalDate d) => !d.isBefore(first) && !d.isAfter(last);

  final marks = <LocalDate, OccurrenceMark>{};
  var openDate = today;
  for (final item in occurrences) {
    final date = item.occurrenceDate ?? item.doDate;
    if (date == null) continue;
    final mark = switch (item.status) {
      ItemStatus.done => OccurrenceMark.done,
      ItemStatus.trashed => OccurrenceMark.skipped,
      _ => OccurrenceMark.open,
    };
    if (mark == OccurrenceMark.open) openDate = date;
    if (inMonth(date)) marks[date] = mark;
  }
  if (series.isAfterCompletion || series.paused) return marks;
  for (final date in series.occurrences) {
    if (date.isAfter(last)) break;
    if (!date.isAfter(openDate) || !inMonth(date)) continue;
    marks.putIfAbsent(date, () => OccurrenceMark.planned);
  }
  return marks;
}
