import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/grove.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';

/// The cairn (§6.4): everything closed, a stone each, a pile a week. The
/// tallest weeks are drawn tallest; there's no target on any axis.
class CairnScreen extends ConsumerStatefulWidget {
  const CairnScreen({super.key});

  @override
  ConsumerState<CairnScreen> createState() => _CairnScreenState();
}

class _CairnScreenState extends ConsumerState<CairnScreen> {
  bool _oldOnly = false;
  LocalDate? _open;

  @override
  Widget build(BuildContext context) {
    final done = ref.watch(doneItemsProvider).value ?? const <Item>[];
    final weekStart = ref.watch(settingsProvider).value?.weekStart ?? 1;
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final shown = [
      for (final item in done)
        if (item.completedAt != null &&
            (!_oldOnly ||
                item.completedAt!.difference(item.createdAt).inDays >=
                    wildflowerDays))
          item,
    ];
    final weeks = <LocalDate, List<Item>>{};
    for (final item in shown) {
      final week = LocalDate.fromDateTime(
        item.completedAt!,
      ).startOfWeek(weekStart);
      (weeks[week] ??= []).add(item);
    }
    final ordered = weeks.keys.toList()..sort((a, b) => b.compareTo(a));
    final tallest = weeks.values.fold<int>(1, (m, l) => max(m, l.length));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groveCairnTitle)),
      body: done.isEmpty
          ? EmptyState(
              icon: Icons.layers_outlined,
              scene: ClearingScene.cairn,
              title: l10n.groveCairnTitle,
              message: l10n.groveCairnEmpty,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    l10n.groveCairnHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilterChip(
                      label: Text(l10n.groveCairnOldOnly),
                      selected: _oldOnly,
                      onSelected: (v) => setState(() => _oldOnly = v),
                    ),
                  ),
                ),
                for (final week in ordered) ...[
                  ListTile(
                    leading: _Stones(
                      count: weeks[week]!.length,
                      tallest: tallest,
                    ),
                    title: Text(l10n.groveCairnWeek(dateLabel(week, today))),
                    subtitle: Text(l10n.groveCairnCount(weeks[week]!.length)),
                    trailing: Icon(
                      _open == week ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () =>
                        setState(() => _open = _open == week ? null : week),
                  ),
                  if (_open == week)
                    for (final item in weeks[week]!) ItemTile(item: item),
                ],
              ],
            ),
    );
  }
}

/// A small pile of stones, as tall as the week was full.
class _Stones extends StatelessWidget {
  const _Stones({required this.count, required this.tallest});

  final int count;
  final int tallest;

  @override
  Widget build(BuildContext context) {
    final glade = GladeTokens.of(context);
    final stones = max(1, (count / tallest * 6).round());
    return ExcludeSemantics(
      child: SizedBox(
        width: 40,
        height: 44,
        child: CustomPaint(
          painter: _StonesPainter(stones, glade.art, glade.artSoft),
        ),
      ),
    );
  }
}

class _StonesPainter extends CustomPainter {
  _StonesPainter(this.stones, this.line, this.soft);

  final int stones;
  final Color line;
  final Color soft;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fill = Paint()..color = soft;
    var y = size.height - 2;
    for (var i = 0; i < stones; i++) {
      final w = 26.0 - i * 3;
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, y - 3),
        width: w,
        height: 6,
      );
      canvas
        ..drawOval(rect, fill)
        ..drawOval(rect, stroke);
      y -= 6.5;
    }
  }

  @override
  bool shouldRepaint(_StonesPainter old) =>
      old.stones != stones || old.line != line || old.soft != soft;
}
