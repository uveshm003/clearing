import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../format.dart';
import '../item_commands.dart';

/// One item in a list: a round complete-checkbox, the title and a quiet line
/// of details. Tapping opens the item.
class ItemTile extends ConsumerWidget {
  const ItemTile({
    super.key,
    required this.item,
    this.quiet = false,
    this.showDate = true,
    this.onTap,
  });

  final Item item;

  /// Carried-over styling: muted text, never red or alarming (FR-04).
  final bool quiet;
  final bool showDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = ref.watch(todayProvider).value;
    final progress = ref.watch(subtaskProgressProvider).value?[item.id];
    final listName = ref
        .watch(listsProvider)
        .value
        ?.where((l) => l.id == item.listId)
        .firstOrNull
        ?.name;
    final done = item.status == ItemStatus.done;

    final details = <String>[
      if (showDate && today != null) ?_whenDetail(context, today),
      if (item.seriesId != null) 'Repeats',
      if (item.status == ItemStatus.waiting && item.waitingOn != null)
        'Waiting on ${item.waitingOn}',
      if (item.followUpDate case final followUp?
          when item.status == ItemStatus.waiting && today != null)
        'Follow up ${dateLabel(followUp, today)}',
      ?listName,
      if (progress != null && !progress.isEmpty) '$progress',
      if (item.deadline case final deadline? when today != null)
        'Deadline ${dateLabel(deadline, today)}',
    ];

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 16),
      leading: Checkbox(
        value: done,
        semanticLabel: done ? 'Mark not done' : 'Mark done',
        onChanged: (_) => done
            ? ref.read(itemActionsProvider).reopen(item)
            : ref.complete(context, item),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: quiet || done ? scheme.onSurfaceVariant : null,
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: details.isEmpty
          ? null
          : Text(
              details.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
      trailing: item.mustDo
          ? Icon(
              Icons.star_rounded,
              color: scheme.primary,
              semanticLabel: 'Must-do',
            )
          : null,
      onTap: onTap ?? () => context.push(Routes.item(item.id)),
      onLongPress: () => showItemMenu(context, ref, item),
    );
  }

  String? _whenDetail(BuildContext context, LocalDate today) {
    final doDate = item.doDate;
    if (doDate == null) return null;
    final time = switch (item.doTime) {
      final minutes? => timeLabel(context, minutes),
      null => null,
    };
    if (doDate == today) return time;
    final day = dateLabel(doDate, today);
    if (quiet) return 'From $day';
    return time == null ? day : '$day, $time';
  }
}

/// The long-press menu: everything one can do to an item without opening it.
Future<void> showItemMenu(BuildContext context, WidgetRef ref, Item item) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      void run(Future<void> Function() action) {
        Navigator.pop(sheetContext);
        action();
      }

      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  item.title,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.status == ItemStatus.active) ...[
                ListTile(
                  leading: Icon(
                    item.mustDo ? Icons.star_outline : Icons.star_rounded,
                  ),
                  title: Text(
                    item.mustDo ? 'Not a must-do' : 'Make it a must-do',
                  ),
                  onTap: () => run(() => ref.toggleMustDo(context, item)),
                ),
                ListTile(
                  leading: const Icon(Icons.redo),
                  title: const Text('Tomorrow'),
                  onTap: () => run(() => ref.snooze(context, item)),
                ),
                ListTile(
                  leading: const Icon(Icons.center_focus_strong_outlined),
                  title: const Text('Focus on this'),
                  onTap: () =>
                      run(() async => context.push(Routes.focus(item.id))),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Reschedule…'),
                onTap: () => run(() => ref.reschedule(context, item)),
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Break into steps'),
                onTap: () =>
                    run(() async => context.push(Routes.item(item.id))),
              ),
              if (item.status != ItemStatus.someday)
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Move to Someday'),
                  onTap: () => run(() => ref.someday(context, item)),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () => run(() => ref.trash(context, item)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
