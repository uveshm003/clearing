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
import '../format.dart';
import '../item_commands.dart';
import '../widgets/reminder_editor.dart';
import '../widgets/subtask_editor.dart';
import '../widgets/when_sheet.dart';
import 'repeat_editor.dart';

/// Everything about one item (FR-03, FR-07). Text edits save automatically.
class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(itemProvider(itemId))) {
      AsyncData(value: final item?) => _ItemEditor(item: item),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This item no longer exists.')),
      ),
      _ => const Scaffold(),
    };
  }
}

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({required this.item});

  final Item item;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  late final ItemActions _actions = ref.read(itemActionsProvider);
  late final _title = TextEditingController(text: widget.item.title);
  late final _doneMeans = TextEditingController(text: widget.item.doneMeans);
  late final _notes = TextEditingController(text: widget.item.notes);
  Timer? _debounce;

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
    return switch (item.status) {
      ItemStatus.inbox => 'Not decided yet',
      ItemStatus.someday => 'Someday',
      ItemStatus.waiting => 'Waiting on ${item.waitingOn ?? 'someone'}',
      ItemStatus.done => 'Done',
      ItemStatus.trashed => 'In Trash',
      ItemStatus.active => switch (item.when) {
        When.today => 'Today',
        When.thisWeek => 'This week',
        When.anytime => 'Anytime',
        When.onDate => [
          dateLabel(item.doDate!, today),
          if (item.doTime case final t?) timeLabel(context, t),
        ].join(', '),
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
    if (_sameForSeries(latest, _opened)) return Navigator.pop(context);
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change future repeats too?'),
        content: const Text(
          'You edited this one. Future repeats can stay as they were, '
          'or start from this version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Just this one'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('This and future'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    if (choice) await ref.read(seriesActionsProvider).applyToFuture(latest);
    if (mounted) Navigator.pop(context);
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
        title: const Text('Waiting on'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
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
          actions: [
            if (item.status == ItemStatus.active)
              IconButton(
                icon: const Icon(Icons.center_focus_strong_outlined),
                tooltip: 'Focus on this',
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
                tooltip: item.mustDo ? 'Not a must-do' : 'Make it a must-do',
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
                    if (context.mounted) Navigator.pop(context);
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
                  const PopupMenuItem(
                    value: 'someday',
                    child: Text('Move to Someday'),
                  ),
                if (item.status != ItemStatus.waiting)
                  const PopupMenuItem(
                    value: 'waiting',
                    child: Text('Someone else is doing it'),
                  ),
                if (series != null) ...[
                  const PopupMenuItem(
                    value: 'future',
                    child: Text('Use for future repeats'),
                  ),
                  PopupMenuItem(
                    value: 'pause',
                    child: Text(
                      series.paused ? 'Resume repeating' : 'Pause repeating',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'stop',
                    child: Text('Stop repeating'),
                  ),
                ],
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
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
                decoration: const InputDecoration(hintText: 'Title'),
                onChanged: _textChanged,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('When'),
              subtitle: Text(_whenText()),
              onTap: _editWhen,
            ),
            if (item.status == ItemStatus.waiting) ...[
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Waiting on'),
                subtitle: Text(item.waitingOn ?? 'Someone'),
                onTap: _editWaiting,
              ),
              ListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: const Text('Follow up'),
                subtitle: Text(
                  item.followUpDate == null
                      ? 'No date'
                      : dateLabel(item.followUpDate!, today),
                ),
                onTap: _editFollowUp,
              ),
            ],
            if (item.status == ItemStatus.active || series != null)
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Repeat'),
                subtitle: Text(switch (series) {
                  null => 'Doesn’t repeat',
                  RepeatSeries(paused: true) =>
                    '${describeRepeat(series, today)} · paused',
                  _ => describeRepeat(series, today),
                }),
                onTap: done ? null : () => _editRepeat(series),
              ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Deadline'),
              subtitle: Text(
                item.deadline == null
                    ? 'None — “do on” is when you plan to do it'
                    : dateLabel(item.deadline!, today),
              ),
              trailing: item.deadline == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove deadline',
                      onPressed: () =>
                          _actions.save(item.copyWith(deadline: () => null)),
                    ),
              onTap: _editDeadline,
            ),
            if (!done) ReminderSection(item: item),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('List'),
              trailing: DropdownButton<String?>(
                value: item.listId,
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final list in lists)
                    DropdownMenuItem(value: list.id, child: Text(list.name)),
                ],
                onChanged: (id) =>
                    _actions.save(item.copyWith(listId: () => id)),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _doneMeans,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Done means…',
                  hintText: 'What does finished look like?',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onChanged: _textChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 16, 0),
              child: SubtaskEditor(itemId: item.id),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: done
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.undo),
                      label: const Text('Not done yet'),
                      onPressed: () => _actions.reopen(item),
                    )
                  : FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      onPressed: () async {
                        final latest = await _saveText();
                        if (!context.mounted) return;
                        await ref.complete(context, latest);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
