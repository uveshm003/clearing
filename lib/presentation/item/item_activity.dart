import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/item_event.dart';
import '../../domain/local_date.dart';
import '../../domain/today_rules.dart';
import '../../l10n/l10n.dart';
import '../format.dart';

/// An item's history in one quiet line (§4.6): "Captured 12 Oct · Planned
/// 14 Oct · Carried over 3 days". Context for things that have lingered.
class ItemActivity extends ConsumerWidget {
  const ItemActivity({super.key, required this.item});

  final Item item;

  static String _entry(AppLocalizations l, ItemEvent e, String date) =>
      switch (e.kind) {
        ItemEventKind.captured => l.activityCaptured(date),
        ItemEventKind.planned => l.activityPlanned(date),
        ItemEventKind.waiting => l.activityWaiting(date),
        ItemEventKind.resolved => l.activityResolved(date),
        ItemEventKind.someday => l.activitySomeday(date),
        ItemEventKind.done => l.activityDone(date),
        ItemEventKind.reopened => l.activityReopened(date),
        ItemEventKind.trashed => l.activityTrashed(date),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(itemEventsProvider(item.id)).value ?? const [];
    final today = ref.watch(todayProvider).value;
    if (today == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Repeated plans on the same day say no more than one.
    final shown = <ItemEvent>[];
    for (final e in events) {
      final last = shown.lastOrNull;
      if (last != null &&
          last.kind == e.kind &&
          LocalDate.fromDateTime(last.at) == LocalDate.fromDateTime(e.at)) {
        continue;
      }
      shown.add(e);
    }
    final parts = [
      if (shown.isEmpty)
        l10n.activityCaptured(
          dateLabel(LocalDate.fromDateTime(item.createdAt), today),
        ),
      for (final e
          in shown.length > 6 ? shown.sublist(shown.length - 6) : shown)
        _entry(l10n, e, dateLabel(LocalDate.fromDateTime(e.at), today)),
      if (item.status == ItemStatus.active && isCarriedOver(item, today))
        l10n.activityCarried(_carriedDays(item, today)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Semantics(
        label: l10n.itemActivity,
        child: Text(
          parts.join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static int _carriedDays(Item item, LocalDate today) {
    final from = item.doDate ?? item.horizonSetOn ?? today;
    return from.daysUntil(today).clamp(1, 9999);
  }
}
