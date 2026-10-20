import 'package:collection/collection.dart';

import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'today_rules.dart';

/// How far ahead the agenda looks (PRD §3.1).
const upcomingDays = 30;

typedef UpcomingView = ({
  List<(LocalDate, List<Item>)> days,
  List<Item> waiting,
});

/// Active items dated after today within [upcomingDays], grouped by day, plus
/// everything Waiting.
UpcomingView buildUpcoming(Iterable<Item> items, LocalDate today) {
  final horizon = today.addDays(upcomingDays);
  final dated = items.where((i) {
    final date = i.doDate;
    return i.status == ItemStatus.active &&
        date != null &&
        date.isAfter(today) &&
        !date.isAfter(horizon);
  });
  final byDay = groupBy(dated, (Item i) => i.doDate!);
  final days = byDay.keys.sorted((a, b) => a.compareTo(b));
  return (
    days: [for (final day in days) (day, byDay[day]!..sort(compareTodayOrder))],
    waiting: items
        .where((i) => i.status == ItemStatus.waiting)
        .sorted(_byFollowUp),
  );
}

/// Earliest follow-up first; items without one go last.
int _byFollowUp(Item a, Item b) => switch ((a.followUpDate, b.followUpDate)) {
  (final x?, final y?) => x.compareTo(y),
  (_?, null) => -1,
  (null, _?) => 1,
  (null, null) => a.createdAt.compareTo(b.createdAt),
};
