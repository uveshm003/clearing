import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/today_rules.dart';
import '../item_commands.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/when_sheet.dart';

final _thisWeekProvider = Provider(
  (ref) => ref
      .watch(openItemsProvider)
      .whenData((items) => items.where(isThisWeek).toList()),
);

/// Items set to "This week" without a date. Swipe-free: tapping the sun
/// moves one to Today.
class ThisWeekScreen extends ConsumerWidget {
  const ThisWeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_thisWeekProvider).value ?? const [];
    final today = ref.watch(todayProvider).value;
    final weekStart =
        ref.watch(settingsProvider).value?.weekStart ?? DateTime.monday;
    return Scaffold(
      appBar: AppBar(title: const Text('This week')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.view_week_outlined,
              title: 'Nothing set for this week',
              message:
                  'Things you mean to do this week, without picking a day, '
                  'gather here and show as one quiet row on Today.',
            )
          : ListView(
              children: [
                for (final item in items)
                  Row(
                    children: [
                      Expanded(
                        child: ItemTile(
                          item: item,
                          quiet:
                              today != null &&
                              isFromEarlierWeek(item, today, weekStart),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.wb_sunny_outlined),
                        tooltip: 'Do today',
                        onPressed: () => ref.plan(item, const WhenToday()),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
              ],
            ),
    );
  }
}
