import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/item_actions.dart';
import '../../core/ids.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../item_commands.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/pebble.dart';
import '../widgets/reminder_editor.dart';
import '../widgets/section_header.dart';
import '../widgets/subtask_editor.dart';
import '../widgets/when_sheet.dart';
import 'repeat_editor.dart';
import 'series_calendar_screen.dart';

/// Everything about one item (FR-03, FR-07). Text edits save automatically.
///
/// On wide screens it sits in a pane beside the list; [onClose] then closes
/// the pane instead of popping a page.
class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.itemId, this.onClose});

  final String itemId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(itemProvider(itemId))) {
      AsyncData(value: final item?) => _ItemEditor(
        item: item,
        onClose: onClose,
      ),
      AsyncData() => Scaffold(
        appBar: AppBar(
          leading: onClose == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.commonClose,
                  onPressed: onClose,
                ),
        ),
        body: Center(child: Text(context.l10n.itemNoLongerExists)),
      ),
      _ => const Scaffold(),
    };
  }
}

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({required this.item, this.onClose});

  final Item item;
  final VoidCallback? onClose;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  late final ItemActions _actions = ref.read(itemActionsProvider);
  late final _title = TextEditingController(text: widget.item.title);
  late final _doneMeans = TextEditingController(text: widget.item.doneMeans);
  late final _notes = TextEditingController(text: widget.item.notes);
  Timer? _debounce;

  /// Leaves the item: closes the pane, or pops the page.
  void _close() {
    if (widget.onClose case final close?) {
      close();
    } else {
      Navigator.pop(context);
    }
  }

  /// The item as it was when opened, to tell whether a repeating item was
  /// edited during this visit.
  late Item _opened = widget.item;

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _saveText();
    }
    _title.dispose();
    _doneMeans.dispose();
    _notes.dispose();
    super.dispose();
  }

  Item get item => widget.item;

  void _textChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _saveText);
  }

  String? _clean(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  /// Applies pending text edits on top of the latest saved item and returns
  /// the result, so follow-up actions (and their undo) start from it.
  Future<Item> _saveText() async {
    _debounce?.cancel();
    final updated = item.copyWith(
      title: _clean(_title),
      doneMeans: () => _clean(_doneMeans),
      notes: () => _clean(_notes),
    );
    return updated == item ? item : _actions.save(updated);
  }

  LocalDate get _today =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  String _whenText() {
    final today = _today;
    final l10n = context.l10n;
    return switch (item.status) {
      ItemStatus.inbox => l10n.itemWhenNotDecided,
      ItemStatus.someday => l10n.someday,
      ItemStatus.waiting => switch (item.waitingOn) {
        final person? => l10n.itemWhenWaitingOn(person),
        null => l10n.itemWhenWaitingOnSomeone,
      },
      ItemStatus.done => l10n.commonDone,
      ItemStatus.trashed => l10n.itemWhenInTrash,
      ItemStatus.active => switch (item.when) {
        When.today => l10n.whenToday,
        When.thisWeek => l10n.whenThisWeek,
        When.anytime => l10n.whenAnytime,
        When.onDate => switch (item.doTime) {
          final t? => l10n.itemWhenDateAtTime(
            dateLabel(item.doDate!, today),
            timeLabel(context, t),
          ),
          null => dateLabel(item.doDate!, today),
        },
      },
    };
  }

  Future<void> _editWhen() async {
    final latest = await _saveText();
    if (!mounted) return;
    final choice = await showWhenSheet(context, today: _today);
    if (choice != null) await ref.plan(latest, choice);
  }

  Future<void> _editRepeat(RepeatSeries? current) async {
    final latest = await _saveText();
    if (!mounted) return;
    final today = _today;
    final doDate = latest.doDate;
    final edited = await editRepeat(
      context,
      weekStart: ref.read(settingsProvider).value?.weekStart ?? DateTime.monday,
      today: today,
      initial:
          current ??
          RepeatSeries(
            id: newId(),
            freq: RepeatFrequency.daily,
            startDate: doDate != null && !doDate.isBefore(today)
                ? doDate
                : today,
            onMissed: OnMissed.carryOver,
            template: SeriesTemplate(title: latest.title),
          ),
    );
    if (edited == null) return;
    final series = ref.read(seriesActionsProvider);
    if (current == null) {
      await series.startRepeating(latest, edited);
    } else {
      await series.changeRule(edited);
    }
  }

  static bool _sameForSeries(Item a, Item b) =>
      a.title == b.title &&
      a.listId == b.listId &&
      a.doTime == b.doTime &&
      a.doneMeans == b.doneMeans;

  /// Leaving a repeating item that was edited asks whether the change is for
  /// this occurrence only or for future ones too (FR-10).
  Future<void> _leave() async {
    final latest = await _saveText();
    if (!mounted) return;
    if (_sameForSeries(latest, _opened)) return _close();
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.itemFutureRepeatsTitle),
        content: Text(context.l10n.itemFutureRepeatsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.itemJustThisOne),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.itemThisAndFuture),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    if (choice) await ref.read(seriesActionsProvider).applyToFuture(latest);
    if (mounted) _close();
  }

  Future<void> _editDeadline() async {
    final picked = await pickDate(
      context,
      today: _today,
      initial: item.deadline,
      askTime: false,
    );
    if (picked != null) {
      await _actions.save(item.copyWith(deadline: () => picked.date));
    }
  }

  Future<void> _editWaiting() async {
    final controller = TextEditingController(text: item.waitingOn);
    final person = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.waitingOn),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: context.l10n.commonName),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (person == null || person.trim().isEmpty) return;
    await _actions.waitFor(item, person, followUp: item.followUpDate);
  }

  Future<void> _editFollowUp() async {
    final picked = await pickDate(
      context,
      today: _today,
      initial: item.followUpDate,
      askTime: false,
    );
    if (picked != null) {
      await _actions.save(item.copyWith(followUpDate: () => picked.date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = _today;
    final lists = (ref.watch(listsProvider).value ?? const [])
        .where((l) => !l.archived || l.id == item.listId)
        .toList();
    final done = item.status == ItemStatus.done;
    final seriesId = item.seriesId;
    final series = seriesId == null
        ? null
        : ref.watch(seriesProvider(seriesId)).value;

    return PopScope(
      // Completing or deleting pops directly; only "back" asks.
      canPop: series == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.onClose == null,
          leading: widget.onClose == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.commonClose,
                  onPressed: () => seriesId == null ? _close() : _leave(),
                ),
          actions: [
            if (item.status == ItemStatus.active)
              IconButton(
                icon: const Icon(Icons.center_focus_strong_outlined),
                tooltip: context.l10n.itemFocusOnThis,
                onPressed: () async {
                  await _saveText();
                  if (context.mounted) context.push(Routes.focus(item.id));
                },
              ),
            if (item.status == ItemStatus.active)
              IconButton(
                icon: Icon(
                  item.mustDo ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: item.mustDo ? scheme.primary : null,
                ),
                tooltip: item.mustDo
                    ? context.l10n.itemNotMustDo
                    : context.l10n.itemMakeMustDo,
                onPressed: () => ref.toggleMustDo(context, item),
              ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                final latest = await _saveText();
                if (!context.mounted) return;
                switch (value) {
                  case 'someday':
                    await ref.someday(context, latest);
                  case 'waiting':
                    await _editWaiting();
                  case 'delete':
                    await ref.trash(context, latest);
                    if (context.mounted) _close();
                  case 'future':
                    await ref.read(seriesActionsProvider).applyToFuture(latest);
                    _opened = latest;
                  case 'pause' when series != null:
                    await ref
                        .read(seriesActionsProvider)
                        .changeRule(series.copyWith(paused: !series.paused));
                  case 'stop':
                    await ref.read(seriesActionsProvider).stopRepeating(latest);
                }
              },
              itemBuilder: (context) => [
                if (item.status != ItemStatus.someday)
                  PopupMenuItem(
                    value: 'someday',
                    child: Text(context.l10n.itemMoveToSomeday),
                  ),
                if (item.status != ItemStatus.waiting)
                  PopupMenuItem(
                    value: 'waiting',
                    child: Text(context.l10n.itemSomeoneElseDoingIt),
                  ),
                if (series != null) ...[
                  PopupMenuItem(
                    value: 'future',
                    child: Text(context.l10n.itemUseForFutureRepeats),
                  ),
                  PopupMenuItem(
                    value: 'pause',
                    child: Text(
                      series.paused
                          ? context.l10n.itemResumeRepeating
                          : context.l10n.itemPauseRepeating,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'stop',
                    child: Text(context.l10n.itemStopRepeating),
                  ),
                ],
                PopupMenuItem(
                  value: 'delete',
                  child: Text(context.l10n.commonDelete),
                ),
              ],
            ),
          ],
        ),
        // Done is always in reach, whatever the scroll (Glade: one filled
        // button, full width, pinned to the bottom).
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: done
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.undo),
                    label: Text(context.l10n.itemNotDoneYet),
                    onPressed: () => _actions.reopen(item),
                  )
                : FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(context.l10n.commonDone),
                    onPressed: () async {
                      final latest = await _saveText();
                      if (!context.mounted) return;
                      await ref.complete(context, latest);
                      if (context.mounted) _close();
                    },
                  ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _title,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.headlineSmall?.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.itemTitleHint,
                ),
                onChanged: _textChanged,
              ),
            ),
            SectionHeader(context.l10n.itemPlanSection),
            Pebble(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(context.l10n.itemWhen),
                  subtitle: Text(_whenText()),
                  onTap: _editWhen,
                ),
                if (item.status == ItemStatus.waiting) ...[
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(context.l10n.waitingOn),
                    subtitle: Text(item.waitingOn ?? context.l10n.itemSomeone),
                    onTap: _editWaiting,
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: Text(context.l10n.itemFollowUp),
                    subtitle: Text(
                      item.followUpDate == null
                          ? context.l10n.itemNoDate
                          : dateLabel(item.followUpDate!, today),
                    ),
                    onTap: _editFollowUp,
                  ),
                ],
                if (item.status == ItemStatus.active || series != null)
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: Text(context.l10n.repeatTitle),
                    subtitle: Text(switch (series) {
                      null => context.l10n.itemDoesntRepeat,
                      RepeatSeries(paused: true) =>
                        context.l10n.itemRepeatPaused(
                          describeRepeat(series, today),
                        ),
                      _ => describeRepeat(series, today),
                    }),
                    onTap: done ? null : () => _editRepeat(series),
                    trailing: series == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.calendar_month_outlined),
                            tooltip: context.l10n.itemSeeAllDates,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    SeriesCalendarScreen(seriesId: series.id),
                              ),
                            ),
                          ),
                  ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(context.l10n.itemDeadline),
                  subtitle: Text(
                    item.deadline == null
                        ? context.l10n.itemDeadlineNone
                        : dateLabel(item.deadline!, today),
                  ),
                  trailing: item.deadline == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: context.l10n.itemRemoveDeadline,
                          onPressed: () => _actions.save(
                            item.copyWith(deadline: () => null),
                          ),
                        ),
                  onTap: _editDeadline,
                ),
                if (!done) ReminderSection(item: item),
              ],
            ),
            SectionHeader(context.l10n.itemDetailsSection),
            Pebble(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  title: Text(context.l10n.itemList),
                  subtitle: Text(
                    lists.where((l) => l.id == item.listId).firstOrNull?.name ??
                        context.l10n.commonNone,
                  ),
                  onTap: () async {
                    final picked = await showChoiceSheet<String?>(
                      context,
                      title: context.l10n.itemList,
                      selected: item.listId,
                      options: [
                        (null, context.l10n.commonNone),
                        for (final list in lists) (list.id, list.name),
                      ],
                    );
                    if (picked != null) {
                      await _actions.save(
                        item.copyWith(listId: () => picked.value),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _doneMeans,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: context.l10n.itemDoneMeansLabel,
                      hintText: context.l10n.itemDoneMeansHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _textChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _notes,
                    maxLines: null,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: context.l10n.itemNotes,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _textChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Pebble(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
              children: [SubtaskEditor(itemId: item.id)],
            ),
          ],
        ),
      ),
    );
  }
}
