import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/grove.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';

/// "Look back" (§6.5): the week in a few kind sentences at the end of the
/// review. Comparisons only ever go upwards; a light week is called quiet,
/// and that's fine.
class LookBack extends ConsumerWidget {
  const LookBack({super.key, required this.parked});

  /// Things moved to Someday during this review.
  final int parked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final done = ref.watch(doneItemsProvider).value ?? const <Item>[];
    final settings = ref.watch(settingsProvider).value;
    final today = LocalDate.fromDateTime(now);
    final weekAgo = now.subtract(const Duration(days: 7));

    final thisWeek = [
      for (final item in done)
        if (item.completedAt case final at? when at.isAfter(weekAgo)) item,
    ];
    final oldest = thisWeek.fold<Item?>(null, (best, item) {
      final waited = item.completedAt!.difference(item.createdAt);
      return best == null ||
              waited > best.completedAt!.difference(best.createdAt)
          ? item
          : best;
    });
    final oldestDays = oldest == null
        ? 0
        : oldest.completedAt!.difference(oldest.createdAt).inDays;

    // "More than any week this season", only when it's true.
    final season = seasonOf(today, settings?.hemisphere ?? Hemisphere.north);
    final weeks = <int, int>{};
    for (final item in done) {
      final at = item.completedAt;
      if (at == null || !season.contains(LocalDate.fromDateTime(at))) continue;
      if (at.isAfter(weekAgo)) continue;
      final week = now.difference(at).inDays ~/ 7;
      weeks[week] = (weeks[week] ?? 0) + 1;
    }
    final best =
        weeks.length >= 2 && thisWeek.length > weeks.values.fold(0, max);

    final lines = [
      l10n.lookBackClosed(thisWeek.length),
      if (thisWeek.isEmpty) l10n.lookBackQuiet,
      if (best) l10n.lookBackBest,
      if (oldest != null && oldestDays >= 7)
        l10n.lookBackOldest(oldest.title, oldestDays),
      if (parked > 0) l10n.lookBackParked(parked),
      if (settings?.groveEnabled ?? false) l10n.lookBackTree,
    ];
    return Semantics(
      container: true,
      label: l10n.lookBackTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lookBackTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final (i, line) in lines.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: i == 0
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}
