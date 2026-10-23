import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// The installed version, or null where the platform can't tell (tests).
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } on Exception {
    return null;
  }
});

/// Version, the privacy promise, feedback and licences (PRD §2.1, §9).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const sourceUrl = 'github.com/uveshm003/clearing';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Clearing', style: theme.textTheme.headlineSmall),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              [
                l10n.aboutTagline,
                if (version != null) l10n.aboutVersion(version),
              ].join('\n'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SectionHeader(l10n.aboutPrivacySection),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(l10n.aboutPrivacy),
          ),
          SectionHeader(l10n.aboutBetaSection),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.aboutSendFeedback),
            subtitle: Text(l10n.aboutSendFeedbackHint),
            onTap: () => SharePlus.instance.share(
              ShareParams(
                subject: l10n.aboutFeedbackSubject,
                text: feedbackTemplate(version),
              ),
            ),
          ),
          const _ErrorLogTiles(),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.aboutSourceCode),
            subtitle: Text(l10n.aboutSourceSubtitle(sourceUrl)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.aboutLicences),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Clearing',
              applicationVersion: version,
            ),
          ),
        ]),
      ),
    );
  }
}

/// What "Send feedback" pre-fills. Only the version: nothing about the
/// phone or its contents is added.
String feedbackTemplate(String? version) => [
  'Clearing ${version ?? ''}'.trim(),
  '',
  l10n.aboutFeedbackWhatHappened,
  '',
  l10n.aboutFeedbackExpected,
  '',
  l10n.aboutFeedbackElse,
].join('\n');

final _errorCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(errorLogProvider).count(),
);

/// Offers to include the on-phone error log with feedback, when there is
/// one. The share sheet shows the whole text before anything is sent.
class _ErrorLogTiles extends ConsumerWidget {
  const _ErrorLogTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(_errorCountProvider).value ?? 0;
    if (count == 0) return const SizedBox.shrink();
    final log = ref.read(errorLogProvider);
    final version = ref.watch(appVersionProvider).value;
    final l10n = context.l10n;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: Text(l10n.aboutSendWithErrorLog(count)),
          subtitle: Text(l10n.aboutErrorLogHint),
          onTap: () async {
            final text = await log.asText();
            await SharePlus.instance.share(
              ShareParams(
                subject: l10n.aboutFeedbackSubject,
                text:
                    '${feedbackTemplate(version)}\n\n'
                    '${l10n.aboutErrorLogHeader}\n$text',
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: Text(l10n.aboutClearErrorLog),
          onTap: () async {
            await log.clear();
            ref.invalidate(_errorCountProvider);
          },
        ),
      ],
    );
  }
}
