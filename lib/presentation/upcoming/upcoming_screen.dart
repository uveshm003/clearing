import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/upcoming_rules.dart';
import '../format.dart';
import '../widgets/search_button.dart';
import '../widgets/empty_state.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming'),
        actions: const [SearchButton()],
      ),
      body: view == null || today == null
          ? const SizedBox.shrink()
          : view.days.isEmpty && view.waiting.isEmpty
          ? const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'Nothing scheduled',
              message: 'Items with a date in the next 30 days show up here.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final (day, items) in view.days) ...[
                  SectionHeader(dateLabel(day, today)),
                  for (final item in items)
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
