import 'package:flutter/material.dart';

import '../../core/glade.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import 'grove_painter.dart';

/// "spring", "monsoon", "summer"… for sentences.
String seasonName(AppLocalizations l, Season season, SeasonStyle style) =>
    switch (season) {
      Season.spring when style == SeasonStyle.monsoon => l.groveSeasonMonsoon,
      Season.spring => l.groveSeasonSpring,
      Season.summer => l.groveSeasonSummer,
      Season.autumn => l.groveSeasonAutumn,
      Season.winter => l.groveSeasonWinter,
    };

/// What a Grove element was for, in words.
String describeElement(
  AppLocalizations l,
  GroveElement e,
  LocalDateLabel label,
) {
  final date = e.date == null ? '' : label(e.date!);
  return switch (e.kind) {
    GroveKind.cairn => l.groveCairn(date, e.count),
    GroveKind.wildflower => l.groveFlower(e.label ?? '', e.count, date),
    GroveKind.tree => l.groveTree(date),
    GroveKind.oldTree => l.groveOldTree(date),
    GroveKind.stream => l.groveStream(date),
    GroveKind.bird => l.groveBird(date),
    GroveKind.bench => l.groveBench,
    GroveKind.lantern => l.groveLantern(date),
    GroveKind.steppingStone => l.groveStep(date),
  };
}

typedef LocalDateLabel = String Function(LocalDate date);

/// The painted Grove, with a text description for screen readers and taps
/// that say what each thing was for.
class GroveScene extends StatefulWidget {
  const GroveScene({
    super.key,
    required this.grove,
    this.monsoon = false,
    this.onTap,
    this.interactive = true,
  });

  final GroveState grove;
  final bool monsoon;
  final void Function(GroveElement? element)? onTap;
  final bool interactive;

  @override
  State<GroveScene> createState() => _GroveSceneState();
}

class _GroveSceneState extends State<GroveScene> {
  late List<Placed> _placed = layoutGrove(widget.grove);
  String? _highlight;

  @override
  void didUpdateWidget(GroveScene old) {
    super.didUpdateWidget(old);
    if (old.grove != widget.grove) _placed = layoutGrove(widget.grove);
  }

  String _description(AppLocalizations l) {
    final g = widget.grove;
    final lanterns = g.count(GroveKind.lantern);
    final extras = [
      if (g.count(GroveKind.stream) > 0) l.groveHasStream,
      if (g.count(GroveKind.bench) > 0) l.groveHasBench,
      if (lanterns > 0) l.groveHasLanterns(lanterns),
    ].join();
    return l.groveDescription(
      g.count(GroveKind.tree) + g.count(GroveKind.oldTree),
      g.count(GroveKind.wildflower),
      g.count(GroveKind.cairn),
      g.count(GroveKind.bird),
      extras,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      image: true,
      label: _description(context.l10n),
      child: AspectRatio(
        aspectRatio: groveSize.width / groveSize.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final scale = size.width / groveSize.width;
            final paint = CustomPaint(
              size: size,
              painter: GrovePainter(
                placed: _placed,
                season: widget.grove.season.season,
                glade: GladeTokens.of(context),
                scheme: theme.colorScheme,
                monsoon: widget.monsoon,
                highlight: _highlight,
              ),
            );
            if (!widget.interactive) return paint;
            return GestureDetector(
              onTapUp: (details) {
                final hit = hitGrove(_placed, details.localPosition / scale);
                setState(() => _highlight = hit?.element.id);
                widget.onTap?.call(hit?.element);
              },
              child: paint,
            );
          },
        ),
      ),
    );
  }
}

/// Labels a Grove date like the rest of the app.
LocalDateLabel groveDateLabel(LocalDate today) =>
    (date) => dateLabel(date, today);
