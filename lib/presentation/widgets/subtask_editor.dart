import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/subtask.dart';
import '../item_commands.dart';

/// Steps for an item (FR-07). Completing the last one offers to complete the
/// item itself.
class SubtaskEditor extends ConsumerStatefulWidget {
  const SubtaskEditor({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<SubtaskEditor> createState() => _SubtaskEditorState();
}

class _SubtaskEditorState extends ConsumerState<SubtaskEditor> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    await ref.read(itemRepositoryProvider).addSubtask(widget.itemId, title);
    _controller.clear();
    _focus.requestFocus();
  }

  Future<void> _toggle(Subtask subtask, List<Subtask> all) async {
    final updated = subtask.copyWith(done: !subtask.done);
    await ref.read(itemRepositoryProvider).saveSubtask(updated);
    final allDone = all.every(
      (s) => s.id == subtask.id ? updated.done : s.done,
    );
    if (!allDone || !mounted) return;

    final item = await ref.read(itemRepositoryProvider).getItem(widget.itemId);
    if (item == null || item.status == ItemStatus.done || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('All steps done'),
          action: SnackBarAction(
            label: 'Complete item',
            onPressed: () => ref.complete(context, item),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtasks =
        ref.watch(subtasksProvider(widget.itemId)).value ?? const [];
    final progress = SubtaskProgress.of(subtasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Steps', style: theme.textTheme.titleSmall)),
            if (!progress.isEmpty)
              Text(
                '$progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        for (final subtask in subtasks)
          Row(
            children: [
              Checkbox(
                value: subtask.done,
                semanticLabel: subtask.title,
                onChanged: (_) => _toggle(subtask, subtasks),
              ),
              Expanded(
                child: Text(
                  subtask.title,
                  style: subtask.done
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Remove step ${subtask.title}',
                onPressed: () =>
                    ref.read(itemRepositoryProvider).deleteSubtask(subtask.id),
              ),
            ],
          ),
        Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.add, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Add a step'),
                onSubmitted: (_) => _add(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
