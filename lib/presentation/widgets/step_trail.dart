import 'package:flutter/material.dart';

import '../../core/glade.dart';

/// Progress through a guided flow: short pills for clarify and the reset,
/// round stones along a path for the weekly review ("The path"). Steps done
/// are filled, the current one is ringed, the rest are faint.
class StepTrail extends StatelessWidget {
  const StepTrail({
    super.key,
    required this.count,
    required this.current,
    this.stones = false,
  });

  final int count;

  /// Zero-based.
  final int current;
  final bool stones;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = GladeMotion.settle.of(context);
    return Semantics(
      label: 'Step ${current + 1} of $count',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GladeSpace.gutter,
          vertical: GladeSpace.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0)
                stones
                    ? Expanded(
                        child: Container(
                          height: 2,
                          color: i <= current
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                      )
                    : const SizedBox(width: 6),
              if (stones)
                AnimatedContainer(
                  duration: duration,
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < current ? scheme.primary : scheme.surface,
                    border: Border.all(
                      color: i <= current
                          ? scheme.primary
                          : scheme.outlineVariant,
                      width: i == current ? 3 : 2,
                    ),
                  ),
                )
              else
                Expanded(
                  child: AnimatedContainer(
                    duration: duration,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i < current
                          ? scheme.primary
                          : i == current
                          ? scheme.primary.withValues(alpha: 0.55)
                          : scheme.outlineVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A large, full-width answer to a flow's question: an icon, the answer and
/// an optional line of explanation, on a pebble.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// The likely answer: a Fern fill instead of bark paper.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: GladeSpace.sm),
      child: Material(
        color: primary ? scheme.primaryContainer : scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(GladeSpace.pebble)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GladeSpace.lg,
                vertical: GladeSpace.md,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: primary ? scheme.onPrimaryContainer : scheme.primary,
                  ),
                  const SizedBox(width: GladeSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: primary ? scheme.onPrimaryContainer : null,
                          ),
                        ),
                        if (subtitle case final subtitle?)
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: primary
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
