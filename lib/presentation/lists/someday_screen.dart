import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../item_commands.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/when_sheet.dart';

final _somedayProvider = StreamProvider(
  (ref) => ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.someday),
);

/// Ideas kept for later. They never appear in Today or Upcoming until
/// promoted.
class SomedayScreen extends ConsumerWidget {
  const SomedayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_somedayProvider).value ?? const [];
    final today = ref.watch(todayProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Someday')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.lightbulb_outline,
              title: 'No ideas parked here',
              message: 'Things you might do one day, without the pressure.',
            )
          : ListView(
              children: [
                for (final item in items)
                  Row(
                    children: [
                      Expanded(child: ItemTile(item: item)),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        tooltip: 'Make it a plan',
                        onPressed: today == null
                            ? null
                            : () async {
                                final choice = await showWhenSheet(
                                  context,
                                  today: today,
                                  title: 'When will you do it?',
                                );
                                if (choice != null) {
                                  await ref.plan(item, choice);
                                }
                              },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
              ],
            ),
    );
  }
}
