import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/lifecycle.dart';
import '../widgets/empty_state.dart';

final _trashProvider = StreamProvider(
  (ref) => ref.watch(itemRepositoryProvider).watchTrash(),
);

/// Deleted items, kept for 30 days (FR-18). Permanent deletion only happens
/// here, by an explicit tap, or when the 30 days are up.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete forever'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_trashProvider).value ?? const <Item>[];
    final now = ref.watch(clockProvider)();
    final actions = ref.read(lifecycleActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  'Empty Trash?',
                  '${items.length} items will be deleted for good. This '
                      'can’t be undone.',
                );
                if (ok) await actions.emptyTrash();
              },
              child: const Text('Empty'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.delete_outline,
              title: 'Trash is empty',
              message:
                  'Deleted items stay here for 30 days, in case you '
                  'want them back.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                for (final item in items)
                  ListTile(
                    title: Text(item.title),
                    subtitle: Text(switch (daysUntilPurge(
                      item.trashedAt ?? now,
                      now,
                    )) {
                      <= 1 => 'Deleted for good tomorrow',
                      final days => 'Deleted for good in $days days',
                    }),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: 'Restore',
                          onPressed: () => actions.restore(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined),
                          tooltip: 'Delete forever',
                          onPressed: () async {
                            final ok = await _confirm(
                              context,
                              'Delete forever?',
                              '“${item.title}” will be gone for good.',
                            );
                            if (ok) await actions.deleteForever(item);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
