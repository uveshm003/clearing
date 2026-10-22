import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ids.dart';
import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/local_date.dart';
import '../../domain/repeat_series.dart';
import '../../domain/template.dart';
import '../format.dart';
import '../item/repeat_editor.dart';
import '../item_commands.dart';
import '../widgets/section_header.dart';
import '../widgets/when_sheet.dart';

/// Editing one template, starting it, or making it a routine (FR-13).
class TemplateScreen extends ConsumerWidget {
  const TemplateScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(templateProvider(templateId))) {
        AsyncData(value: final template?) => _Editor(template: template),
        AsyncData() => Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This template no longer exists.')),
        ),
        _ => const Scaffold(),
      };
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.template});

  final Template template;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final _name = TextEditingController(text: widget.template.name);
  late final _doneMeans = TextEditingController(
    text: widget.template.doneMeans,
  );
  final _newStep = TextEditingController();
  final _newStepFocus = FocusNode();
  Timer? _debounce;

  Template get template => widget.template;

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _saveText();
    }
    _name.dispose();
    _doneMeans.dispose();
    _newStep.dispose();
    _newStepFocus.dispose();
    super.dispose();
  }

  LocalDate get _today =>
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());

  Future<void> _save(Template updated) =>
      ref.read(templateActionsProvider).save(updated);

  void _textChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _saveText);
  }

  Future<void> _saveText() {
    _debounce?.cancel();
    final name = _name.text.trim();
    final doneMeans = _doneMeans.text.trim();
    return _save(
      template.copyWith(
        name: name.isEmpty ? null : name,
        doneMeans: () => doneMeans.isEmpty ? null : doneMeans,
      ),
    );
  }

  Future<void> _addStep() async {
    final step = _newStep.text.trim();
    if (step.isEmpty) return;
    _newStep.clear();
    _newStepFocus.requestFocus();
    await _save(template.copyWith(steps: [...template.steps, step]));
  }

  Future<void> _start() async {
    final messenger = ScaffoldMessenger.of(context);
    await _saveText();
    final item = await ref.read(templateActionsProvider).start(widget.template);
    if (!mounted) return;
    final choice = await showWhenSheet(
      context,
      today: _today,
      title: 'When will you do it?',
    );
    // Without a choice it waits in the Inbox, like anything captured.
    if (choice != null) await ref.plan(item, choice);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            choice == null ? 'Added to the Inbox' : '“${item.title}” added',
          ),
        ),
      );
  }

  Future<void> _editRoutine(RepeatSeries? current) async {
    await _saveText();
    if (!mounted) return;
    final today = _today;
    final edited = await editRepeat(
      context,
      today: today,
      weekStart: ref.read(settingsProvider).value?.weekStart ?? DateTime.monday,
      initial:
          current ??
          RepeatSeries(
            id: newId(),
            freq: RepeatFrequency.weekly,
            weekdays: const {1, 2, 3, 4, 5},
            startDate: today,
            // Routines skip quietly by default: tomorrow is a fresh start.
            onMissed: OnMissed.skip,
            template: const SeriesTemplate(title: ''),
          ),
    );
    if (edited == null) return;
    if (current == null) {
      await ref.read(templateActionsProvider).makeRoutine(template, edited);
    } else {
      await ref.read(seriesActionsProvider).changeRule(edited);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _today;
    final seriesId = template.seriesId;
    final series = seriesId == null
        ? null
        : ref.watch(seriesProvider(seriesId)).value;
    final lists = (ref.watch(listsProvider).value ?? const [])
        .where((l) => !l.archived || l.id == template.listId)
        .toList();
    final actions = ref.read(templateActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(template.isRoutine ? 'Routine' : 'Template'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) async {
              if (value == 'stop') {
                await actions.stopRoutine(template);
              } else if (value == 'delete') {
                await actions.delete(template);
                if (context.mounted) context.pop();
              }
            },
            itemBuilder: (context) => [
              if (template.isRoutine)
                const PopupMenuItem(
                  value: 'stop',
                  child: Text('Stop the routine'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete template'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(hintText: 'Name'),
              onChanged: _textChanged,
            ),
          ),
          const SectionHeader('Steps'),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (from, to) {
              final steps = [...template.steps];
              steps.insert(to, steps.removeAt(from));
              _save(template.copyWith(steps: steps));
            },
            children: [
              for (final (i, step) in template.steps.indexed)
                ListTile(
                  key: ValueKey('$i:$step'),
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(
                      Icons.drag_indicator,
                      semanticLabel: 'Drag to reorder',
                    ),
                  ),
                  title: Text(step),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove step',
                    onPressed: () => _save(
                      template.copyWith(
                        steps: [...template.steps]..removeAt(i),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _newStep,
              focusNode: _newStepFocus,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Add a step',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add step',
                  onPressed: _addStep,
                ),
              ),
              onSubmitted: (_) => _addStep(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: TextField(
              controller: _doneMeans,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Done means…',
                border: OutlineInputBorder(),
              ),
              onChanged: _textChanged,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('List'),
            trailing: DropdownButton<String?>(
              value: template.listId,
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                for (final list in lists)
                  DropdownMenuItem(value: list.id, child: Text(list.name)),
              ],
              onChanged: (id) => _save(template.copyWith(listId: () => id)),
            ),
          ),
          const SectionHeader('Use it'),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(template.isRoutine ? 'Routine' : 'Make it a routine'),
            subtitle: Text(
              series == null
                  ? 'Arrives as a fresh checklist on the days you choose'
                  : describeRepeat(series, today),
            ),
            onTap: () => _editRoutine(series),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start now'),
              onPressed: _start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Starting makes a copy. Changing the template later won’t '
              'change items already made from it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
