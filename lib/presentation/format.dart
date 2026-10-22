import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/enums.dart';
import '../domain/local_date.dart';
import '../domain/repeat_series.dart';

/// "Today", "Tomorrow", "Yesterday", a weekday within the coming week,
/// otherwise "Fri 23 Oct" (with the year when it differs).
String dateLabel(LocalDate date, LocalDate today) {
  final days = today.daysUntil(date);
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days == -1) return 'Yesterday';
  final dt = DateTime(date.year, date.month, date.day);
  if (days > 1 && days < 7) return DateFormat.EEEE().format(dt);
  if (date.year != today.year) return DateFormat('EEE d MMM y').format(dt);
  return DateFormat('EEE d MMM').format(dt);
}

/// Formats minutes from midnight using the device's 12/24-hour preference.
String timeLabel(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

TimeOfDay timeOfDay(int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

DateTime dateTimeOf(LocalDate date) =>
    DateTime(date.year, date.month, date.day);

/// "Mon", "Tue"… for [DateTime.weekday] numbers.
String weekdayShort(int weekday) =>
    DateFormat.E().format(DateTime(2024, 1, weekday)); // 1 Jan 2024: Monday

/// "Monday", "Tuesday"… for [DateTime.weekday] numbers.
String weekdayLong(int weekday) =>
    DateFormat.EEEE().format(DateTime(2024, 1, weekday));

/// "1st", "2nd", "23rd"…
String ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

/// "Every day", "Every 2 weeks on Mon, Thu", "Every month on the 31st,
/// until Fri 30 Oct".
String describeRepeat(RepeatSeries series, LocalDate today) {
  final n = series.interval;
  final unit = switch (series.freq) {
    RepeatFrequency.daily => 'day',
    RepeatFrequency.weekly => 'week',
    RepeatFrequency.monthly => 'month',
  };
  final weekdays = series.weekdays.isEmpty
      ? [series.startDate.weekday]
      : (series.weekdays.toList()..sort());
  final rule = [
    n == 1 ? 'Every $unit' : 'Every $n ${unit}s',
    if (series.isAfterCompletion)
      'after it’s done'
    else if (series.freq == RepeatFrequency.weekly)
      'on ${weekdays.map(weekdayShort).join(', ')}'
    else if (series.freq == RepeatFrequency.monthly)
      'on the ${ordinal(series.monthDay ?? series.startDate.day)}',
  ];
  return [
    rule.join(' '),
    if (series.endDate case final end?) 'until ${dateLabel(end, today)}',
    if (series.maxCount case final count?) '$count times',
  ].join(', ');
}

/// "At the time", "10 min before", "1 day before", or the custom time.
String reminderLabel(
  BuildContext context, {
  int? offsetMinutes,
  DateTime? fireAt,
  required LocalDate today,
}) {
  if (offsetMinutes != null) return offsetLabel(offsetMinutes);
  final at = fireAt!;
  return '${dateLabel(LocalDate.fromDateTime(at), today)}, '
      '${timeLabel(context, at.hour * 60 + at.minute)}';
}

String offsetLabel(int minutes) => switch (minutes) {
  0 => 'At the time',
  < 60 => '$minutes min before',
  _ when minutes % (24 * 60) == 0 =>
    minutes == 24 * 60 ? '1 day before' : '${minutes ~/ (24 * 60)} days before',
  _ when minutes % 60 == 0 => '${minutes ~/ 60} h before',
  _ => '$minutes min before',
};
