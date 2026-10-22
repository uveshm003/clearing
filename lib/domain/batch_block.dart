import 'package:meta/meta.dart';

import 'local_date.dart';

/// A time slot for a whole list, such as "Errands, Saturday 10:00" (FR-05).
/// It shows as one entry on Today instead of each errand on its own.
@immutable
class BatchBlock {
  const BatchBlock({
    required this.id,
    required this.listId,
    required this.time,
    this.date,
    this.weekday,
  }) : assert((date == null) != (weekday == null));

  final String id;
  final String listId;

  /// Once, on this date…
  final LocalDate? date;

  /// …or every week on this [DateTime.weekday].
  final int? weekday;

  /// Minutes from local midnight.
  final int time;

  bool get repeats => weekday != null;

  bool occursOn(LocalDate day) =>
      date == day || (weekday != null && weekday == day.weekday);

  /// The dates it falls on from [from] to [to], inclusive.
  Iterable<LocalDate> datesBetween(LocalDate from, LocalDate to) sync* {
    for (var day = from; !day.isAfter(to); day = day.addDays(1)) {
      if (occursOn(day)) yield day;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is BatchBlock &&
      other.id == id &&
      other.listId == listId &&
      other.date == date &&
      other.weekday == weekday &&
      other.time == time;

  @override
  int get hashCode => Object.hash(id, listId, date, weekday, time);
}
