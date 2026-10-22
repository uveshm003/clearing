import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../domain/calendar_rules.dart';
import '../format.dart';
import '../widgets/block_tile.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

/// The week timeline (FR-15): seven days with what's planned on each, one
/// week at a time.
class WeekView extends ConsumerStatefulWidget {
  const WeekView({super.key});

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  /// Weeks from the current one.
  var _offset = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider).value;
    if (today == null) return const SizedBox.shrink();
    final weekStartDay =
        ref.watch(settingsProvider).value?.weekStart ?? DateTime.monday;
    final start = today.startOfWeek(weekStartDay).addDays(7 * _offset);
    final end = start.addDays(6);
    final items = ref.watch(openItemsProvider).value ?? const [];
    final blocks = ref.watch(blocksProvider).value ?? const [];
    final week = weekTimeline(items, weekStart: start, today: today);
    final range = DateFormat('d MMM');

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous week',
              onPressed: _offset > 0 ? () => setState(() => _offset--) : null,
            ),
            Expanded(
              child: Text(
                switch (_offset) {
                  0 => 'This week',
                  1 => 'Next week',
                  _ =>
                    '${range.format(dateTimeOf(start))} – '
                        '${range.format(dateTimeOf(end))}',
                },
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next week',
              onPressed: () => setState(() => _offset++),
            ),
          ],
        ),
        if (week.anyDay.isNotEmpty) ...[
          const SectionHeader('Any day this week'),
          for (final item in week.anyDay) ItemTile(item: item),
        ],
        for (final (:day, items: dayItems) in week.days) ...[
          SectionHeader(
            dateLabel(day, today) == DateFormat.EEEE().format(dateTimeOf(day))
                ? dateLabel(day, today)
                : '${dateLabel(day, today)} · '
                      '${DateFormat('EEE d MMM').format(dateTimeOf(day))}',
          ),
          for (final block in blocks)
            if (block.occursOn(day)) BlockTile(block: block),
          for (final item in dayItems) ItemTile(item: item, showDate: false),
          if (dayItems.isEmpty && !blocks.any((b) => b.occursOn(day)))
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                day.isBefore(today) ? 'Nothing left' : 'Free',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
