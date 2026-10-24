import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/router.dart';
import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';
import 'coach_marks.dart';
import 'guides.dart';

/// The help centre: getting started, a short guide per area, and the rest
/// of the help (questions and answers, reminders, feedback).
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          SectionHeader(l.helpGetStarted),
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined),
            title: Text(l.welcomeTourTitle),
            subtitle: Text(l.helpTourHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.intro),
          ),
          ListTile(
            leading: const Icon(Icons.replay),
            title: Text(l.settingsReplayWelcome),
            subtitle: Text(l.settingsReplayWelcomeHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.welcome),
          ),
          SectionHeader(l.helpGuides),
          for (final topic in GuideTopic.values)
            Builder(
              builder: (context) {
                final guide = guideFor(l, topic);
                return ListTile(
                  leading: Icon(guide.icon),
                  title: Text(guide.title),
                  subtitle: Text(guide.lead),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.guide(topic.name)),
                );
              },
            ),
          SectionHeader(l.helpMore),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: Text(l.faqTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.faq),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_paused_outlined),
            title: Text(l.remindersHelpTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.remindersHelp),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settingsAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.about),
          ),
        ]),
      ),
    );
  }
}

/// One guide: its lead, then four short points.
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key, required this.topic});

  final GuideTopic topic;

  /// The tab a guide's "Show me" opens.
  static String _tab(CoachTarget target) => switch (target) {
    CoachTarget.capture || CoachTarget.today => Routes.today,
    CoachTarget.inbox => Routes.inbox,
    CoachTarget.upcoming => Routes.upcoming,
    CoachTarget.lists => Routes.lists,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final guide = guideFor(context.l10n, topic);
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.touch_app_outlined),
        label: Text(context.l10n.guideShowMe),
        onPressed: () {
          final target = coachFor(topic);
          context.go(_tab(target));
          // After the shell has laid out the tab.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ref.read(coachProvider.notifier).show(target),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(guide.lead, style: theme.textTheme.titleMedium),
          ),
          Pebble(
            children: [
              for (final point in guide.points)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GladeSpace.lg,
                    vertical: GladeSpace.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primaryContainer,
                          ),
                          child: Icon(
                            point.icon,
                            size: 20,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: GladeSpace.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                point.title,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              point.body,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
