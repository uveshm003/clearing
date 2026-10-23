import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../capture/capture_sheet.dart';
import '../format.dart';
import '../widgets/block_tile.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

final _listItemsProvider = StreamProvider.autoDispose
    .family<List<Item>, String>(
      (ref, listId) => ref.watch(itemRepositoryProvider).watchInList(listId),
    );

/// The open items of one list, grouped by how settled they are.
class ListScreen extends ConsumerWidget {
  const ListScreen({super.key, required this.listId});

  final String listId;

  static const _sections = [
    (ItemStatus.active, 'To do'),
    (ItemStatus.inbox, 'Not decided yet'),
    (ItemStatus.waiting, 'Waiting on'),
    (ItemStatus.someday, 'Someday'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref
        .watch(listsProvider)
        .value
        ?.where((l) => l.id == listId)
        .firstOrNull;
    final items = ref.watch(_listItemsProvider(listId)).value ?? const [];
    final blocks = (ref.watch(blocksProvider).value ?? const [])
        .where((b) => b.listId == listId)
        .toList();
    final today = ref.watch(todayProvider).value;

    Future<void> schedule() async {
      final picked = await pickBlockTime(
        context,
        now: ref.read(clockProvider)(),
        weekStart:
            ref.read(settingsProvider).value?.weekStart ?? DateTime.monday,
      );
      if (picked == null) return;
      final date = picked.when.date;
      await ref
          .read(blockRepositoryProvider)
          .add(
            listId,
            date: date == null ? null : LocalDate.fromDateTime(date),
            weekday: picked.when.weekday,
            time: picked.time,
          );
    }

    final blockTiles = [
      for (final block in blocks)
        ListTile(
          leading: const Icon(Icons.event_available_outlined),
          title: Text(
            block.repeats
                ? 'Every ${weekdayLong(block.weekday!)} at '
                      '${timeLabel(context, block.time)}'
                : '${today == null ? block.date : dateLabel(block.date!, today)} '
                      'at ${timeLabel(context, block.time)}',
          ),
          subtitle: const Text('Shows as one entry on Today'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Remove time block',
            onPressed: () => ref.read(blockRepositoryProvider).delete(block.id),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(list?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_available_outlined),
            tooltip: 'Block out time',
            onPressed: schedule,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add to ${list?.name ?? 'list'}',
            onPressed: () => showCaptureSheet(context, listId: listId),
          ),
        ],
      ),
      body: items.isEmpty && blocks.isEmpty
          ? EmptyState(
              icon: Icons.list_alt_outlined,
              scene: ClearingScene.nest,
              title: 'Nothing in ${list?.name ?? 'this list'}',
              message:
                  'Add things that belong together, like errands to '
                  'run in one trip.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                ...blockTiles,
                for (final (status, label) in _sections)
                  if (items.where((i) => i.status == status).toList()
                      case final group when group.isNotEmpty) ...[
                    SectionHeader(label),
                    for (final item in group) ItemTile(item: item),
                  ],
              ],
            ),
    );
  }
}
