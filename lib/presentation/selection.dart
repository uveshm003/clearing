import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../l10n/l10n.dart';
import 'item_commands.dart';
import 'widgets/choice_sheet.dart';
import 'widgets/item_tile.dart';
import 'widgets/when_sheet.dart';

/// Items picked for a bulk action (FR-24). Long-press starts selecting;
/// while anything is selected, a tap toggles instead of opening.
class Selection extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool get active => state.isNotEmpty;

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  void clear() => state = const {};
}

final selectionProvider = NotifierProvider<Selection, Set<String>>(
  Selection.new,
);

/// The bar that replaces the tabs while items are selected.
class SelectionBar extends ConsumerWidget {
  const SelectionBar({super.key});

  Future<List<Item>> _items(WidgetRef ref) async {
    final actions = ref.read(itemActionsProvider);
    return [
      for (final id in ref.read(selectionProvider)) ?await actions.get(id),
    ];
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    String Function(int count) message,
    Future<Object?> Function(Item item) change,
  ) async {
    final items = await _items(ref);
    if (items.isEmpty || !context.mounted) return;
    ref.read(selectionProvider.notifier).clear();
    await ref.withUndoAll(context, items, message(items.length), () async {
      for (final item in items) {
        await change(item);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectionProvider);
    final l10n = context.l10n;
    final actions = ref.read(itemActionsProvider);
    final scheme = Theme.of(context).colorScheme;

    Future<void> plan(WhenChoice choice) => _run(
      context,
      ref,
      l10n.selectPlanned,
      (item) => ref.plan(item, choice),
    );

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.selectClear,
                onPressed: () => ref.read(selectionProvider.notifier).clear(),
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.selectCount(selected.length),
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: l10n.commonDone,
                onPressed: () =>
                    _run(context, ref, l10n.selectDone, actions.complete),
              ),
              IconButton(
                icon: const Icon(Icons.wb_sunny_outlined),
                tooltip: l10n.whenToday,
                onPressed: () => plan(const WhenToday()),
              ),
              IconButton(
                icon: const Icon(Icons.view_week_outlined),
                tooltip: l10n.whenThisWeek,
                onPressed: () => plan(const WhenThisWeek()),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.commonMore,
                onSelected: (value) async {
                  switch (value) {
                    case 'date':
                      final today = ref.read(todayProvider).value;
                      if (today == null) return;
                      final choice = await pickDate(context, today: today);
                      if (choice != null) await plan(choice);
                    case 'list':
                      final lists = (ref.read(listsProvider).value ?? const [])
                          .where((l) => !l.archived)
                          .toList();
                      final picked = await showChoiceSheet<String?>(
                        context,
                        title: l10n.selectMoveToList,
                        selected: null,
                        options: [
                          (null, l10n.commonNone),
                          for (final list in lists) (list.id, list.name),
                        ],
                      );
                      if (picked == null || !context.mounted) return;
                      await _run(
                        context,
                        ref,
                        l10n.selectMoved,
                        (item) => actions.save(
                          item.copyWith(listId: () => picked.value),
                        ),
                      );
                    case 'someday':
                      await _run(
                        context,
                        ref,
                        l10n.selectSomeday,
                        actions.moveToSomeday,
                      );
                    case 'delete':
                      await _run(
                        context,
                        ref,
                        l10n.selectTrashed,
                        actions.trash,
                      );
                    case 'more':
                      final items = await _items(ref);
                      if (items.length != 1 || !context.mounted) return;
                      ref.read(selectionProvider.notifier).clear();
                      await showItemMenu(context, ref, items.single);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'date', child: Text(l10n.whenPickDate)),
                  PopupMenuItem(
                    value: 'list',
                    child: Text(l10n.selectMoveToList),
                  ),
                  PopupMenuItem(value: 'someday', child: Text(l10n.someday)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.commonDelete),
                  ),
                  if (selected.length == 1)
                    PopupMenuItem(
                      value: 'more',
                      child: Text(l10n.selectMoreActions),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a screen so Back first stops selecting.
class SelectionScope extends ConsumerWidget {
  const SelectionScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(selectionProvider).isNotEmpty;
    return PopScope(
      canPop: !active,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(selectionProvider.notifier).clear();
      },
      child: child,
    );
  }
}

/// Whether an item in [status] can be acted on in bulk.
bool selectable(ItemStatus status) =>
    status != ItemStatus.done && status != ItemStatus.trashed;
