import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
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
                'Close your mental tabs.',
                if (version != null) 'Version $version',
              ].join('\n'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SectionHeader('Your privacy'),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'No account, no server, no analytics, no ads. Clearing can’t '
              'reach the internet at all: everything you write stays on this '
              'phone unless you export it yourself.',
            ),
          ),
          const SectionHeader('Beta'),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send feedback'),
            subtitle: const Text(
              'Opens your email or messaging app with a short template',
            ),
            onTap: () => SharePlus.instance.share(
              ShareParams(
                subject: 'Clearing feedback',
                text: feedbackTemplate(version),
              ),
            ),
          ),
          const _ErrorLogTiles(),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source code'),
            subtitle: const Text('$sourceUrl · MIT licence'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licences'),
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
  'What happened:',
  '',
  'What I expected:',
  '',
  'Anything else:',
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
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: Text('Send feedback with the error log ($count)'),
          subtitle: const Text(
            'Error types and where they happened; you see it all first',
          ),
          onTap: () async {
            final text = await log.asText();
            await SharePlus.instance.share(
              ShareParams(
                subject: 'Clearing feedback',
                text:
                    '${feedbackTemplate(version)}\n\n--- Error log ---\n$text',
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Clear the error log'),
          onTap: () async {
            await log.clear();
            ref.invalidate(_errorCountProvider);
          },
        ),
      ],
    );
  }
}
