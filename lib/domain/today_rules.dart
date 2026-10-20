import 'package:meta/meta.dart';

import 'enums.dart';
import 'item.dart';
import 'local_date.dart';

/// The sections of the Today tab (PRD §3.1, FR-04).
@immutable
class TodayView {
  const TodayView({
    required this.mustDo,
    required this.alsoToday,
    required this.carriedOver,
    required this.thisWeekCount,
  });

  final List<Item> mustDo;
  final List<Item> alsoToday;

  /// Shown quietly and collapsed; never styled as an alarm.
  final List<Item> carriedOver;
  final int thisWeekCount;

  bool get isEmpty =>
      mustDo.isEmpty && alsoToday.isEmpty && carriedOver.isEmpty;
}

/// Whether [item] belongs on Today: an active item set to Today, or with a
/// do-date on or before [today].
bool isOnToday(Item item, LocalDate today) {
  if (item.status != ItemStatus.active) return false;
  final doDate = item.doDate;
  if (doDate != null) return !doDate.isAfter(today);
  return item.horizon == WhenHorizon.today;
}

/// Whether an item on Today was planned for an earlier day.
bool isCarriedOver(Item item, LocalDate today) {
  final doDate = item.doDate;
  if (doDate != null) return doDate.isBefore(today);
  final setOn = item.horizonSetOn;
  return setOn != null && setOn.isBefore(today);
}

bool isThisWeek(Item item) =>
    item.status == ItemStatus.active && item.when == When.thisWeek;

/// Builds the Today view from all items.
///
/// Must-do items stay in Must-do even when carried over, so the user's chosen
/// priorities are never hidden in a collapsed section.
TodayView buildTodayView(Iterable<Item> items, LocalDate today) {
  final mustDo = <Item>[];
  final alsoToday = <Item>[];
  final carriedOver = <Item>[];
  var thisWeekCount = 0;

  for (final item in items) {
    if (isThisWeek(item)) {
      thisWeekCount++;
      continue;
    }
    if (!isOnToday(item, today)) continue;
    if (item.mustDo) {
      mustDo.add(item);
    } else if (isCarriedOver(item, today)) {
      carriedOver.add(item);
    } else {
      alsoToday.add(item);
    }
  }

  mustDo.sort(compareTodayOrder);
  alsoToday.sort(compareTodayOrder);
  carriedOver.sort(compareTodayOrder);
  return TodayView(
    mustDo: mustDo,
    alsoToday: alsoToday,
    carriedOver: carriedOver,
    thisWeekCount: thisWeekCount,
  );
}

/// Timed items first by time, then by manual order, then oldest first.
int compareTodayOrder(Item a, Item b) {
  final aTime = a.doTime;
  final bTime = b.doTime;
  if (aTime != null && bTime != null && aTime != bTime) {
    return aTime.compareTo(bTime);
  }
  if ((aTime == null) != (bTime == null)) return aTime != null ? -1 : 1;
  final bySort = a.sortOrder.compareTo(b.sortOrder);
  if (bySort != 0) return bySort;
  return a.createdAt.compareTo(b.createdAt);
}

/// Outcome of asking to flag one more item as must-do (FR-04).
sealed class MustDoCheck {
  const MustDoCheck();
}

class MustDoAllowed extends MustDoCheck {
  const MustDoAllowed();
}

/// The cap is reached: the UI asks which item to swap out instead of silently
/// refusing.
class MustDoNeedsSwap extends MustDoCheck {
  const MustDoNeedsSwap(this.current);
  final List<Item> current;
}

MustDoCheck checkMustDoCap(Iterable<Item> items, LocalDate today, int cap) {
  final current = items.where((i) => i.mustDo && isOnToday(i, today)).toList();
  return current.length < cap
      ? const MustDoAllowed()
      : MustDoNeedsSwap(current..sort(compareTodayOrder));
}
