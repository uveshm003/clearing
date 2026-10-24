import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/today_rules.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/when_sheet.dart';

final _thisWeekProvider = Provider(
  (ref) => ref
      .watch(todayItemsProvider)
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
      appBar: AppBar(title: Text(context.l10n.whenThisWeek)),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.view_week_outlined,
              scene: ClearingScene.clearing,
              title: context.l10n.thisWeekEmptyTitle,
              message: context.l10n.thisWeekEmptyMessage,
            )
          : ListView(
              children: [
                for (final item in items)
                  Row(
                    children: [
                      Expanded(
                        child: ItemTile(
                          item: item,
                          swipe: true,
                          quiet:
                              today != null &&
                              isFromEarlierWeek(item, today, weekStart),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.wb_sunny_outlined),
                        tooltip: context.l10n.thisWeekDoToday,
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
