import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/app_settings.dart';
import '../../domain/enums.dart';
import '../../l10n/l10n.dart';

/// [style]'s preset applied to [settings] (§4.12): one choice instead of
/// ten switches. Everything stays changeable afterwards.
AppSettings applyStyle(AppSettings settings, ClearingStyle style) =>
    switch (style) {
      ClearingStyle.minimal => settings.copyWith(
        style: () => style,
        groveEnabled: false,
        invitationsEnabled: false,
        showTips: false,
        sounds: false,
        morningDigest: false,
        planMyDay: false,
      ),
      ClearingStyle.gentle => settings.copyWith(
        style: () => style,
        groveEnabled: true,
        invitationsEnabled: false,
        showTips: true,
        sounds: false,
        planMyDay: true,
      ),
      ClearingStyle.encouraging => settings.copyWith(
        style: () => style,
        groveEnabled: true,
        invitationsEnabled: true,
        showTips: true,
        sounds: true,
        morningDigest:
            settings.notificationIntensity != NotificationIntensity.off,
        planMyDay: true,
      ),
    };

/// "Make Clearing yours".
class StyleScreen extends ConsumerWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (settings == null) return const Scaffold();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.styleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.styleHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          RadioGroup<ClearingStyle>(
            groupValue: settings.style,
            onChanged: (style) async {
              if (style == null) return;
              final messenger = ScaffoldMessenger.of(context);
              final applied = l10n.styleApplied;
              await ref
                  .read(settingsRepositoryProvider)
                  .save(applyStyle(settings, style));
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(applied)));
            },
            child: Column(
              children: [
                for (final (style, title, hint) in [
                  (
                    ClearingStyle.minimal,
                    l10n.styleMinimal,
                    l10n.styleMinimalHint,
                  ),
                  (
                    ClearingStyle.gentle,
                    l10n.styleGentle,
                    l10n.styleGentleHint,
                  ),
                  (
                    ClearingStyle.encouraging,
                    l10n.styleEncouraging,
                    l10n.styleEncouragingHint,
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: RadioListTile<ClearingStyle>(
                        value: style,
                        title: Text(title),
                        subtitle: Text(hint),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
