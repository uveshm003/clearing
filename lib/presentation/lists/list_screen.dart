import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/item_list.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';
import '../format.dart';
import '../widgets/block_tile.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';
import '../widgets/when_sheet.dart';

final _listItemsProvider = StreamProvider.autoDispose
    .family<List<Item>, String>(
      (ref, listId) => ref.watch(itemRepositoryProvider).watchInList(listId),
    );

/// Lists in shopping mode this session (§4.8).
class ShoppingLists extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final shoppingListsProvider = NotifierProvider<ShoppingLists, Set<String>>(
  ShoppingLists.new,
);

/// The open items of one list, grouped by how settled they are. A project
/// shows its outcome first; an errands list can switch to shopping mode.
class ListScreen extends ConsumerWidget {
  const ListScreen({super.key, required this.listId});

  final String listId;

  static List<(ItemStatus, String)> _sections(AppLocalizations l10n) => [
    (ItemStatus.active, l10n.listSectionToDo),
    (ItemStatus.inbox, l10n.listSectionNotDecided),
    (ItemStatus.waiting, l10n.waitingOn),
    (ItemStatus.someday, l10n.someday),
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
    final shopping = ref.watch(shoppingListsProvider).contains(listId);
    final ticked = !shopping || today == null
        ? const <Item>[]
        : [
            for (final item
                in ref.watch(doneItemsProvider).value ?? const <Item>[])
              if (item.listId == listId &&
                  !item.archived &&
                  item.completedAt != null &&
                  LocalDate.fromDateTime(item.completedAt!) == today)
                item,
          ];

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
                ? context.l10n.listBlockEvery(
                    weekdayLong(block.weekday!),
                    timeLabel(context, block.time),
                  )
                : context.l10n.listBlockOn(
                    today == null
                        ? '${block.date}'
                        : dateLabel(block.date!, today),
                    timeLabel(context, block.time),
                  ),
          ),
          subtitle: Text(context.l10n.listBlockSubtitle),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: context.l10n.listRemoveBlock,
            onPressed: () => ref.read(blockRepositoryProvider).delete(block.id),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(list?.name ?? ''),
        actions: [
          if (list?.kind == ListKind.errands)
            IconButton(
              isSelected: shopping,
              icon: const Icon(Icons.shopping_cart_outlined),
              selectedIcon: const Icon(Icons.shopping_cart),
              tooltip: context.l10n.listShoppingMode,
              onPressed: () =>
                  ref.read(shoppingListsProvider.notifier).toggle(listId),
            ),
          IconButton(
            icon: const Icon(Icons.event_available_outlined),
            tooltip: context.l10n.listBlockOutTime,
            onPressed: schedule,
          ),
          PopupMenuButton<String>(
            tooltip: context.l10n.commonMore,
            onSelected: (_) => context.push(Routes.reorderList(listId)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reorder',
                child: Text(context.l10n.listReorder),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: list == null
                ? context.l10n.listAddToList
                : context.l10n.listAddTo(list.name),
            onPressed: () => showCaptureSheet(context, listId: listId),
          ),
        ],
      ),
      body:
          items.isEmpty &&
              blocks.isEmpty &&
              ticked.isEmpty &&
              !(list?.isProject ?? false)
          ? EmptyState(
              icon: Icons.list_alt_outlined,
              scene: ClearingScene.nest,
              title: list == null
                  ? context.l10n.listEmptyTitleThisList
                  : context.l10n.listEmptyTitle(list.name),
              message: context.l10n.listEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (list != null && list.isProject) _ProjectHeader(list: list),
                if (shopping)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      context.l10n.listShoppingHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ...blockTiles,
                for (final (status, label) in _sections(context.l10n))
                  if (items.where((i) => i.status == status).toList()
                      case final group when group.isNotEmpty) ...[
                    SectionHeader(label),
                    for (final item in group)
                      shopping
                          ? MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: TextScaler.linear(
                                  MediaQuery.textScalerOf(context).scale(1.2),
                                ),
                              ),
                              child: ItemTile(item: item, swipe: true),
                            )
                          : ItemTile(item: item, swipe: true),
                  ],
                if (ticked.isNotEmpty) ...[
                  const Divider(),
                  for (final item in ticked) ItemTile(item: item),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OutlinedButton(
                        onPressed: () async {
                          final actions = ref.read(itemActionsProvider);
                          for (final item in ticked) {
                            await actions.save(item.copyWith(archived: true));
                          }
                        },
                        child: Text(context.l10n.listClearTicked),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// A project's outcome and target, editable in place.
class _ProjectHeader extends ConsumerWidget {
  const _ProjectHeader({required this.list});

  final ItemList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final today = ref.watch(todayProvider).value;
    final repo = ref.read(listRepositoryProvider);
    return Pebble(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      highlight: true,
      children: [
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(l10n.projectOutcome),
          subtitle: Text(list.outcome ?? l10n.projectOutcomeHint),
          onTap: () async {
            final controller = TextEditingController(text: list.outcome);
            final outcome = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.projectOutcome),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: l10n.projectOutcomeHint,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            );
            controller.dispose();
            if (outcome != null) {
              await repo.save(
                list.copyWith(
                  outcome: () => outcome.trim().isEmpty ? null : outcome.trim(),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.projectTarget),
          subtitle: Text(
            list.targetDate == null || today == null
                ? l10n.projectTargetNone
                : dateLabel(list.targetDate!, today),
          ),
          onTap: () async {
            if (today == null) return;
            final picked = await pickDate(
              context,
              today: today,
              askTime: false,
            );
            if (picked != null) {
              await repo.save(list.copyWith(targetDate: () => picked.date));
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            l10n.projectOnlyNext,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
