import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ids.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/local_date.dart';
import '../../domain/reminder.dart';
import '../../domain/repeat_series.dart';
import '../format.dart';
import '../item/repeat_editor.dart';
import '../item_commands.dart';
import '../widgets/reminder_editor.dart';
import '../widgets/subtask_editor.dart';
import '../widgets/when_sheet.dart';

enum _Step { actionable, nextAction, delegate, when, details }

/// The clarify flow (PRD §4.2). One question per screen; every step after the
/// first can be skipped. Leaving early keeps the item safely in the Inbox.
class ClarifyScreen extends ConsumerWidget {
  const ClarifyScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemProvider(itemId));
    return switch (item) {
      AsyncData(value: final item?) => _ClarifyFlow(item: item),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This item no longer exists.')),
      ),
      _ => const Scaffold(),
    };
  }
}

class _ClarifyFlow extends ConsumerStatefulWidget {
  const _ClarifyFlow({required this.item});

  final Item item;

  @override
  ConsumerState<_ClarifyFlow> createState() => _ClarifyFlowState();
}

class _ClarifyFlowState extends ConsumerState<_ClarifyFlow> {
  var _step = _Step.actionable;
  late final _title = TextEditingController(text: widget.item.title);
  late final _doneMeans = TextEditingController(text: widget.item.doneMeans);
  final _person = TextEditingController();
  LocalDate? _followUp;
  bool _delegating = false;
  WhenChoice _when = const WhenAnytime();
  String? _listId;
  bool _mustDo = false;
  final _reminders = <ReminderChoice>[];
  RepeatSeries? _repeat;

  @override
  void initState() {
    super.initState();
    _listId = widget.item.listId;
  }

  @override
  void dispose() {
    _title.dispose();
    _doneMeans.dispose();
    _person.dispose();
    super.dispose();
  }

  LocalDate get _today =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  Item get _edited => widget.item.copyWith(
    title: _title.text.trim().isEmpty ? null : _title.text.trim(),
    listId: () => _listId,
    doneMeans: () =>
        _doneMeans.text.trim().isEmpty ? null : _doneMeans.text.trim(),
  );

  void _go(_Step step) => setState(() => _step = step);

  Future<void> _finish(Future<void> Function() save) async {
    await save();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveWaiting() => _finish(
    () => ref
        .read(itemActionsProvider)
        .waitFor(_edited, _person.text, followUp: _followUp),
  );

  Future<void> _savePlanned() => _finish(() async {
    var planned = await ref.plan(_edited, _when);
    final reminders = ref.read(reminderRepositoryProvider);
    for (final r in _reminders) {
      await reminders.add(
        planned.id,
        offsetMinutes: r.offsetMinutes,
        fireAt: r.fireAt,
      );
    }
    // After the reminders, so the series template includes them.
    if (_repeat case final repeat?) {
      await ref.read(seriesActionsProvider).startRepeating(planned, repeat);
      planned = (await ref.read(itemActionsProvider).get(planned.id))!;
    }
    if (_mustDo && mounted) await ref.toggleMustDo(context, planned);
  });

  /// The item as it will be once placed, for offering reminder offsets.
  Item get _placed => switch (_when) {
    WhenOnDate(:final date, :final time) => _edited.copyWith(
      doDate: () => date,
      doTime: () => time,
    ),
    _ => _edited,
  };

  LocalDate get _repeatStart => switch (_when) {
    WhenOnDate(:final date) => date,
    _ => _today,
  };

  Future<void> _addReminder() async {
    final choice = await pickReminder(
      context,
      item: _placed,
      today: _today,
      taken: {for (final r in _reminders) ?r.offsetMinutes},
    );
    if (choice == null || !mounted) return;
    setState(() => _reminders.add(choice));
    await askToNotify(context, ref);
  }

  Future<void> _editRepeat() async {
    final edited = await editRepeat(
      context,
      today: _today,
      initial:
          _repeat?.copyWith(startDate: _repeatStart) ??
          RepeatSeries(
            id: newId(),
            freq: RepeatFrequency.daily,
            startDate: _repeatStart,
            onMissed: OnMissed.carryOver,
            template: SeriesTemplate(title: _edited.title),
          ),
    );
    if (edited != null) setState(() => _repeat = edited);
  }

  bool get _whenIsToday => switch (_when) {
    WhenToday() => true,
    WhenOnDate(:final date) => !date.isAfter(_today),
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final step = _step;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text('Clarify · ${step.index + 1} of ${_Step.values.length}'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: switch (step) {
              _Step.actionable => _actionable(context),
              _Step.nextAction => _nextAction(context),
              _Step.delegate => _delegate(context),
              _Step.when => _whenStep(context),
              _Step.details => _details(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _question(
    BuildContext context,
    String question, {
    String? hint,
    required List<Widget> children,
    List<Widget> actions = const [],
  }) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          _title.text.trim().isEmpty ? widget.item.title : _title.text.trim(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(question, style: theme.textTheme.headlineSmall),
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(hint, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),
        ...children,
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ],
    );
  }

  Widget _skip(_Step next) =>
      TextButton(onPressed: () => _go(next), child: const Text('Skip'));

  Widget _actionable(BuildContext context) => _question(
    context,
    'Is this actionable?',
    children: [
      FilledButton(
        onPressed: () => _go(_Step.nextAction),
        child: const Text('Yes, there’s something to do'),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => _finish(() => ref.someday(context, widget.item)),
        child: const Text('No, keep it as an idea'),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => _finish(() => ref.trash(context, widget.item)),
        child: const Text('No, let it go'),
      ),
    ],
  );

  Widget _nextAction(BuildContext context) => _question(
    context,
    'What’s the next action?',
    hint: 'A concrete step, starting with a verb: call, buy, email, book…',
    children: [
      TextField(
        controller: _title,
        autofocus: true,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onSubmitted: (_) => _go(_Step.delegate),
      ),
    ],
    actions: [
      _skip(_Step.delegate),
      FilledButton(
        onPressed: () => _go(_Step.delegate),
        child: const Text('Next'),
      ),
    ],
  );

  Widget _delegate(BuildContext context) => _question(
    context,
    'Is someone else doing it?',
    children: _delegating
        ? [
            TextField(
              controller: _person,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Who?',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_repeat_outlined),
              title: Text(
                _followUp == null
                    ? 'Follow up on… (optional)'
                    : 'Follow up ${dateLabel(_followUp!, _today)}',
              ),
              onTap: () async {
                final picked = await pickDate(
                  context,
                  today: _today,
                  askTime: false,
                );
                if (picked != null) setState(() => _followUp = picked.date);
              },
            ),
          ]
        : [
            FilledButton(
              onPressed: () => _go(_Step.when),
              child: const Text('No, I’ll do it'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() => _delegating = true),
              child: const Text('Yes, I’m waiting on someone'),
            ),
          ],
    actions: _delegating
        ? [
            TextButton(
              onPressed: () => setState(() => _delegating = false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: _person.text.trim().isEmpty ? null : _saveWaiting,
              child: const Text('Save as Waiting'),
            ),
          ]
        : [_skip(_Step.when)],
  );

  Widget _whenStep(BuildContext context) {
    void choose(WhenChoice choice) {
      _when = choice;
      _go(_Step.details);
    }

    return _question(
      context,
      'When?',
      children: [
        ListTile(
          leading: const Icon(Icons.wb_sunny_outlined),
          title: const Text('Today'),
          onTap: () => choose(const WhenToday()),
        ),
        ListTile(
          leading: const Icon(Icons.view_week_outlined),
          title: const Text('This week'),
          onTap: () => choose(const WhenThisWeek()),
        ),
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: const Text('Pick a date'),
          onTap: () async {
            final picked = await pickDate(context, today: _today);
            if (picked != null) choose(picked);
          },
        ),
        ListTile(
          leading: const Icon(Icons.all_inclusive),
          title: const Text('Anytime'),
          subtitle: const Text('No particular day'),
          onTap: () => choose(const WhenAnytime()),
        ),
      ],
      actions: [_skip(_Step.details)],
    );
  }

  Widget _details(BuildContext context) {
    final lists = (ref.watch(listsProvider).value ?? const [])
        .where((l) => !l.archived || l.id == _listId)
        .toList();
    final mustDoAvailable = _whenIsToday;
    return _question(
      context,
      'Anything else?',
      hint: 'All optional.',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final list in lists)
              ChoiceChip(
                label: Text(list.name),
                selected: list.id == _listId,
                onSelected: (selected) =>
                    setState(() => _listId = selected ? list.id : null),
              ),
          ],
        ),
        if (mustDoAvailable)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Must-do today'),
            value: _mustDo,
            onChanged: (value) => setState(() => _mustDo = value),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_none),
          title: const Text('Remind me'),
          subtitle: Text(
            _reminders.isEmpty
                ? 'No reminder'
                : [
                    for (final r in _reminders)
                      reminderLabel(
                        context,
                        offsetMinutes: r.offsetMinutes,
                        fireAt: r.fireAt,
                        today: _today,
                      ),
                  ].join(' · '),
          ),
          trailing: _reminders.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove reminders',
                  onPressed: () => setState(_reminders.clear),
                ),
          onTap: _reminders.length < maxRemindersPerItem ? _addReminder : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.repeat),
          title: const Text('Repeat'),
          subtitle: Text(
            _repeat == null
                ? 'Doesn’t repeat'
                : describeRepeat(_repeat!, _today),
          ),
          trailing: _repeat == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Don’t repeat',
                  onPressed: () => setState(() => _repeat = null),
                ),
          onTap: _editRepeat,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _doneMeans,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Done means…',
            hintText: 'e.g. “form posted”, not “sort out taxes”',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SubtaskEditor(itemId: widget.item.id),
      ],
      actions: [
        FilledButton(onPressed: _savePlanned, child: const Text('Done')),
      ],
    );
  }
}
