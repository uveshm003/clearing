import 'package:flutter/material.dart';

import '../../core/glade.dart';
import '../../l10n/l10n.dart';
import '../widgets/clearing_art.dart';

/// Today's "Open sky" moment (§4.2): when the last thing is ticked the
/// clearing fades in with the sun up, and a line says what the day held.
/// With animations off, it's simply there.
class AllClear extends StatelessWidget {
  const AllClear({super.key, required this.closed, this.celebrate = false});

  /// Things closed today.
  final int closed;

  /// It has just happened (rather than the screen opening on a clear day).
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = celebrate
        ? GladeMotion.glow.of(context) * 2
        : Duration.zero;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: celebrate ? 0 : 1, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: Semantics(
        liveRegion: celebrate,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const ClearingArt(ClearingScene.clearing),
              const SizedBox(height: GladeSpace.lg),
              Text(
                context.l10n.todayAllClearTitle,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: GladeSpace.xs),
              Text(
                context.l10n.todayAllClearReflection(closed),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                context.l10n.todayAllClearRest,
                style: theme.textTheme.bodyMedium?.copyWith(
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
