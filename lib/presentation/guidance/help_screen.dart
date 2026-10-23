import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/router.dart';
import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';
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
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key, required this.topic});

  final GuideTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final guide = guideFor(context.l10n, topic);
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
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
