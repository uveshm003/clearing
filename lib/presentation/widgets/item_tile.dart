import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../shell/two_pane.dart';

/// Items the user just ticked, so a row animating away after Done still
/// looks done ("Mist"), whatever list it leaves.
final justDone = <String>{};

/// One item in a list: a round complete-checkbox, the title and a quiet line
/// of details. Tapping opens the item.
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
  });

  final Item item;

  /// Carried-over styling: muted text, never red or alarming (FR-04).
  final bool quiet;
  final bool showDate;
  final VoidCallback? onTap;

  /// True while the row animates out of a list.
  final bool leaving;

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
    final finishing =
        _closing || (widget.leaving && justDone.contains(item.id));
    final done = item.status == ItemStatus.done || finishing;
    final quiet = widget.quiet;

    final details = <String>[
      if (widget.showDate && today != null)
        ?_whenDetail(context, today)
      // Without the date (the day is shown around it), the time still counts.
      else if (item.doTime case final minutes?)
        timeLabel(context, minutes),
      if (item.seriesId != null) context.l10n.itemTileRepeats,
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
    ];

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 16),
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
      trailing: item.mustDo
          ? Icon(
              Icons.star_rounded,
              color: glade.dawn,
              semanticLabel: context.l10n.mustDo,
            )
          : null,
      onTap: widget.onTap ?? () => openItem(context, ref, item.id),
      onLongPress: () => showItemMenu(context, ref, item),
    );
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
