import 'package:meta/meta.dart';

import 'local_date.dart';

/// How one finished day went, written once the day is over. A record, never
/// a score: the Grove and the insights page read it.
@immutable
class DayRecord {
  const DayRecord({
    required this.date,
    this.mustDoPlanned = 0,
    this.mustDoDone = 0,
    this.closed = 0,
    this.allClear = false,
  });

  final LocalDate date;
  final int mustDoPlanned;
  final int mustDoDone;

  /// Items completed that day.
  final int closed;

  /// Something was on Today and all of it was done.
  final bool allClear;

  @override
  bool operator ==(Object other) =>
      other is DayRecord &&
      other.date == date &&
      other.mustDoPlanned == mustDoPlanned &&
      other.mustDoDone == mustDoDone &&
      other.closed == closed &&
      other.allClear == allClear;

  @override
  int get hashCode =>
      Object.hash(date, mustDoPlanned, mustDoDone, closed, allClear);
}
