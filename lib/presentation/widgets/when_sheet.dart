import 'package:flutter/material.dart';

import '../../domain/local_date.dart';
import '../format.dart';

/// The answer to "When?" in clarify, reschedule and the inbox shortcuts.
sealed class WhenChoice {
  const WhenChoice();
}

class WhenToday extends WhenChoice {
  const WhenToday();
}

class WhenThisWeek extends WhenChoice {
  const WhenThisWeek();
}

class WhenAnytime extends WhenChoice {
  const WhenAnytime();
}

class WhenOnDate extends WhenChoice {
  const WhenOnDate(this.date, {this.time});
  final LocalDate date;
  final int? time;
}

/// Asks for a date, then optionally a time. Returns null if cancelled.
Future<WhenOnDate?> pickDate(
  BuildContext context, {
  required LocalDate today,
  LocalDate? initial,
  int? initialTime,
  bool askTime = true,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: dateTimeOf(
      initial != null && !initial.isBefore(today) ? initial : today,
    ),
    firstDate: dateTimeOf(today),
    lastDate: dateTimeOf(today.addDays(365 * 5)),
    helpText: 'Do on',
  );
  if (picked == null || !context.mounted) return null;
  final date = LocalDate.fromDateTime(picked);
  if (!askTime) return WhenOnDate(date);

  final addTime = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(dateLabel(date, today)),
      content: const Text('Add a time? Most things don’t need one.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No time'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add time'),
        ),
      ],
    ),
  );
  if (addTime != true || !context.mounted) return WhenOnDate(date);
  final time = await showTimePicker(
    context: context,
    initialTime: timeOfDay(initialTime ?? 9 * 60),
  );
  return WhenOnDate(date, time: time == null ? null : minutesOf(time));
}

/// A bottom sheet offering Today, This week, Pick a date and Anytime.
Future<WhenChoice?> showWhenSheet(
  BuildContext context, {
  required LocalDate today,
  String title = 'When?',
}) {
  return showModalBottomSheet<WhenChoice>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              title,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          ...whenOptions(sheetContext, today: today),
        ],
      ),
    ),
  );
}

/// The four "When?" options as list tiles that pop the current route with
/// the chosen [WhenChoice].
List<Widget> whenOptions(BuildContext context, {required LocalDate today}) => [
  ListTile(
    leading: const Icon(Icons.wb_sunny_outlined),
    title: const Text('Today'),
    onTap: () => Navigator.pop(context, const WhenToday()),
  ),
  ListTile(
    leading: const Icon(Icons.view_week_outlined),
    title: const Text('This week'),
    onTap: () => Navigator.pop(context, const WhenThisWeek()),
  ),
  ListTile(
    leading: const Icon(Icons.event_outlined),
    title: const Text('Pick a date'),
    onTap: () async {
      final picked = await pickDate(context, today: today);
      if (picked != null && context.mounted) Navigator.pop(context, picked);
    },
  ),
  ListTile(
    leading: const Icon(Icons.all_inclusive),
    title: const Text('Anytime'),
    subtitle: const Text('No particular day'),
    onTap: () => Navigator.pop(context, const WhenAnytime()),
  ),
];
