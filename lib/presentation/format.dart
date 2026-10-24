import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/enums.dart';
import '../domain/item_context.dart';
import '../domain/local_date.dart';
import '../domain/repeat_series.dart';
import '../l10n/l10n.dart';

/// "Today", "Tomorrow", "Yesterday", a weekday within the coming week,
/// otherwise "Fri 23 Oct" (with the year when it differs).
String dateLabel(LocalDate date, LocalDate today) {
  final days = today.daysUntil(date);
  if (days == 0) return l10n.whenToday;
  if (days == 1) return l10n.dateTomorrow;
  if (days == -1) return l10n.dateYesterday;
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

/// "1st", "2nd", "23rd"… in English; other languages say the number and
/// put the word for "day" in the sentence around it.
String ordinal(int n) {
  if (!l10n.localeName.startsWith('en')) return '$n';
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
  if (series.weeklyTarget case final target?) {
    return [
      l10n.repeatTimesAWeek(target),
      if (series.endDate case final end?)
        l10n.repeatUntil(dateLabel(end, today)),
    ].join(', ');
  }
  final n = series.interval;
  final weekdays = series.weekdays.isEmpty
      ? [series.startDate.weekday]
      : (series.weekdays.toList()..sort());
  final rule = [
    switch (series.freq) {
      RepeatFrequency.daily => l10n.repeatEveryDay(n),
      RepeatFrequency.weekly => l10n.repeatEveryWeek(n),
      RepeatFrequency.monthly => l10n.repeatEveryMonth(n),
    },
    if (series.isAfterCompletion)
      l10n.repeatAfterDone
    else if (series.freq == RepeatFrequency.weekly)
      l10n.repeatOnDays(weekdays.map(weekdayShort).join(', '))
    else if (series.freq == RepeatFrequency.monthly)
      l10n.repeatOnMonthDay(ordinal(series.monthDay ?? series.startDate.day)),
  ];
  return [
    rule.join(' '),
    if (series.endDate case final end?) l10n.repeatUntil(dateLabel(end, today)),
    if (series.maxCount case final count?) l10n.repeatTimes(count),
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
  0 => l10n.offsetAtTime,
  _ when minutes % (24 * 60) == 0 => l10n.offsetDays(minutes ~/ (24 * 60)),
  _ when minutes >= 60 && minutes % 60 == 0 => l10n.offsetHours(minutes ~/ 60),
  _ => l10n.offsetMinutes(minutes),
};

/// "5 min", "1 hour", "Longer" for an effort from [Item.effortSteps].
String effortLabel(int minutes) => switch (minutes) {
  < 60 => l10n.effortMinutes(minutes),
  60 => l10n.effortHour,
  _ => l10n.effortLonger,
};

/// A context's name: built-in ones in the app's language.
String contextLabel(ItemContext context) => switch (context.kind) {
  ContextKind.home => l10n.contextHome,
  ContextKind.out => l10n.contextOut,
  ContextKind.computer => l10n.contextComputer,
  ContextKind.phone => l10n.contextPhone,
  ContextKind.lowEnergy => l10n.contextLowEnergy,
  ContextKind.user => context.name,
};
