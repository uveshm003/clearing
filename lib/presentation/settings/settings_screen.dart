import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../../domain/lifecycle.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commonSettings)),
      body: ListView(
        children: pebbleSections([
          SectionHeader(l10n.tabToday),
          ListTile(
            title: Text(l10n.settingsMustDoPerDay),
            subtitle: Text(l10n.settingsMustDoPerDayHint),
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
            title: l10n.settingsWeekStartsOn,
            hint: l10n.settingsWeekStartsOnHint,
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
          SectionHeader(l10n.tabInbox),
          SwitchListTile(
            title: Text(l10n.settingsInboxBadge),
            value: settings.inboxBadge,
            onChanged: (v) => save(settings.copyWith(inboxBadge: v)),
          ),
          SwitchListTile(
            title: Text(l10n.suggestionsTitle),
            subtitle: Text(l10n.settingsStarterSuggestionsHint),
            value: settings.starterSuggestions,
            onChanged: (v) => save(settings.copyWith(starterSuggestions: v)),
          ),
          ListTile(
            enabled: settings.starterSuggestions,
            title: Text(l10n.settingsEditSuggestions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.suggestions),
          ),
          SectionHeader(l10n.settingsRemindersSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<NotificationIntensity>(
              segments: [
                ButtonSegment(
                  value: NotificationIntensity.off,
                  label: Text(l10n.settingsIntensityOff),
                ),
                ButtonSegment(
                  value: NotificationIntensity.gentle,
                  label: Text(l10n.settingsIntensityGentle),
                ),
                ButtonSegment(
                  value: NotificationIntensity.standard,
                  label: Text(l10n.settingsIntensityStandard),
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
              NotificationIntensity.off => l10n.settingsIntensityOffHint,
              NotificationIntensity.gentle => l10n.settingsIntensityGentleHint,
              NotificationIntensity.standard =>
                l10n.settingsIntensityStandardHint,
            }, style: Theme.of(context).textTheme.bodySmall),
          ),
          ListTile(
            enabled:
                settings.notificationIntensity != NotificationIntensity.off,
            title: Text(l10n.settingsQuietHours),
            subtitle: Text(
              settings.quietHoursStart == settings.quietHoursEnd
                  ? l10n.commonNone
                  : l10n.settingsQuietHoursRange(
                      timeLabel(context, settings.quietHoursStart),
                      timeLabel(context, settings.quietHoursEnd),
                    ),
            ),
            onTap: () async {
              final start = await showTimePicker(
                context: context,
                initialTime: timeOfDay(settings.quietHoursStart),
                helpText: l10n.settingsQuietFrom,
              );
              if (start == null || !context.mounted) return;
              final end = await showTimePicker(
                context: context,
                initialTime: timeOfDay(settings.quietHoursEnd),
                helpText: l10n.settingsQuietUntil,
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
            title: Text(l10n.settingsMorningSummary),
            subtitle: Text(
              settings.morningDigest
                  ? l10n.settingsMorningSummaryOn(
                      timeLabel(context, settings.morningDigestTime),
                    )
                  : l10n.settingsMorningSummaryOff,
            ),
            value: settings.morningDigest,
            onChanged:
                settings.notificationIntensity == NotificationIntensity.off
                ? null
                : (v) => save(settings.copyWith(morningDigest: v)),
          ),
          if (settings.morningDigest)
            ListTile(
              title: Text(l10n.settingsSummaryTime),
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
            title: Text(l10n.settingsRemindersNotArriving),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.remindersHelp),
          ),
          SectionHeader(l10n.settingsWeeklyReviewSection),
          SwitchListTile(
            title: Text(l10n.settingsRemindReview),
            subtitle: Text(l10n.settingsRemindReviewHint),
            value: settings.reviewReminder,
            onChanged: (v) => save(settings.copyWith(reviewReminder: v)),
          ),
          ChoiceTile<int>(
            enabled: settings.reviewReminder,
            title: l10n.settingsReviewDay,
            value: settings.reviewWeekday,
            options: [
              for (final day in weekdaysFrom(settings.weekStart))
                (day, weekdayLong(day)),
            ],
            onChanged: (day) => save(settings.copyWith(reviewWeekday: day)),
          ),
          ListTile(
            enabled: settings.reviewReminder,
            title: Text(l10n.settingsReviewTime),
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
          SectionHeader(l10n.settingsDoneSection),
          ChoiceTile<int>(
            title: l10n.settingsAutoArchive,
            hint: l10n.settingsAutoArchiveHint,
            value: settings.autoArchiveDays,
            options: [
              (1, l10n.settingsArchiveAfterDay),
              (7, l10n.settingsArchiveAfterWeek),
              (30, l10n.settingsArchiveAfterMonth),
              (archiveNever, l10n.settingsArchiveNever),
              if (!const [
                1,
                7,
                30,
                archiveNever,
              ].contains(settings.autoArchiveDays))
                (
                  settings.autoArchiveDays,
                  l10n.settingsArchiveAfterDays(settings.autoArchiveDays),
                ),
            ],
            onChanged: (days) => save(settings.copyWith(autoArchiveDays: days)),
          ),
          SectionHeader(l10n.settingsDataSection),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backupTitle),
            subtitle: Text(l10n.settingsBackupHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.backup),
          ),
          SectionHeader(l10n.settingsAppearanceSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemePreference>(
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text(l10n.settingsThemeSystem),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text(l10n.settingsThemeLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  label: Text(l10n.settingsThemeDark),
                ),
              ],
              selected: {settings.theme},
              onSelectionChanged: (s) =>
                  save(settings.copyWith(theme: s.single)),
            ),
          ),
          SectionHeader(l10n.settingsHelpSection),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.introTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.intro),
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: Text(l10n.settingsFaq),
            subtitle: Text(l10n.settingsFaqHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.faq),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
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
                title: Text(context.l10n.settingsNotificationsBlocked),
                subtitle: Text(context.l10n.settingsNotificationsBlockedHint),
                onTap: () async {
                  await gateway.requestPermission();
                  setState(() => _access = _check());
                },
              ),
            ListTile(
              title: Text(context.l10n.settingsExactTiming),
              subtitle: Text(
                exact
                    ? context.l10n.settingsExactTimingOn
                    : context.l10n.settingsExactTimingOff,
              ),
              onTap: exact ? null : gateway.requestExact,
            ),
          ],
        );
      },
    );
  }
}
