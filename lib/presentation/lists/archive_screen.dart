import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

final _doneProvider = StreamProvider(
  (ref) => ref.watch(itemRepositoryProvider).watchDone(),
);

/// Done items (FR-18): recent ones, then the archive. Unticking one puts it
/// back where it was planned.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_doneProvider).value ?? const <Item>[];
    final days = ref.watch(settingsProvider).value?.autoArchiveDays ?? 7;
    final recent = items.where((i) => !i.archived).toList();
    final archived = items.where((i) => i.archived).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Done')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nothing done yet',
              message:
                  'Finished items rest here, and search still finds '
                  'them.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (recent.isNotEmpty) ...[
                  SectionHeader(
                    'Recently done',
                    trailing: days > 0 ? 'archived after $days days' : null,
                  ),
                  for (final item in recent) ItemTile(item: item),
                ],
                if (archived.isNotEmpty) ...[
                  const SectionHeader('Archive'),
                  for (final item in archived) ItemTile(item: item),
                ],
              ],
            ),
    );
  }
}
