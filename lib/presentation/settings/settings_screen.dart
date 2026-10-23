import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../../domain/lifecycle.dart';
import '../../domain/local_date.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// The settings needed so far (FR-21). Review and backup settings arrive with
/// their milestones.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const Scaffold();
    void save(AppSettings s) => ref.read(settingsRepositoryProvider).save(s);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: pebbleSections([
          const SectionHeader('Today'),
          ListTile(
            title: const Text('Must-do items per day'),
            subtitle: const Text('Keeping this small keeps Today doable'),
            trailing: Text('${settings.mustDoCap}'),
          ),
          Slider(
            value: settings.mustDoCap.toDouble(),
            min: AppSettings.minMustDoCap.toDouble(),
            max: AppSettings.maxMustDoCap.toDouble(),
            divisions: AppSettings.maxMustDoCap - AppSettings.minMustDoCap,
            label: '${settings.mustDoCap}',
            onChanged: (v) => save(settings.copyWith(mustDoCap: v.round())),
          ),
          ChoiceTile<int>(
            title: 'Week starts on',
            hint: 'for “This week” and weekday choices',
            value: settings.weekStart,
            options: [
              for (final day in const [
                DateTime.monday,
                DateTime.saturday,
                DateTime.sunday,
              ])
                (day, weekdayLong(day)),
            ],
            onChanged: (day) => save(settings.copyWith(weekStart: day)),
          ),
          const SectionHeader('Inbox'),
          SwitchListTile(
            title: const Text('Show count on the Inbox tab'),
            value: settings.inboxBadge,
            onChanged: (v) => save(settings.copyWith(inboxBadge: v)),
          ),
          SwitchListTile(
            title: const Text('Starter suggestions'),
            subtitle: const Text(
              'Quick-add ideas in capture and an empty inbox',
            ),
            value: settings.starterSuggestions,
            onChanged: (v) => save(settings.copyWith(starterSuggestions: v)),
          ),
          ListTile(
            enabled: settings.starterSuggestions,
            title: const Text('Edit suggestions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.suggestions),
          ),
          const SectionHeader('Reminders'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<NotificationIntensity>(
              segments: const [
                ButtonSegment(
                  value: NotificationIntensity.off,
                  label: Text('Off'),
                ),
                ButtonSegment(
                  value: NotificationIntensity.gentle,
                  label: Text('Gentle'),
                ),
                ButtonSegment(
                  value: NotificationIntensity.standard,
                  label: Text('Standard'),
                ),
              ],
              selected: {settings.notificationIntensity},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(notificationIntensity: s.single)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(switch (settings.notificationIntensity) {
              NotificationIntensity.off => 'No notifications at all.',
              NotificationIntensity.gentle =>
                'Only reminders you set, without sound or vibration.',
              NotificationIntensity.standard =>
                'Only reminders you set, with sound.',
            }, style: Theme.of(context).textTheme.bodySmall),
          ),
          ListTile(
            enabled:
                settings.notificationIntensity != NotificationIntensity.off,
            title: const Text('Quiet hours'),
            subtitle: Text(
              settings.quietHoursStart == settings.quietHoursEnd
                  ? 'None'
                  : '${timeLabel(context, settings.quietHoursStart)} – '
                        '${timeLabel(context, settings.quietHoursEnd)}. '
                        'Early reminders wait until morning; ones you timed '
                        'exactly still arrive.',
            ),
            onTap: () async {
              final start = await showTimePicker(
                context: context,
                initialTime: timeOfDay(settings.quietHoursStart),
                helpText: 'Quiet from',
              );
              if (start == null || !context.mounted) return;
              final end = await showTimePicker(
                context: context,
                initialTime: timeOfDay(settings.quietHoursEnd),
                helpText: 'Quiet until',
              );
              if (end == null) return;
              save(
                settings.copyWith(
                  quietHoursStart: minutesOf(start),
                  quietHoursEnd: minutesOf(end),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Morning summary'),
            subtitle: Text(
              settings.morningDigest
                  ? 'Today’s must-dos at '
                        '${timeLabel(context, settings.morningDigestTime)}. '
                        'Nothing on a clear day.'
                  : 'One note each morning with today’s must-dos',
            ),
            value: settings.morningDigest,
            onChanged:
                settings.notificationIntensity == NotificationIntensity.off
                ? null
                : (v) => save(settings.copyWith(morningDigest: v)),
          ),
          if (settings.morningDigest)
            ListTile(
              title: const Text('Summary time'),
              trailing: Text(timeLabel(context, settings.morningDigestTime)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: timeOfDay(settings.morningDigestTime),
                );
                if (time != null) {
                  save(settings.copyWith(morningDigestTime: minutesOf(time)));
                }
              },
            ),
          const _ReminderAccess(),
          ListTile(
            title: const Text('Reminders not arriving?'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.remindersHelp),
          ),
          const SectionHeader('Weekly review'),
          SwitchListTile(
            title: const Text('Remind me to review'),
            subtitle: const Text('About 15 minutes, once a week'),
            value: settings.reviewReminder,
            onChanged: (v) => save(settings.copyWith(reviewReminder: v)),
          ),
          ChoiceTile<int>(
            enabled: settings.reviewReminder,
            title: 'Review day',
            value: settings.reviewWeekday,
            options: [
              for (final day in weekdaysFrom(settings.weekStart))
                (day, weekdayLong(day)),
            ],
            onChanged: (day) => save(settings.copyWith(reviewWeekday: day)),
          ),
          ListTile(
            enabled: settings.reviewReminder,
            title: const Text('Review time'),
            trailing: Text(timeLabel(context, settings.reviewTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: timeOfDay(settings.reviewTime),
              );
              if (time != null) {
                save(settings.copyWith(reviewTime: minutesOf(time)));
              }
            },
          ),
          const SectionHeader('Done items'),
          ChoiceTile<int>(
            title: 'Move done items to the archive',
            hint: 'still searchable there',
            value: settings.autoArchiveDays,
            options: [
              (1, 'After a day'),
              (7, 'After a week'),
              (30, 'After a month'),
              (archiveNever, 'Never'),
              if (!const [
                1,
                7,
                30,
                archiveNever,
              ].contains(settings.autoArchiveDays))
                (
                  settings.autoArchiveDays,
                  'After ${settings.autoArchiveDays} days',
                ),
            ],
            onChanged: (days) => save(settings.copyWith(autoArchiveDays: days)),
          ),
          const SectionHeader('Your data'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup'),
            subtitle: const Text('Export a copy, or restore one'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.backup),
          ),
          const SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemePreference>(
              segments: const [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text('Light'),
                ),
                ButtonSegment(value: ThemePreference.dark, label: Text('Dark')),
              ],
              selected: {settings.theme},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(theme: s.single)),
            ),
          ),
          const SectionHeader('Help'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How Clearing works'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.intro),
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: const Text('Questions and answers'),
            subtitle: const Text('Backups, new phones, undo and more'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.faq),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About and feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.about),
          ),
        ]),
      ),
    );
  }
}

/// What the system allows: notifications at all, and exact timing (PRD §7).
/// Re-checked on return from system settings.
class _ReminderAccess extends ConsumerStatefulWidget {
  const _ReminderAccess();

  @override
  ConsumerState<_ReminderAccess> createState() => _ReminderAccessState();
}

class _ReminderAccessState extends ConsumerState<_ReminderAccess>
    with WidgetsBindingObserver {
  late Future<(bool, bool)> _access = _check();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _access = _check());
    }
  }

  Future<(bool, bool)> _check() async {
    final gateway = ref.read(notificationGatewayProvider);
    return (await gateway.areEnabled(), await gateway.canScheduleExact());
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.read(notificationGatewayProvider);
    return FutureBuilder(
      future: _access,
      builder: (context, snapshot) {
        final (enabled, exact) = snapshot.data ?? (true, true);
        return Column(
          children: [
            if (!enabled)
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Notifications are blocked'),
                subtitle: const Text('Tap to allow them for Clearing'),
                onTap: () async {
                  await gateway.requestPermission();
                  setState(() => _access = _check());
                },
              ),
            ListTile(
              title: const Text('Exact timing'),
              subtitle: Text(
                exact
                    ? 'Reminders arrive on the minute'
                    : 'Off: reminders may arrive a few minutes late. '
                          'Tap to allow exact timing.',
              ),
              onTap: exact ? null : gateway.requestExact,
            ),
          ],
        );
      },
    );
  }
}
