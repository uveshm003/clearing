import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../../domain/ics.dart';
import '../../domain/lifecycle.dart';
import '../../domain/local_date.dart' show weekdaysFrom;
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/item_tile.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';
import 'whats_new.dart';

/// One setting and the words it's found by.
typedef _Row = ({String words, Widget widget});

/// A settings section: a header, a line on what it's for, and its rows.
typedef _Section = ({String title, String? hint, List<_Row> rows});

/// Every setting (FR-21), in sections, with a search at the top.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _query = '';

  void _save(AppSettings s) => ref.read(settingsRepositoryProvider).save(s);

  _Row _row(Widget widget, List<String?> words) =>
      (words: words.nonNulls.join(' ').toLowerCase(), widget: widget);

  _Row _switch({
    required String title,
    String? subtitle,
    Widget? secondary,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) => _row(
    SwitchListTile(
      secondary: secondary,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      onChanged: onChanged,
    ),
    [title, subtitle],
  );

  _Row _link({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) => _row(
    ListTile(
      enabled: enabled,
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
    [title, subtitle],
  );

  Future<void> _exportCalendar() async {
    final today = ref.read(todayProvider).value;
    final open = ref.read(openItemsProvider).value ?? const [];
    if (today == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final none = context.l10n.settingsExportCalendarNone;
    final ics = upcomingCalendar(
      open,
      from: today,
      now: ref.read(clockProvider)(),
    );
    if (!ics.contains('BEGIN:VEVENT')) {
      messenger.showSnackBar(SnackBar(content: Text(none)));
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(ics.codeUnits),
            mimeType: 'text/calendar',
            name: 'clearing-upcoming.ics',
          ),
        ],
        fileNameOverrides: const ['clearing-upcoming.ics'],
      ),
    );
  }

  List<_Section> _sections(AppSettings settings) {
    final l10n = context.l10n;
    final earned = ref.watch(earnedVariantsProvider);
    final notificationsOff =
        settings.notificationIntensity == NotificationIntensity.off;
    final swipeOptions = [
      for (final action in SwipeAction.values)
        (action, swipeLabel(context, action)),
    ];
    return [
      (
        title: l10n.tabToday,
        hint: l10n.settingsTodayHint,
        rows: [
          _row(
            ListTile(
              title: Text(l10n.settingsMustDoPerDay),
              subtitle: Text(l10n.settingsMustDoPerDayHint),
              trailing: Text('${settings.mustDoCap}'),
            ),
            [l10n.settingsMustDoPerDay, l10n.settingsMustDoPerDayHint],
          ),
          _row(
            Slider(
              value: settings.mustDoCap.toDouble(),
              min: AppSettings.minMustDoCap.toDouble(),
              max: AppSettings.maxMustDoCap.toDouble(),
              divisions: AppSettings.maxMustDoCap - AppSettings.minMustDoCap,
              label: '${settings.mustDoCap}',
              onChanged: (v) => _save(settings.copyWith(mustDoCap: v.round())),
            ),
            [l10n.settingsMustDoPerDay],
          ),
          _row(
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
              onChanged: (day) => _save(settings.copyWith(weekStart: day)),
            ),
            [l10n.settingsWeekStartsOn, l10n.settingsWeekStartsOnHint],
          ),
          _switch(
            title: l10n.settingsPlanMyDay,
            subtitle: l10n.planDayPromptHint,
            value: settings.planMyDay,
            onChanged: (v) => _save(settings.copyWith(planMyDay: v)),
          ),
        ],
      ),
      (
        title: l10n.settingsCaptureSection,
        hint: l10n.settingsCaptureHint,
        rows: [
          _switch(
            title: l10n.settingsParse,
            subtitle: l10n.settingsParseHint,
            value: settings.parseCapture,
            onChanged: (v) => _save(settings.copyWith(parseCapture: v)),
          ),
          _switch(
            title: l10n.settingsParsedSkipInbox,
            value: settings.parsedSkipInbox,
            onChanged: settings.parseCapture
                ? (v) => _save(settings.copyWith(parsedSkipInbox: v))
                : null,
          ),
          _link(
            title: l10n.settingsContexts,
            subtitle: l10n.contextsHint,
            icon: Icons.place_outlined,
            onTap: () => context.push(Routes.contexts),
          ),
        ],
      ),
      (
        title: l10n.tabInbox,
        hint: l10n.settingsInboxHint,
        rows: [
          _switch(
            title: l10n.settingsInboxBadge,
            value: settings.inboxBadge,
            onChanged: (v) => _save(settings.copyWith(inboxBadge: v)),
          ),
          _switch(
            title: l10n.suggestionsTitle,
            subtitle: l10n.settingsStarterSuggestionsHint,
            value: settings.starterSuggestions,
            onChanged: (v) => _save(settings.copyWith(starterSuggestions: v)),
          ),
          _link(
            enabled: settings.starterSuggestions,
            title: l10n.settingsEditSuggestions,
            onTap: () => context.push(Routes.suggestions),
          ),
        ],
      ),
      (
        title: l10n.settingsSwipeSection,
        hint: l10n.settingsSwipeHint,
        rows: [
          _row(
            ChoiceTile<SwipeAction>(
              title: l10n.settingsSwipeStart,
              value: settings.swipeStart,
              options: swipeOptions,
              onChanged: (a) => _save(settings.copyWith(swipeStart: a)),
            ),
            [l10n.settingsSwipeStart, l10n.settingsSwipeSection],
          ),
          _row(
            ChoiceTile<SwipeAction>(
              title: l10n.settingsSwipeEnd,
              value: settings.swipeEnd,
              options: swipeOptions,
              onChanged: (a) => _save(settings.copyWith(swipeEnd: a)),
            ),
            [l10n.settingsSwipeEnd, l10n.settingsSwipeSection],
          ),
        ],
      ),
      (
        title: l10n.settingsRemindersSection,
        hint: l10n.settingsRemindersHint,
        rows: [
          _row(
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
                    _save(settings.copyWith(notificationIntensity: s.single)),
              ),
            ),
            [
              l10n.settingsRemindersSection,
              l10n.settingsIntensityGentle,
              l10n.settingsIntensityStandard,
            ],
          ),
          _row(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(switch (settings.notificationIntensity) {
                NotificationIntensity.off => l10n.settingsIntensityOffHint,
                NotificationIntensity.gentle =>
                  l10n.settingsIntensityGentleHint,
                NotificationIntensity.standard =>
                  l10n.settingsIntensityStandardHint,
              }, style: Theme.of(context).textTheme.bodySmall),
            ),
            [l10n.settingsRemindersSection],
          ),
          _row(
            ListTile(
              enabled: !notificationsOff,
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
                if (start == null || !mounted) return;
                final end = await showTimePicker(
                  context: context,
                  initialTime: timeOfDay(settings.quietHoursEnd),
                  helpText: l10n.settingsQuietUntil,
                );
                if (end == null) return;
                _save(
                  settings.copyWith(
                    quietHoursStart: minutesOf(start),
                    quietHoursEnd: minutesOf(end),
                  ),
                );
              },
            ),
            [l10n.settingsQuietHours],
          ),
          _switch(
            title: l10n.settingsMorningSummary,
            subtitle: settings.morningDigest
                ? l10n.settingsMorningSummaryOn(
                    timeLabel(context, settings.morningDigestTime),
                  )
                : l10n.settingsMorningSummaryOff,
            value: settings.morningDigest,
            onChanged: notificationsOff
                ? null
                : (v) => _save(settings.copyWith(morningDigest: v)),
          ),
          if (settings.morningDigest)
            _row(
              ListTile(
                title: Text(l10n.settingsSummaryTime),
                trailing: Text(timeLabel(context, settings.morningDigestTime)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: timeOfDay(settings.morningDigestTime),
                  );
                  if (time != null) {
                    _save(
                      settings.copyWith(morningDigestTime: minutesOf(time)),
                    );
                  }
                },
              ),
              [l10n.settingsSummaryTime, l10n.settingsMorningSummary],
            ),
          _row(const _ReminderAccess(), [
            l10n.settingsExactTiming,
            l10n.settingsNotificationsBlocked,
          ]),
          _link(
            title: l10n.settingsRemindersNotArriving,
            onTap: () => context.push(Routes.remindersHelp),
          ),
        ],
      ),
      (
        title: l10n.settingsPrivacySection,
        hint: l10n.settingsPrivacyHint,
        rows: [
          _switch(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: l10n.settingsHideOnLock,
            subtitle: l10n.settingsHideOnLockHint,
            value: settings.hideOnLockScreen,
            onChanged: (v) => _save(settings.copyWith(hideOnLockScreen: v)),
          ),
          _row(_AppLockTile(settings: settings), [
            l10n.settingsAppLock,
            l10n.settingsAppLockHint,
          ]),
          if (settings.appLock)
            _row(
              ChoiceTile<int>(
                title: l10n.settingsLockAfter,
                value: settings.lockAfterMinutes,
                options: [
                  (0, l10n.settingsLockImmediately),
                  (1, l10n.settingsLockMinutes(1)),
                  (5, l10n.settingsLockMinutes(5)),
                ],
                onChanged: (m) => _save(settings.copyWith(lockAfterMinutes: m)),
              ),
              [l10n.settingsLockAfter],
            ),
        ],
      ),
      (
        title: l10n.settingsWeeklyReviewSection,
        hint: l10n.settingsWeeklyReviewHint,
        rows: [
          _switch(
            title: l10n.settingsRemindReview,
            subtitle: l10n.settingsRemindReviewHint,
            value: settings.reviewReminder,
            onChanged: (v) => _save(settings.copyWith(reviewReminder: v)),
          ),
          _row(
            ChoiceTile<int>(
              enabled: settings.reviewReminder,
              title: l10n.settingsReviewDay,
              value: settings.reviewWeekday,
              options: [
                for (final day in weekdaysFrom(settings.weekStart))
                  (day, weekdayLong(day)),
              ],
              onChanged: (day) => _save(settings.copyWith(reviewWeekday: day)),
            ),
            [l10n.settingsReviewDay],
          ),
          _row(
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
                  _save(settings.copyWith(reviewTime: minutesOf(time)));
                }
              },
            ),
            [l10n.settingsReviewTime],
          ),
          _row(
            ChoiceTile<ReviewLength>(
              title: l10n.settingsReviewLength,
              value: settings.reviewLength,
              options: [
                (ReviewLength.ask, l10n.settingsReviewAsk),
                (ReviewLength.quick, l10n.reviewQuick),
                (ReviewLength.full, l10n.reviewFull),
              ],
              onChanged: (v) => _save(settings.copyWith(reviewLength: v)),
            ),
            [l10n.settingsReviewLength, l10n.reviewQuick],
          ),
          _link(
            title: l10n.settingsReviewPrompts,
            subtitle: settings.reviewPrompts.isEmpty
                ? l10n.settingsReviewPromptsHint
                : settings.reviewPrompts.join(', '),
            onTap: () => context.push(Routes.reviewPrompts),
          ),
          _switch(
            title: l10n.settingsWinsPrompt,
            subtitle: l10n.lookBackWins,
            value: settings.winsPrompt,
            onChanged: (v) => _save(settings.copyWith(winsPrompt: v)),
          ),
        ],
      ),
      (
        title: l10n.settingsFocusSection,
        hint: l10n.settingsFocusHint,
        rows: [
          _switch(
            title: l10n.settingsFocusTimebox,
            subtitle: l10n.settingsFocusTimeboxHint,
            value: settings.focusTimebox,
            onChanged: (v) => _save(settings.copyWith(focusTimebox: v)),
          ),
          _switch(
            title: l10n.settingsBreathing,
            value: settings.breathingOpener,
            onChanged: (v) => _save(settings.copyWith(breathingOpener: v)),
          ),
        ],
      ),
      (
        title: l10n.settingsDoneSection,
        hint: l10n.settingsDoneHint,
        rows: [
          _row(
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
              onChanged: (days) =>
                  _save(settings.copyWith(autoArchiveDays: days)),
            ),
            [l10n.settingsAutoArchive, l10n.settingsAutoArchiveHint],
          ),
        ],
      ),
      (
        title: l10n.settingsGroveSection,
        hint: l10n.settingsGroveHint,
        rows: [
          _switch(
            secondary: const Icon(Icons.park_outlined),
            title: l10n.settingsGroveShow,
            value: settings.groveEnabled,
            onChanged: (v) =>
                _save(settings.copyWith(groveEnabled: v, groveAsked: true)),
          ),
          _switch(
            title: l10n.settingsInvitations,
            subtitle: l10n.settingsInvitationsHint,
            value: settings.invitationsEnabled,
            onChanged: settings.groveEnabled
                ? (v) => _save(settings.copyWith(invitationsEnabled: v))
                : null,
          ),
          if (settings.groveEnabled)
            _link(
              title: l10n.groveTitle,
              icon: Icons.landscape_outlined,
              onTap: () => context.push(Routes.grove),
            ),
        ],
      ),
      (
        title: l10n.settingsDataSection,
        hint: l10n.settingsDataHint,
        rows: [
          _link(
            icon: Icons.backup_outlined,
            title: l10n.backupTitle,
            subtitle: l10n.settingsBackupHint,
            onTap: () => context.push(Routes.backup),
          ),
          _row(
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.settingsExportCalendar),
              subtitle: Text(l10n.settingsExportCalendarHint),
              onTap: _exportCalendar,
            ),
            [l10n.settingsExportCalendar, l10n.settingsExportCalendarHint],
          ),
        ],
      ),
      (
        title: l10n.settingsAppearanceSection,
        hint: l10n.settingsAppearanceHint,
        rows: [
          _row(
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
                    _save(settings.copyWith(theme: s.single)),
              ),
            ),
            [
              l10n.settingsAppearanceSection,
              l10n.settingsThemeLight,
              l10n.settingsThemeDark,
            ],
          ),
          _row(_VariantPicker(settings: settings, earned: earned), [
            l10n.settingsThemeVariant,
            l10n.variantAutumn,
          ]),
          _switch(
            title: l10n.settingsUnlockAll,
            value: settings.unlockAllThemes,
            onChanged: (v) => _save(settings.copyWith(unlockAllThemes: v)),
          ),
          _switch(
            secondary: const Icon(Icons.contrast),
            title: l10n.settingsHighContrast,
            subtitle: l10n.settingsHighContrastHint,
            value: settings.highContrast,
            onChanged: (v) => _save(settings.copyWith(highContrast: v)),
          ),
          _switch(
            secondary: const Icon(Icons.format_line_spacing),
            title: l10n.settingsRoomyText,
            subtitle: l10n.settingsRoomyTextHint,
            value: settings.roomyText,
            onChanged: (v) => _save(settings.copyWith(roomyText: v)),
          ),
          _row(const _TextPreview(), [l10n.settingsTextPreview]),
          _link(
            icon: Icons.tune,
            title: l10n.settingsMakeYours,
            subtitle: l10n.settingsMakeYoursHint,
            onTap: () => context.push(Routes.style),
          ),
        ],
      ),
      (
        title: l10n.settingsFeedbackSection,
        hint: l10n.settingsFeedbackHint,
        rows: [
          _switch(
            secondary: const Icon(Icons.music_note_outlined),
            title: l10n.settingsSounds,
            subtitle: l10n.settingsSoundsHint,
            value: settings.sounds,
            onChanged: (v) => _save(settings.copyWith(sounds: v)),
          ),
        ],
      ),
      (
        title: l10n.settingsHelpSection,
        hint: l10n.settingsHelpHint,
        rows: [
          _link(
            icon: Icons.help_outline,
            title: l10n.helpTitle,
            subtitle: l10n.helpSubtitle,
            onTap: () => context.push(Routes.help),
          ),
          _switch(
            secondary: const Icon(Icons.lightbulb_outline),
            title: l10n.settingsShowTips,
            subtitle: l10n.settingsShowTipsHint,
            value: settings.showTips,
            onChanged: (v) => _save(settings.copyWith(showTips: v)),
          ),
          _row(
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l10n.settingsResetTips),
              enabled: settings.seenTips.isNotEmpty,
              onTap: () {
                _save(settings.copyWith(showTips: true, seenTips: const {}));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(l10n.settingsTipsReset)),
                  );
              },
            ),
            [l10n.settingsResetTips],
          ),
          _link(
            icon: Icons.replay,
            title: l10n.settingsReplayWelcome,
            subtitle: l10n.settingsReplayWelcomeHint,
            onTap: () => context.push(Routes.welcome),
          ),
          _link(
            icon: Icons.new_releases_outlined,
            title: l10n.settingsWhatsNew,
            onTap: () => showWhatsNew(context),
          ),
          _link(
            icon: Icons.info_outline,
            title: l10n.settingsAbout,
            onTap: () => context.push(Routes.about),
          ),
          if (kDebugMode)
            _link(
              icon: Icons.developer_mode,
              title: l10n.settingsDeveloper,
              onTap: () => context.push(Routes.developer),
            ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const Scaffold();
    final l10n = context.l10n;
    final query = _query.trim().toLowerCase();
    final children = <Widget>[];
    for (final section in _sections(settings)) {
      final matches = query.isEmpty
          ? section.rows
          : section.title.toLowerCase().contains(query)
          ? section.rows
          : section.rows.where((r) => r.words.contains(query)).toList();
      if (matches.isEmpty) continue;
      children
        ..add(SectionHeader(section.title, description: section.hint))
        ..addAll(matches.map((r) => r.widget));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commonSettings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.settingsSearch,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.settingsSearchNone),
            ),
          ...pebbleSections(children),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// The Glade colour variants: earned ones to pick, the rest with how
/// they're found. High contrast is a separate switch, never a reward.
class _VariantPicker extends ConsumerWidget {
  const _VariantPicker({required this.settings, required this.earned});

  final AppSettings settings;
  final Set<GladeVariant> earned;

  static String name(AppLocalizations l, GladeVariant v) => switch (v) {
    GladeVariant.glade => l.variantGlade,
    GladeVariant.autumn => l.variantAutumn,
    GladeVariant.monsoon => l.variantMonsoon,
    GladeVariant.winter => l.variantWinter,
    GladeVariant.nightSky => l.variantNightSky,
  };

  static String? how(AppLocalizations l, GladeVariant v) => switch (v) {
    GladeVariant.glade => null,
    GladeVariant.autumn => l.variantHowAutumn,
    GladeVariant.monsoon => l.variantHowMonsoon,
    GladeVariant.winter => l.variantHowWinter,
    GladeVariant.nightSky => l.variantHowNightSky,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final current = settings.canUse(settings.themeVariant, earned)
        ? settings.themeVariant
        : GladeVariant.glade;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsThemeVariant, style: theme.textTheme.bodyMedium),
          Text(
            l10n.settingsThemeVariantHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final variant in GladeVariant.values)
                Tooltip(
                  message: settings.canUse(variant, earned)
                      ? name(l10n, variant)
                      : how(l10n, variant) ?? '',
                  child: ChoiceChip(
                    avatar: settings.canUse(variant, earned)
                        ? null
                        : const Icon(Icons.lock_outline, size: 16),
                    label: Text(
                      name(l10n, variant),
                      semanticsLabel: settings.canUse(variant, earned)
                          ? null
                          : l10n.variantLocked(name(l10n, variant)),
                    ),
                    selected: current == variant,
                    onSelected: settings.canUse(variant, earned)
                        ? (_) => ref
                              .read(settingsRepositoryProvider)
                              .save(settings.copyWith(themeVariant: variant))
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A Today row at the current text size, so the effect is visible here.
class _TextPreview extends ConsumerWidget {
  const _TextPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsTextPreview,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.radio_button_unchecked),
                title: Text(context.l10n.whatsNew1Title),
                subtitle: Text(context.l10n.whenToday),
              ),
            ),
          ),
          Text(
            context.l10n.settingsTextPreviewHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The app lock switch: only offered when the phone has a screen lock.
class _AppLockTile extends ConsumerWidget {
  const _AppLockTile({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.read(authenticatorProvider);
    return FutureBuilder(
      future: auth.isAvailable(),
      builder: (context, snapshot) {
        final available = snapshot.data ?? false;
        return SwitchListTile(
          secondary: const Icon(Icons.lock_outline),
          title: Text(l10n.settingsAppLock),
          subtitle: Text(
            available
                ? l10n.settingsAppLockHint
                : l10n.settingsAppLockUnavailable,
          ),
          value: settings.appLock,
          onChanged: !available && !settings.appLock
              ? null
              : (on) async {
                  // Turning it on checks the lock works first.
                  if (on && !await auth.authenticate(l10n.lockReason)) return;
                  await ref
                      .read(settingsRepositoryProvider)
                      .save(settings.copyWith(appLock: on));
                },
        );
      },
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
