import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../format.dart';

/// Contexts (FR-22): add your own, rename or remove any.
class ContextsScreen extends ConsumerWidget {
  const ContextsScreen({super.key});

  Future<String?> _askName(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          initial == null
              ? context.l10n.contextsNew
              : context.l10n.contextsRename,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
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
    return name == null || name.trim().isEmpty ? null : name.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider).value ?? const [];
    final repository = ref.read(contextRepositoryProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.contextsScreenTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.contextsNew,
        onPressed: () async {
          final name = await _askName(context);
          if (name != null) await repository.create(name);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              context.l10n.contextsHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final c in contexts)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(contextLabel(c)),
              trailing: PopupMenuButton<String>(
                tooltip: context.l10n.commonMore,
                onSelected: (value) async {
                  if (value == 'delete') {
                    await repository.delete(c.id);
                  } else {
                    final name = await _askName(
                      context,
                      initial: contextLabel(c),
                    );
                    if (name != null) await repository.rename(c, name);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(context.l10n.contextsRename),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(context.l10n.contextsDelete),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
