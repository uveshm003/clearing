import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_actions.dart';
import '../core/providers.dart';
import '../domain/item.dart';
import '../domain/today_rules.dart';
import '../l10n/l10n.dart';
import 'widgets/when_sheet.dart';

/// UI-side wrappers around [ItemActions] that add undo snackbars and dialogs,
/// shared by every screen that shows items.
///
/// Each command reads [ItemActions] up front: the widget that started it is
/// often unmounted by the change itself (a completed item leaves its list),
/// and `ref` must not be used after that, e.g. when Undo is tapped.
extension ItemCommands on WidgetRef {
  ItemActions get _actions => read(itemActionsProvider);

  Future<Item> plan(Item item, WhenChoice choice) =>
      _plan(_actions, item, choice);

  /// Runs [change], then offers to undo it by restoring [item] exactly.
  Future<void> withUndo(
    BuildContext context,
    Item item,
    String message,
    Future<Object?> Function() change,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final undoLabel = context.l10n.commonUndo;
    final actions = _actions;
    await change();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: undoLabel,
            onPressed: () => actions.undo(item),
          ),
        ),
      );
  }

  Future<void> complete(BuildContext context, Item item) => withUndo(
    context,
    item,
    context.l10n.commonDone,
    () => _actions.complete(item),
  );

  Future<void> trash(BuildContext context, Item item) => withUndo(
    context,
    item,
    context.l10n.commandsTrashed,
    () => _actions.trash(item),
  );

  Future<void> someday(BuildContext context, Item item) => withUndo(
    context,
    item,
    context.l10n.commandsSomeday,
    () => _actions.moveToSomeday(item),
  );

  Future<void> snooze(BuildContext context, Item item) => withUndo(
    context,
    item,
    context.l10n.commandsSnoozed,
    () => _actions.snoozeToTomorrow(item),
  );

  Future<void> reschedule(BuildContext context, Item item) async {
    final actions = _actions;
    final today = read(todayProvider).value;
    if (today == null) return;
    final choice = await showWhenSheet(context, today: today);
    if (choice == null || !context.mounted) return;
    await withUndo(
      context,
      item,
      context.l10n.commandsRescheduled,
      () => _plan(actions, item, choice),
    );
  }

  /// Toggles must-do. At the cap, asks which item to swap out rather than
  /// refusing silently (FR-04).
  Future<void> toggleMustDo(BuildContext context, Item item) async {
    final actions = _actions;
    if (item.mustDo) return actions.clearMustDo(item);
    final openItems = read(openItemsProvider).value ?? const [];
    final cap = read(settingsProvider).value?.mustDoCap ?? 3;
    final result = await actions.setMustDo(
      item,
      openItems: openItems,
      cap: cap,
    );
    if (result is! MustDoNeedsSwap || !context.mounted) return;

    final out = await showDialog<Item>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.commandsMustDoCapTitle(cap)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(context.l10n.commandsMustDoSwapPrompt),
          ),
          for (final current in result.current)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, current),
              child: Text(current.title),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commandsMustDoKeep),
          ),
        ],
      ),
    );
    if (out != null) await actions.swapMustDo(out: out, into: item);
  }
}

Future<Item> _plan(ItemActions actions, Item item, WhenChoice choice) =>
    switch (choice) {
      WhenToday() => actions.planToday(item),
      WhenThisWeek() => actions.planThisWeek(item),
      WhenAnytime() => actions.planAnytime(item),
      WhenOnDate(:final date, :final time) => actions.planOnDate(
        item,
        date,
        time: time,
      ),
    };
