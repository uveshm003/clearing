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
import '../../l10n/l10n.dart';
import '../format.dart';
import '../item/repeat_editor.dart';
import '../item_commands.dart';
import '../widgets/choice_sheet.dart';
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
          body: Center(child: Text(context.l10n.templateGone)),
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
    final l10n = context.l10n;
    await _saveText();
    final item = await ref.read(templateActionsProvider).start(widget.template);
    if (!mounted) return;
    final choice = await showWhenSheet(
      context,
      today: _today,
      title: l10n.templateWhenStart,
    );
    // Without a choice it waits in the Inbox, like anything captured.
    if (choice != null) await ref.plan(item, choice);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            choice == null
                ? l10n.templateAddedToInbox
                : l10n.templateAdded(item.title),
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          template.isRoutine ? l10n.templateRoutine : l10n.templateTemplate,
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.commonMore,
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
                PopupMenuItem(
                  value: 'stop',
                  child: Text(l10n.templateStopRoutine),
                ),
              PopupMenuItem(value: 'delete', child: Text(l10n.templateDelete)),
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
              decoration: InputDecoration(hintText: l10n.commonName),
              onChanged: _textChanged,
            ),
          ),
          SectionHeader(l10n.templateSteps),
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
                    child: Icon(
                      Icons.drag_indicator,
                      semanticLabel: l10n.templateDragToReorder,
                    ),
                  ),
                  title: Text(step),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.templateRemoveStep,
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
                hintText: l10n.templateAddStepHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.templateAddStep,
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
              decoration: InputDecoration(
                labelText: l10n.templateDoneMeans,
                border: OutlineInputBorder(),
              ),
              onChanged: _textChanged,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text(l10n.templateList),
            subtitle: Text(
              lists.where((l) => l.id == template.listId).firstOrNull?.name ??
                  l10n.commonNone,
            ),
            onTap: () async {
              final picked = await showChoiceSheet<String?>(
                context,
                title: l10n.templateList,
                selected: template.listId,
                options: [
                  (null, l10n.commonNone),
                  for (final list in lists) (list.id, list.name),
                ],
              );
              if (picked != null) {
                await _save(template.copyWith(listId: () => picked.value));
              }
            },
          ),
          SectionHeader(l10n.templateUseIt),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(
              template.isRoutine
                  ? l10n.templateRoutine
                  : l10n.templateMakeRoutine,
            ),
            subtitle: Text(
              series == null
                  ? l10n.templateMakeRoutineHint
                  : describeRepeat(series, today),
            ),
            onTap: () => _editRoutine(series),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.templateStartNow),
              onPressed: _start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.templateStartNote,
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
