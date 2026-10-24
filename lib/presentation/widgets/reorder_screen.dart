import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';

/// Drag to reorder (FR-25): Today's items, or a list's. Each move is saved
/// as it's made; screen readers get "Move up" and "Move down" actions.
class ReorderScreen extends ConsumerStatefulWidget {
  const ReorderScreen({super.key, this.listId});

  /// A list to reorder; null for Today.
  final String? listId;

  @override
  ConsumerState<ReorderScreen> createState() => _ReorderScreenState();
}

final _listItemsProvider = StreamProvider.autoDispose
    .family<List<Item>, String>(
      (ref, listId) => ref.watch(itemRepositoryProvider).watchInList(listId),
    );

class _ReorderScreenState extends ConsumerState<ReorderScreen> {
  List<Item>? _items;

  List<Item>? _source() {
    if (widget.listId case final id?) {
      return ref.watch(_listItemsProvider(id)).value;
    }
    final view = ref.watch(todayViewProvider).value;
    if (view == null) return null;
    // Timed items keep to their times, so only untimed ones move.
    return [
      ...view.mustDo,
      ...view.alsoToday,
      ...view.carriedOver,
    ].where((i) => i.doTime == null).toList();
  }

  Future<void> _move(int from, int to) async {
    final items = [..._items!];
    final item = items.removeAt(from);
    items.insert(to.clamp(0, items.length), item);
    setState(() => _items = items);
    await ref.read(itemActionsProvider).reorder(items);
  }

  @override
  Widget build(BuildContext context) {
    _items ??= _source();
    final items = _items;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reorderTitle)),
      body: items == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    l10n.reorderHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorderItem: _move,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Semantics(
                        key: ValueKey(item.id),
                        customSemanticsActions: {
                          if (i > 0)
                            CustomSemanticsAction(
                              label: l10n.reorderMoveUp,
                            ): () =>
                                _move(i, i - 1),
                          if (i < items.length - 1)
                            CustomSemanticsAction(
                              label: l10n.reorderMoveDown,
                            ): () =>
                                _move(i, i + 1),
                        },
                        child: ListTile(
                          title: Text(item.title),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
