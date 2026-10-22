import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/starter_suggestion.dart';

/// Add, edit and hide starter suggestions (FR-06).
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(suggestionsProvider).value ?? const [];
    final repo = ref.read(listRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Starter suggestions')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () async {
          final title = await _askTitle(context);
          if (title != null) await repo.addSuggestion(title);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          for (final s in suggestions)
            SwitchListTile(
              title: Text(s.title),
              subtitle: s.userCreated ? const Text('Yours') : null,
              value: s.enabled,
              onChanged: (v) => repo.saveSuggestion(s.copyWith(enabled: v)),
              secondary: PopupMenuButton<String>(
                onSelected: (value) => _onMenu(context, ref, s, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (s.userCreated)
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    StarterSuggestion s,
    String value,
  ) async {
    final repo = ref.read(listRepositoryProvider);
    switch (value) {
      case 'edit':
        final title = await _askTitle(context, initial: s.title);
        if (title != null) await repo.saveSuggestion(s.copyWith(title: title));
      case 'delete':
        await repo.deleteSuggestion(s.id);
    }
  }

  Future<String?> _askTitle(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'New suggestion' : 'Edit suggestion'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
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
    return title == null || title.trim().isEmpty ? null : title.trim();
  }
}
