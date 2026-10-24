import 'package:collection/collection.dart';

import 'enums.dart';
import 'grove.dart';
import 'item_event.dart';

/// The private "Your rhythm" page (§5.9): observations worked out from data
/// already kept. Nothing new is stored.

/// Things closed in each hour of the day (index 0 = midnight).
List<int> closesByHour(Iterable<ClosedThing> closed) {
  final hours = List.filled(24, 0);
  for (final thing in closed) {
    hours[thing.completedAt.hour]++;
  }
  return hours;
}

enum DayPart { morning, afternoon, evening, night }

/// The part of the day with the most closes, if there are enough to say.
DayPart? busiestPart(List<int> hours, {int atLeast = 5}) {
  if (hours.sum < atLeast) return null;
  int sum(int from, int to) => hours.sublist(from, to).sum;
  final parts = {
    DayPart.morning: sum(5, 12),
    DayPart.afternoon: sum(12, 17),
    DayPart.evening: sum(17, 22),
    DayPart.night: sum(22, 24) + sum(0, 5),
  };
  return parts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

/// The middle value of [values]; null when empty.
int? median(Iterable<int> values) {
  final sorted = values.toList()..sort();
  if (sorted.isEmpty) return null;
  return sorted[sorted.length ~/ 2];
}

/// Days from capture to the first decision about each item.
List<int> inboxWaits(List<ItemEvent> events) {
  final captured = <String, DateTime>{};
  final waits = <int>[];
  for (final event in events) {
    if (event.kind == ItemEventKind.captured) {
      captured[event.itemId] = event.at;
    } else if (captured.remove(event.itemId) case final at?) {
      waits.add(event.at.difference(at).inDays);
    }
  }
  return waits;
}
