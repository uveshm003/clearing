import 'package:meta/meta.dart';

/// A calendar date with no time or time zone, e.g. "the 31st of October".
///
/// Items store dates as local calendar dates (PRD §3.2); the device time zone
/// is only resolved when a reminder is scheduled.
@immutable
class LocalDate implements Comparable<LocalDate> {
  LocalDate(int year, int month, int day)
    : this._fromUtc(DateTime.utc(year, month, day));

  LocalDate._fromUtc(DateTime utc)
    : year = utc.year,
      month = utc.month,
      day = utc.day;

  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO-8601 calendar date such as `2026-10-20`.
  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected YYYY-MM-DD', iso);
    }
    return LocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// 1 = Monday … 7 = Sunday, as in [DateTime.weekday].
  int get weekday => _utc.weekday;

  /// The number of days in this date's month.
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  LocalDate addDays(int days) => LocalDate(year, month, day + days);

  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  /// The first day of the week containing this date.
  ///
  /// [weekStart] uses [DateTime.weekday] numbering (1 = Monday).
  LocalDate startOfWeek(int weekStart) => addDays(-((weekday - weekStart) % 7));

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Combines this date with a time of day in the device's local time zone.
  DateTime atMinutes(int minutesFromMidnight) =>
      DateTime(year, month, day, 0, minutesFromMidnight);

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
