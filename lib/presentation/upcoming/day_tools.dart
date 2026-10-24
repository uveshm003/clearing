import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../item_commands.dart';
import '../widgets/item_tile.dart';
import '../widgets/when_sheet.dart';

/// More than this many planned on one day is a full day: the must-do cap
/// plus five (§4.7).
int busyThreshold(int mustDoCap) => mustDoCap + 5;

/// "A full day: 9 planned. Spread some out?" Planning tomorrow's overwhelm
/// today is easy; this offers a calm way out.
class BusyNote extends ConsumerWidget {
  const BusyNote({super.key, required this.day, required this.items});

  final LocalDate day;
  final List<Item> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cap = ref.watch(settingsProvider).value?.mustDoCap ?? 3;
    final limit = busyThreshold(cap);
    if (items.length <= limit) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.busyDay(items.length),
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => _spread(context, ref, limit),
            child: Text(context.l10n.busySpread),
          ),
        ],
      ),
    );
  }

  /// Moves the untimed, non-must-do items beyond [limit] to the following
  /// days, one a day.
  Future<void> _spread(BuildContext context, WidgetRef ref, int limit) async {
    final movable = [
      for (final item in items.reversed)
        if (item.doTime == null && !item.mustDo) item,
    ].take(items.length - limit).toList();
    if (movable.isEmpty) return;
    final actions = ref.read(itemActionsProvider);
    await ref.withUndoAll(
      context,
      movable,
      context.l10n.busySpreadDone(movable.length),
      () async {
        for (final (i, item) in movable.indexed) {
          await actions.planOnDate(item, day.addDays(i + 1));
        }
        return null;
      },
    );
  }
}

/// A row in the week view with a handle for dragging it to another day.
class DraggableItemRow extends StatelessWidget {
  const DraggableItemRow({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: ItemTile(item: item, showDate: false)),
        Draggable<Item>(
          data: item,
          feedback: Material(
            elevation: 4,
            borderRadius: const BorderRadius.all(
              Radius.circular(GladeSpace.md),
            ),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(item.title, style: theme.textTheme.bodyMedium),
            ),
          ),
          childWhenDragging: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.drag_indicator, color: Colors.transparent),
          ),
          child: Tooltip(
            message: context.l10n.dragToDay,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.drag_indicator),
            ),
          ),
        ),
      ],
    );
  }
}

/// A day that items can be dropped on to move them there, keeping their
/// time of day.
class DayDropTarget extends ConsumerWidget {
  const DayDropTarget({super.key, required this.day, required this.child});

  final LocalDate day;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glade = GladeTokens.of(context);
    return DragTarget<Item>(
      onWillAcceptWithDetails: (details) => details.data.doDate != day,
      onAcceptWithDetails: (details) {
        final item = details.data;
        ref.withUndo(
          context,
          item,
          context.l10n.commandsRescheduled,
          () => ref.plan(item, WhenOnDate(day, time: item.doTime)),
        );
      },
      builder: (context, candidates, _) => DecoratedBox(
        decoration: BoxDecoration(
          border: candidates.isEmpty
              ? null
              : Border.all(color: glade.dawn, width: 2),
          borderRadius: const BorderRadius.all(
            Radius.circular(GladeSpace.pebble),
          ),
        ),
        child: child,
      ),
    );
  }
}
