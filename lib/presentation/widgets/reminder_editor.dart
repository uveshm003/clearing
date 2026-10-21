import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/reminder.dart';
import '../format.dart';

/// "Remind me" on an item: up to three reminders, kept apart from the do-date
/// and the deadline (FR-08).
class ReminderSection extends ConsumerWidget {
  const ReminderSection({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final reminders = ref.watch(remindersProvider(item.id)).value ?? const [];
    final repo = ref.read(reminderRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reminder in reminders)
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(
              reminderLabel(
                context,
                offsetMinutes: reminder.offsetMinutes,
                fireAt: reminder.fireAt,
                today: today,
              ),
            ),
            subtitle: reminder.isRelative && item.doDate == null
                ? const Text('Waiting for a date')
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove reminder',
              onPressed: () => repo.delete(reminder.id),
            ),
          ),
        if (reminders.length < maxRemindersPerItem)
          ListTile(
            leading: const Icon(Icons.add_alert_outlined),
            title: Text(reminders.isEmpty ? 'Remind me' : 'Add a reminder'),
            subtitle: reminders.isEmpty
                ? const Text('Separate from when you plan to do it')
                : null,
            onTap: () async {
              final choice = await pickReminder(
                context,
                item: item,
                today: today,
                taken: {for (final r in reminders) ?r.offsetMinutes},
              );
              if (choice == null || !context.mounted) return;
              await repo.add(
                item.id,
                offsetMinutes: choice.offsetMinutes,
                fireAt: choice.fireAt,
              );
              if (context.mounted) await askToNotify(context, ref);
            },
          ),
      ],
    );
  }
}

typedef ReminderChoice = ({int? offsetMinutes, DateTime? fireAt});

/// Offers the offset presets (when the item has a date) and a custom time.
Future<ReminderChoice?> pickReminder(
  BuildContext context, {
  required Item item,
  required LocalDate today,
  Set<int> taken = const {},
}) {
  final timeNote = item.doDate != null && item.doTime == null
      ? ' (counted from 9:00)'
      : '';
  return showModalBottomSheet<ReminderChoice>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Remind me',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            if (item.doDate != null)
              for (final offset in reminderOffsetPresets)
                if (!taken.contains(offset))
                  ListTile(
                    title: Text('${offsetLabel(offset)}$timeNote'),
                    onTap: () => Navigator.pop(sheetContext, (
                      offsetMinutes: offset,
                      fireAt: null,
                    )),
                  ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('At a time I choose'),
              onTap: () async {
                final at = await _pickDateTime(sheetContext, today: today);
                if (at != null && sheetContext.mounted) {
                  Navigator.pop(sheetContext, (
                    offsetMinutes: null,
                    fireAt: at,
                  ));
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<DateTime?> _pickDateTime(
  BuildContext context, {
  required LocalDate today,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: dateTimeOf(today),
    firstDate: dateTimeOf(today),
    lastDate: dateTimeOf(today.addDays(365 * 5)),
    helpText: 'Remind me on',
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: timeOfDay(defaultReminderTime),
    helpText: 'Remind me at',
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Asks for notification permission in context, the moment a reminder is
/// added (FR-09), and says plainly when reminders can't arrive on time.
Future<void> askToNotify(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final gateway = ref.read(notificationGatewayProvider);
  final settings = ref.read(settingsProvider).value;

  void tell(String message, {String? action, VoidCallback? onAction}) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action == null
              ? null
              : SnackBarAction(label: action, onPressed: onAction!),
        ),
      );
  }

  if (settings?.notificationIntensity == NotificationIntensity.off) {
    return tell(
      'Reminders are off in Settings',
      action: 'Settings',
      onAction: () => context.push(Routes.settings),
    );
  }
  final allowed =
      await gateway.areEnabled() || await gateway.requestPermission();
  if (!allowed) {
    return tell(
      'Notifications are off for Clearing, so this reminder can’t appear. '
      'You can allow them in system settings.',
    );
  }
  if (!_askedForExact && !await gateway.canScheduleExact()) {
    _askedForExact = true;
    tell(
      'Reminders may arrive a few minutes late',
      action: 'Make exact',
      onAction: gateway.requestExact,
    );
  }
}

/// Asked once per run, so adding reminders never turns into nagging.
var _askedForExact = false;
