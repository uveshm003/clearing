import 'package:flutter/material.dart';

import '../../core/glade.dart';
import 'section_header.dart';

/// Glade's grouped card: a soft, rounded patch of bark paper that holds
/// related rows, such as Today's must-dos or an item's "When" settings.
class Pebble extends StatelessWidget {
  const Pebble({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: GladeSpace.lg),
    this.padding = const EdgeInsets.symmetric(vertical: GladeSpace.xs),
    this.highlight = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  /// A Fern fill instead of bark paper, for the one group that matters most.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: margin,
      child: Material(
        color: highlight
            ? scheme.primaryContainer.withValues(alpha: 0.55)
            : scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(GladeSpace.pebble)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// [Pebble] for slivers: wraps a lazily built list, so a long group stays
/// smooth to scroll.
class SliverPebble extends StatelessWidget {
  const SliverPebble({super.key, required this.sliver, this.highlight = false});

  final Widget sliver;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: GladeSpace.lg),
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: highlight
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : scheme.surfaceContainer,
          borderRadius: const BorderRadius.all(
            Radius.circular(GladeSpace.pebble),
          ),
        ),
        sliver: SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: GladeSpace.xs),
          sliver: sliver,
        ),
      ),
    );
  }
}

/// Groups a settings-style column into pebbles: everything between two
/// [SectionHeader]s goes on one pebble under its header. Widgets before the
/// first header stay as they are.
List<Widget> pebbleSections(List<Widget> children) {
  final out = <Widget>[];
  var group = <Widget>[];
  var grouping = false;
  void close() {
    if (group.isNotEmpty) out.add(Pebble(children: group));
    group = <Widget>[];
  }

  for (final child in children) {
    if (child is SectionHeader) {
      close();
      out.add(child);
      grouping = true;
    } else if (grouping) {
      group.add(child);
    } else {
      out.add(child);
    }
  }
  close();
  return out;
}
