import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/upcoming_rules.dart';
import '../format.dart';
import '../widgets/block_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_button.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

final _upcomingProvider = Provider<AsyncValue<UpcomingView>>((ref) {
  final today = ref.watch(todayProvider).value;
  return ref
      .watch(openItemsProvider)
      .whenData(
        (items) => today == null
            ? (days: const [], waiting: const [])
            : buildUpcoming(items, today),
      );
});

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_upcomingProvider).value;
    final today = ref.watch(todayProvider).value;
    final allBlocks = ref.watch(blocksProvider).value ?? const [];
    // Days with items or batch blocks, in order.
    final days = <LocalDate, List<Item>>{
      for (final (day, items)
          in view?.days ?? const <(LocalDate, List<Item>)>[])
        day: items,
    };
    if (today != null) {
      for (final block in allBlocks) {
        for (final day in block.datesBetween(
          today.addDays(1),
          today.addDays(upcomingDays),
        )) {
          days.putIfAbsent(day, () => const []);
        }
      }
    }
    final sortedDays = days.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming'),
        actions: const [SearchButton()],
      ),
      body: view == null || today == null
          ? const SizedBox.shrink()
          : days.isEmpty && view.waiting.isEmpty
          ? const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'Nothing scheduled',
              message: 'Items with a date in the next 30 days show up here.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final day in sortedDays) ...[
                  SectionHeader(dateLabel(day, today)),
                  for (final block in allBlocks)
                    if (block.occursOn(day)) BlockTile(block: block),
                  for (final item in days[day]!)
                    ItemTile(item: item, showDate: false),
                ],
                if (view.waiting.isNotEmpty) ...[
                  const SectionHeader('Waiting on'),
                  for (final item in view.waiting)
                    ItemTile(
                      item: item,
                      showDate: false,
                      key: ValueKey(item.id),
                    ),
                ],
              ],
            ),
    );
  }
}
