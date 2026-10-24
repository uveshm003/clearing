import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/feature_flags.dart';
import '../../l10n/l10n.dart';

/// Developer options (§8): switches for unfinished features, and sample
/// data. Only reachable in debug builds.
class DeveloperScreen extends ConsumerWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final l10n = context.l10n;
    if (settings == null) return const Scaffold();
    final repository = ref.read(settingsRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.developerTitle)),
      body: ListView(
        children: [
          ListTile(title: Text(l10n.developerHint)),
          for (final flag in FeatureFlag.values)
            SwitchListTile(
              title: Text(flag.key),
              subtitle: Text(flag.description),
              value: settings.flag(flag),
              onChanged: (on) => repository.save(
                settings.copyWith(
                  flags: on
                      ? {...settings.flags, flag.key}
                      : ({...settings.flags}..remove(flag.key)),
                ),
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text(l10n.developerSeed),
            onTap: () => ref
                .read(itemActionsProvider)
                .capture(
                  [
                    'Pay rent fri 9am',
                    'Renew passport',
                    'Buy stamps',
                    'Call the dentist',
                    'Plan the trip',
                    'Read the lease',
                    'Back up photos',
                    'Fix the bike light',
                    'Reply to Sam',
                    'Sort the recycling',
                  ].join('\n'),
                ),
          ),
        ],
      ),
    );
  }
}
