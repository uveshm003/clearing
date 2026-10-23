import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/local_date.dart';
import '../../domain/template.dart';
import '../format.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

/// Routines and templates (FR-13).
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  Future<void> _create(
    BuildContext context,
    WidgetRef ref, {
    String? name,
    List<String> steps = const [],
    String? doneMeans,
  }) async {
    final title = name ?? await _askName(context);
    if (title == null) return;
    final template = await ref
        .read(templateActionsProvider)
        .create(title, steps: steps, doneMeans: doneMeans);
    if (context.mounted) context.push(Routes.template(template.id));
  }

  Future<String?> _askName(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Packing list'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name == null || name.trim().isEmpty ? null : name.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider).value ?? const <Template>[];
    final routines = templates.where((t) => t.isRoutine).toList();
    final checklists = templates.where((t) => !t.isRoutine).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Routines & templates')),
      floatingActionButton: templates.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: 'New template',
              onPressed: () => _create(context, ref),
              child: const Icon(Icons.add),
            ),
      body: templates.isEmpty
          ? EmptyState(
              icon: Icons.checklist,
              scene: ClearingScene.cairn,
              title: 'No templates yet',
              message:
                  'A template is a checklist you use again and again. Make '
                  'it a routine and it arrives on its own schedule.',
              action: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final (name, steps, doneMeans) in exampleTemplates)
                        ActionChip(
                          label: Text(name),
                          onPressed: () => _create(
                            context,
                            ref,
                            name: name,
                            steps: steps,
                            doneMeans: doneMeans,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => _create(context, ref),
                    child: const Text('Start from scratch'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (routines.isNotEmpty) ...[
                  const SectionHeader('Routines'),
                  for (final t in routines) _TemplateTile(template: t),
                ],
                if (checklists.isNotEmpty) ...[
                  const SectionHeader('Templates'),
                  for (final t in checklists) _TemplateTile(template: t),
                ],
              ],
            ),
    );
  }
}

class _TemplateTile extends ConsumerWidget {
  const _TemplateTile({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final seriesId = template.seriesId;
    final series = seriesId == null
        ? null
        : ref.watch(seriesProvider(seriesId)).value;
    final steps = template.steps.length;
    return ListTile(
      leading: Icon(template.isRoutine ? Icons.repeat : Icons.checklist),
      title: Text(template.name),
      subtitle: Text(
        [
          '$steps ${steps == 1 ? 'step' : 'steps'}',
          if (series != null) describeRepeat(series, today),
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.template(template.id)),
    );
  }
}
