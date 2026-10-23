import 'package:flutter/material.dart';

import '../../core/glade.dart';

/// A screen's header in Glade: a large Fraunces title over open space, with
/// an optional line beneath and an optional sky band behind it.
///
/// The band ("Open sky") lightens as Today empties. It is never the only
/// signal: [subtitle] always says what is left in words.
class GladeHeader extends StatelessWidget {
  const GladeHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.sky,
    this.trailing,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  /// The band's colour; none leaves the plain page.
  final Color? sky;
  final Widget? trailing;

  /// Icon buttons at the top end, for screens without an app bar.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gutter = gladeGutter(MediaQuery.sizeOf(context).width);
    return AnimatedContainer(
      duration: GladeMotion.settle.of(context),
      curve: GladeMotion.settle.curve,
      margin: EdgeInsets.fromLTRB(gutter - 8, 0, gutter - 8, GladeSpace.sm),
      padding: const EdgeInsets.fromLTRB(8, GladeSpace.lg, 8, GladeSpace.lg),
      decoration: BoxDecoration(
        color: sky ?? Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(GladeSpace.pebble),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.displaySmall),
                ),
                if (subtitle case final subtitle?) ...[
                  const SizedBox(height: GladeSpace.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
          ?trailing,
        ],
      ),
    );
  }
}
