import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../widgets/section_header.dart';

/// The settings needed so far (FR-21). Reminders, review and backup settings
/// arrive with their milestones.
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
        children: [
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
        ],
      ),
    );
  }
}
