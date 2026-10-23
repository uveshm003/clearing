import 'package:flutter/material.dart';

import '../../core/glade.dart';
import 'clearing_art.dart';

/// A calm, centred message for screens with nothing to show (PRD §9:
/// "helpful empty states"), over one of Glade's line drawings.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.scene,
  });

  /// Shown when there is no [scene] for this state.
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final ClearingScene? scene;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GladeSpace.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scene case final scene?)
                ClearingArt(scene)
              else
                Icon(icon, size: 48, color: scheme.outline),
              const SizedBox(height: GladeSpace.xl),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (message case final message?) ...[
                const SizedBox(height: GladeSpace.sm),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action case final action?) ...[
                const SizedBox(height: GladeSpace.xl),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
