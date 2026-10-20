import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/local_date.dart';

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
