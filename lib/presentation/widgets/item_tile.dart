import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../core/glade.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../item_commands.dart';
import '../selection.dart';
import '../shell/two_pane.dart';
import 'when_sheet.dart';

/// Items the user just ticked, so a row animating away after Done still
/// looks done ("Mist"), whatever list it leaves.
final justDone = <String>{};

/// One item in a list: a round complete-checkbox, the title and a quiet line
/// of details. Tapping opens the item; pressing and holding selects it for a
/// bulk action (FR-24).
///
/// Ticking it is Glade's "Mist" moment: the ring fills and a dawn underline
/// glows at once, with a light haptic, then the item completes and its list
/// lets it drift away. With animations off it completes at once.
class ItemTile extends ConsumerStatefulWidget {
  const ItemTile({
    super.key,
    required this.item,
    this.quiet = false,
    this.showDate = true,
    this.onTap,
    this.leaving = false,
    this.swipe = false,
    this.nowLine = false,
  });

  final Item item;

  /// Carried-over styling: muted text, never red or alarming (FR-04).
  final bool quiet;
  final bool showDate;
  final VoidCallback? onTap;

  /// True while the row animates out of a list.
  final bool leaving;

  /// Offers the swipe actions chosen in Settings.
  final bool swipe;

  /// Draws a "now" line above the row: the first timed item still to come.
  final bool nowLine;

  @override
  ConsumerState<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends ConsumerState<ItemTile> {
  var _closing = false;

  Item get item => widget.item;

  Future<void> _toggle() async {
    if (item.status == ItemStatus.done) {
      await ref.read(itemActionsProvider).reopen(item);
      return;
    }
    HapticFeedback.lightImpact();
    justDone.add(item.id);
    setState(() => _closing = true);
    final pause = GladeMotion.settle.of(context);
    if (pause > Duration.zero) await Future<void>.delayed(pause);
    if (!mounted) return;
    await ref.complete(context, item);
  }

  void _select() => ref.read(selectionProvider.notifier).toggle(item.id);

  Future<void> _swipe(SwipeAction action) async {
    final today = ref.read(todayProvider).value;
    switch (action) {
      case SwipeAction.none:
        break;
      case SwipeAction.done:
        await _toggle();
      case SwipeAction.tomorrow:
        await ref.snooze(context, item);
      case SwipeAction.today:
        await ref.withUndo(
          context,
          item,
          context.l10n.commandsRescheduled,
          () => ref.plan(item, const WhenToday()),
        );
      case SwipeAction.thisWeek:
        await ref.withUndo(
          context,
          item,
          context.l10n.commandsRescheduled,
          () => ref.plan(item, const WhenThisWeek()),
        );
      case SwipeAction.pickDate:
        if (today == null) return;
        final choice = await pickDate(context, today: today);
        if (choice == null || !mounted) return;
        await ref.withUndo(
          context,
          item,
          context.l10n.commandsRescheduled,
          () => ref.plan(item, choice),
        );
      case SwipeAction.someday:
        await ref.someday(context, item);
      case SwipeAction.delete:
        await ref.trash(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glade = GladeTokens.of(context);
    final today = ref.watch(todayProvider).value;
    final progress = ref.watch(subtaskProgressProvider).value?[item.id];
    final listName = ref
        .watch(listsProvider)
        .value
        ?.where((l) => l.id == item.listId)
        .firstOrNull
        ?.name;
    final contextIds = ref.watch(itemContextsProvider).value?[item.id];
    final contexts = contextIds == null || contextIds.isEmpty
        ? const <String>[]
        : [
            for (final c in ref.watch(contextsProvider).value ?? const [])
              if (contextIds.contains(c.id)) contextLabel(c),
          ];
    final selection = ref.watch(selectionProvider);
    final selecting = selection.isNotEmpty;
    final selected = selection.contains(item.id);
    final canSelect = selectable(item.status) && !widget.leaving;
    final finishing =
        _closing || (widget.leaving && justDone.contains(item.id));
    final done = item.status == ItemStatus.done || finishing;
    final quiet = widget.quiet;
    final now = ref.watch(clockProvider)();

    final details = <String>[
      if (widget.showDate && today != null)
        ?_whenDetail(context, today)
      // Without the date (the day is shown around it), the time still counts.
      else if (item.doTime case final minutes?)
        timeLabel(context, minutes),
      if (item.seriesId case final seriesId?)
        switch (ref.watch(flexibleProgressProvider(seriesId))) {
          (:final done, :final target) => context.l10n.flexibleProgress(
            done,
            target,
          ),
          null => context.l10n.itemTileRepeats,
        },
      if (item.status == ItemStatus.waiting && item.waitingOn != null)
        context.l10n.itemTileWaitingOn(item.waitingOn!),
      if (item.followUpDate case final followUp?
          when item.status == ItemStatus.waiting && today != null)
        context.l10n.itemTileFollowUp(dateLabel(followUp, today)),
      ?listName,
      if (progress != null && !progress.isEmpty)
        context.l10n.itemTileProgress(progress.done, progress.total),
      if (item.deadline case final deadline? when today != null)
        context.l10n.itemTileDeadline(dateLabel(deadline, today)),
      if (item.effort case final effort?) effortLabel(effort),
      ...contexts,
      if (item.status == ItemStatus.inbox) ?_age(context, now),
    ];

    Widget tile = ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 16),
      selected: selected,
      selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.6),
      selectedColor: scheme.onPrimaryContainer,
      leading: Checkbox(
        value: done,
        semanticLabel: done
            ? context.l10n.itemTileMarkNotDone
            : context.l10n.itemTileMarkDone,
        onChanged: finishing ? null : (_) => _toggle(),
      ),
      title: AnimatedDefaultTextStyle(
        duration: GladeMotion.glow.of(context),
        curve: GladeMotion.glow.curve,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: quiet || item.status == ItemStatus.done
              ? scheme.onSurfaceVariant
              : scheme.onSurface,
          decoration: finishing
              ? TextDecoration.underline
              : item.status == ItemStatus.done
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: finishing ? glade.dawn : scheme.onSurfaceVariant,
          decorationThickness: finishing ? 2.5 : 1,
        ),
        child: Text(item.title),
      ),
      subtitle: details.isEmpty ? null : Text(details.join(' · ')),
      trailing: selected
          ? Icon(Icons.check_circle, color: scheme.primary)
          : item.mustDo
          ? Icon(
              Icons.star_rounded,
              color: glade.dawn,
              semanticLabel: context.l10n.mustDo,
            )
          : null,
      onTap: selecting && canSelect
          ? _select
          : widget.onTap ?? () => openItem(context, ref, item.id),
      onLongPress: canSelect ? _select : () => showItemMenu(context, ref, item),
    );

    // Keys for a keyboard: Space ticks, E opens, Delete moves to Trash.
    tile = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (!finishing) _toggle();
        },
        const SingleActivator(LogicalKeyboardKey.keyE): () =>
            openItem(context, ref, item.id),
        const SingleActivator(LogicalKeyboardKey.delete): () =>
            ref.trash(context, item),
      },
      child: tile,
    );

    tile = Semantics(
      selected: selected,
      customSemanticsActions: canSelect
          ? {
              CustomSemanticsAction(
                label: selected
                    ? context.l10n.selectDeselect
                    : context.l10n.selectThis,
              ): _select,
              CustomSemanticsAction(
                label: context.l10n.selectMoreActions,
              ): () =>
                  showItemMenu(context, ref, item),
            }
          : null,
      child: tile,
    );

    final settings = ref.watch(settingsProvider).value;
    if (widget.swipe &&
        !widget.leaving &&
        !selecting &&
        item.status != ItemStatus.done &&
        settings != null) {
      tile = _Swipeable(
        item: item,
        start: settings.swipeStart,
        end: settings.swipeEnd,
        onSwipe: _swipe,
        child: tile,
      );
    }

    if (widget.nowLine) {
      tile = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NowLine(color: glade.dawn),
          tile,
        ],
      );
    }
    return tile;
  }

  /// "waiting 9 days" for an inbox item older than a week, never in red.
  String? _age(BuildContext context, DateTime now) {
    final days = now.difference(item.createdAt).inDays;
    if (days < 7) return null;
    return days < 14
        ? context.l10n.itemTileAge(days)
        : context.l10n.itemTileAgeWeeks(days ~/ 7);
  }

  String? _whenDetail(BuildContext context, LocalDate today) {
    final doDate = item.doDate;
    if (doDate == null) {
      return widget.quiet && item.horizon == WhenHorizon.thisWeek
          ? context.l10n.itemTileFromLastWeek
          : null;
    }
    final time = switch (item.doTime) {
      final minutes? => timeLabel(context, minutes),
      null => null,
    };
    if (doDate == today) return time;
    final day = dateLabel(doDate, today);
    if (widget.quiet) return context.l10n.itemTileFromDay(day);
    return time == null ? day : context.l10n.itemTileDayTime(day, time);
  }
}

/// The swipe actions from Settings, with the same labels for TalkBack.
class _Swipeable extends StatelessWidget {
  const _Swipeable({
    required this.item,
    required this.start,
    required this.end,
    required this.onSwipe,
    required this.child,
  });

  final Item item;
  final SwipeAction start;
  final SwipeAction end;
  final void Function(SwipeAction action) onSwipe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ActionPane? pane(SwipeAction action) {
      if (action == SwipeAction.none) return null;
      final (background, foreground) = switch (action) {
        SwipeAction.done ||
        SwipeAction.today => (scheme.primary, scheme.onPrimary),
        SwipeAction.delete => (
          scheme.surfaceContainerHighest,
          scheme.onSurface,
        ),
        SwipeAction.someday => (scheme.surfaceContainerHigh, scheme.onSurface),
        _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
      };
      return ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => onSwipe(action),
            icon: swipeIcon(action),
            label: swipeLabel(context, action),
            backgroundColor: background,
            foregroundColor: foreground,
          ),
        ],
      );
    }

    return Semantics(
      customSemanticsActions: {
        for (final action in {start, end})
          if (action != SwipeAction.none && action != SwipeAction.done)
            CustomSemanticsAction(label: swipeLabel(context, action)): () =>
                onSwipe(action),
      },
      child: Slidable(
        key: ValueKey('swipe-${item.id}'),
        startActionPane: pane(start),
        endActionPane: pane(end),
        child: child,
      ),
    );
  }
}

IconData swipeIcon(SwipeAction action) => switch (action) {
  SwipeAction.none => Icons.block,
  SwipeAction.done => Icons.check,
  SwipeAction.tomorrow => Icons.redo,
  SwipeAction.today => Icons.wb_sunny_outlined,
  SwipeAction.thisWeek => Icons.view_week_outlined,
  SwipeAction.pickDate => Icons.event_outlined,
  SwipeAction.someday => Icons.lightbulb_outline,
  SwipeAction.delete => Icons.delete_outline,
};

String swipeLabel(BuildContext context, SwipeAction action) {
  final l10n = context.l10n;
  return switch (action) {
    SwipeAction.none => l10n.swipeNone,
    SwipeAction.done => l10n.commonDone,
    SwipeAction.tomorrow => l10n.itemTileTomorrow,
    SwipeAction.today => l10n.whenToday,
    SwipeAction.thisWeek => l10n.whenThisWeek,
    SwipeAction.pickDate => l10n.inboxSwipePickDate,
    SwipeAction.someday => l10n.someday,
    SwipeAction.delete => l10n.commonDelete,
  };
}

/// The thin dawn line marking now, between timed items done and to come.
class _NowLine extends StatelessWidget {
  const _NowLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Row(
        children: [
          Text(
            context.l10n.itemTileNow,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 2, color: color)),
        ],
      ),
    );
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
                    item.mustDo
                        ? sheetContext.l10n.itemTileNotMustDo
                        : sheetContext.l10n.itemTileMakeMustDo,
                  ),
                  onTap: () => run(() => ref.toggleMustDo(context, item)),
                ),
                ListTile(
                  leading: const Icon(Icons.redo),
                  title: Text(sheetContext.l10n.itemTileTomorrow),
                  onTap: () => run(() => ref.snooze(context, item)),
                ),
                ListTile(
                  leading: const Icon(Icons.center_focus_strong_outlined),
                  title: Text(sheetContext.l10n.itemTileFocusOnThis),
                  onTap: () =>
                      run(() async => context.push(Routes.focus(item.id))),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(sheetContext.l10n.itemTileReschedule),
                onTap: () => run(() => ref.reschedule(context, item)),
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: Text(sheetContext.l10n.itemTileBreakIntoSteps),
                onTap: () =>
                    run(() async => context.push(Routes.item(item.id))),
              ),
              if (item.status != ItemStatus.someday)
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(sheetContext.l10n.itemTileMoveToSomeday),
                  onTap: () => run(() => ref.someday(context, item)),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(sheetContext.l10n.commonDelete),
                onTap: () => run(() => ref.trash(context, item)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
