import 'package:collection/collection.dart';

import 'app_settings.dart';
import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'review_session.dart';
import 'today_rules.dart';

/// The steps of the weekly review (PRD §4.3), in order.
enum ReviewStep {
  emptyHead,
  inbox,
  lastWeek,
  waiting,
  nextWeek,
  someday,
  close,
}

/// A review left unfinished can be resumed for this long.
const reviewResumeWindow = Duration(days: 7);

/// Whether [session] is an unfinished review that should be picked up.
bool canResume(ReviewSession? session, DateTime now) =>
    session != null &&
    !session.isComplete &&
    now.difference(session.startedAt) < reviewResumeWindow;

/// "Last week's open items": This week, and anything carried over on Today.
List<Item> lastWeekOpen(Iterable<Item> items, LocalDate today) => [
  for (final item in items)
    if (isThisWeek(item) ||
        (isOnToday(item, today) && isCarriedOver(item, today)))
      item,
]..sort(compareTodayOrder);

/// Active items dated in the coming seven days, by date.
List<Item> nextSevenDays(Iterable<Item> items, LocalDate today) {
  final until = today.addDays(7);
  return items
      .where(
        (i) =>
            i.status == ItemStatus.active &&
            i.doDate != null &&
            i.doDate!.isAfter(today) &&
            !i.doDate!.isAfter(until),
      )
      .sorted((a, b) {
        final byDate = a.doDate!.compareTo(b.doDate!);
        return byDate != 0 ? byDate : compareTodayOrder(a, b);
      });
}

/// The next review reminder after [now], at the chosen weekday and time.
DateTime nextReviewAt(AppSettings settings, DateTime now) {
  final today = LocalDate.fromDateTime(now);
  final offset = (settings.reviewWeekday - today.weekday) % 7;
  final candidate = today.addDays(offset).atMinutes(settings.reviewTime);
  return candidate.isAfter(now)
      ? candidate
      : today.addDays(offset + 7).atMinutes(settings.reviewTime);
}
