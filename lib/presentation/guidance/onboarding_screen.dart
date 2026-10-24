import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';
import '../settings/backup_screen.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/clearing_art.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// The welcome (first launch only; never forced: Skip is on every page).
///
/// A short tour of the four verbs and the privacy promise, then "Make it
/// yours" (must-dos per day, week start, reminders, weekly review) and a
/// last page offering to capture the first thought. With [tourOnly] it is
/// just the tour, replayed from Help.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.tourOnly = false});

  final bool tourOnly;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  var _page = 0;
  AppSettings? _draft;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  AppSettings get _settings =>
      _draft ?? ref.read(settingsProvider).value ?? const AppSettings();

  void _update(AppSettings settings) => setState(() => _draft = settings);

  void _next() => _pages.nextPage(
    duration: GladeMotion.step.of(context) + const Duration(milliseconds: 100),
    curve: GladeMotion.step.curve,
  );

  /// Ends the welcome: settings saved, never shown again on its own.
  Future<void> _finish({bool capture = false}) async {
    if (widget.tourOnly) {
      context.pop();
      return;
    }
    await ref
        .read(settingsRepositoryProvider)
        .save(_settings.copyWith(onboardingDone: true, groveAsked: true));
    if (!mounted) return;
    context.go(Routes.today);
    if (capture) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) showCaptureSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tour = <({Widget art, String title, String body})>[
      (
        art: const ClearingArt(ClearingScene.clearing),
        title: l.welcomeTitle,
        body: l.welcomeBody,
      ),
      (
        art: const ClearingArt(ClearingScene.nest),
        title: l.welcomeCaptureTitle,
        body: l.welcomeCaptureBody,
      ),
      (
        art: const ClearingArt(ClearingScene.path),
        title: l.welcomeDecideTitle,
        body: l.welcomeDecideBody,
      ),
      (
        art: const ClearingArt(ClearingScene.clearing),
        title: l.welcomeTodayTitle,
        body: l.welcomeTodayBody,
      ),
      (
        art: const ClearingArt(ClearingScene.cairn),
        title: l.welcomeReviewTitle,
        body: l.welcomeReviewBody,
      ),
      (
        art: const _LockArt(),
        title: l.welcomePrivateTitle,
        body: l.welcomePrivateBody,
      ),
    ];
    final pages = <Widget>[
      for (final page in tour)
        _TourPage(art: page.art, title: page.title, body: page.body),
      if (!widget.tourOnly) ...[
        _SetupPage(settings: _settings, onChanged: _update),
        _ReadyPage(onCapture: () => _finish(capture: true), onToday: _finish),
      ],
    ];
    final lastTour = tour.length - 1;
    final onSetup = !widget.tourOnly && _page == tour.length;
    final onReady = !widget.tourOnly && _page == tour.length + 1;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: widget.tourOnly ? Text(l.welcomeTourTitle) : null,
        actions: [
          if (!onReady)
            TextButton(
              onPressed: _finish,
              child: Text(widget.tourOnly ? l.commonClose : l.commonSkip),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final (i, page) in pages.indexed)
                    Semantics(
                      label: l.welcomePageLabel(i + 1, pages.length),
                      child: page,
                    ),
                ],
              ),
            ),
            if (!onReady)
              ExcludeSemantics(
                child: _Dots(count: pages.length, current: _page),
              ),
            if (!onReady)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: switch (_page) {
                    0 when !widget.tourOnly => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _next,
                            child: Text(l.welcomeShowMe),
                          ),
                        ),
                        TextButton(
                          onPressed: _finish,
                          child: Text(l.welcomeSkip),
                        ),
                        // Moving from another phone: bring everything over.
                        TextButton.icon(
                          icon: const Icon(Icons.restore_page_outlined),
                          label: Text(l.welcomeRestore),
                          onPressed: () async {
                            if (await restoreFromFile(context, ref)) {
                              await _finish();
                            }
                          },
                        ),
                      ],
                    ),
                    _ when onSetup => FilledButton(
                      onPressed: _next,
                      child: Text(l.welcomeSetupDone),
                    ),
                    _ when widget.tourOnly && _page == lastTour => FilledButton(
                      onPressed: _finish,
                      child: Text(l.commonDone),
                    ),
                    _ => FilledButton(
                      onPressed: _next,
                      child: Text(l.commonNext),
                    ),
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.art, required this.title, required this.body});

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              art,
              const SizedBox(height: GladeSpace.xl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: GladeSpace.lg),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Make it yours": the few settings that shape the first week.
class _SetupPage extends StatelessWidget {
  const _SetupPage({required this.settings, required this.onChanged});

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Semantics(
            header: true,
            child: Text(
              l.welcomeSetupTitle,
              style: theme.textTheme.displaySmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(
            l.welcomeSetupHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SectionHeader(
          l.welcomeSetupMustDo,
          description: l.welcomeSetupMustDoHint,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (
                var n = AppSettings.minMustDoCap;
                n <= AppSettings.maxMustDoCap;
                n++
              )
                ButtonSegment(value: n, label: Text('$n')),
            ],
            selected: {settings.mustDoCap},
            onSelectionChanged: (s) =>
                onChanged(settings.copyWith(mustDoCap: s.single)),
          ),
        ),
        SectionHeader(l.welcomeSetupWeek),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final day in const [
                DateTime.monday,
                DateTime.saturday,
                DateTime.sunday,
              ])
                ButtonSegment(value: day, label: Text(weekdayLong(day))),
            ],
            selected: {settings.weekStart},
            onSelectionChanged: (s) =>
                onChanged(settings.copyWith(weekStart: s.single)),
          ),
        ),
        SectionHeader(l.welcomeSetupReminders),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<NotificationIntensity>(
            segments: [
              ButtonSegment(
                value: NotificationIntensity.off,
                label: Text(l.settingsIntensityOff),
              ),
              ButtonSegment(
                value: NotificationIntensity.gentle,
                label: Text(l.settingsIntensityGentle),
              ),
              ButtonSegment(
                value: NotificationIntensity.standard,
                label: Text(l.settingsIntensityStandard),
              ),
            ],
            selected: {settings.notificationIntensity},
            onSelectionChanged: (s) =>
                onChanged(settings.copyWith(notificationIntensity: s.single)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(switch (settings.notificationIntensity) {
            NotificationIntensity.off => l.settingsIntensityOffHint,
            NotificationIntensity.gentle => l.settingsIntensityGentleHint,
            NotificationIntensity.standard => l.settingsIntensityStandardHint,
          }, style: theme.textTheme.bodySmall),
        ),
        const SizedBox(height: 16),
        Pebble(
          children: [
            SwitchListTile(
              title: Text(l.welcomeSetupReview),
              value: settings.reviewReminder,
              onChanged: (v) => onChanged(settings.copyWith(reviewReminder: v)),
            ),
            if (settings.reviewReminder) ...[
              ChoiceTile<int>(
                title: l.settingsReviewDay,
                value: settings.reviewWeekday,
                options: [
                  for (final day in weekdaysFrom(settings.weekStart))
                    (day, weekdayLong(day)),
                ],
                onChanged: (day) =>
                    onChanged(settings.copyWith(reviewWeekday: day)),
              ),
              ListTile(
                title: Text(l.settingsReviewTime),
                subtitle: Text(timeLabel(context, settings.reviewTime)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: timeOfDay(settings.reviewTime),
                  );
                  if (time != null) {
                    onChanged(settings.copyWith(reviewTime: minutesOf(time)));
                  }
                },
              ),
            ],
          ],
        ),
        SectionHeader(l.groveAskTitle, description: l.groveAskBody),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<bool>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(l.groveAskYes)),
              ButtonSegment(value: false, label: Text(l.groveAskNo)),
            ],
            // Nothing chosen until the person chooses; unchosen means off.
            selected: settings.groveAsked ? {settings.groveEnabled} : {},
            onSelectionChanged: (s) => onChanged(
              settings.copyWith(
                groveEnabled: s.isNotEmpty && s.single,
                groveAsked: s.isNotEmpty,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.onCapture, required this.onToday});

  final VoidCallback onCapture;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              const ClearingArt(ClearingScene.clearing),
              const SizedBox(height: GladeSpace.xl),
              Semantics(
                header: true,
                child: Text(
                  l.welcomeReadyTitle,
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: GladeSpace.lg),
              Text(
                l.welcomeReadyBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GladeSpace.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.welcomeCaptureFirst),
                  onPressed: onCapture,
                ),
              ),
              const SizedBox(height: GladeSpace.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onToday,
                  child: Text(l.welcomeGoToday),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A padlock on a fern disc, for the privacy page.
class _LockArt extends StatelessWidget {
  const _LockArt();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: 116,
        height: 116,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primaryContainer,
        ),
        child: Icon(Icons.lock_outline, size: 52, color: scheme.primary),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: GladeMotion.settle.of(context),
            width: i == current ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: i == current ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Whether the welcome should open on launch: never finished, and nothing
/// captured yet (people updating from an older version skip it).
Future<bool> shouldWelcome(
  Future<AppSettings> settings,
  Future<DateTime?> firstItem,
) async => !(await settings).onboardingDone && await firstItem == null;
