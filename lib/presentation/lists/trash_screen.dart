import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/lifecycle.dart';
import '../../l10n/l10n.dart';
import '../widgets/clearing_art.dart';
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
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.trashDeleteForever),
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
        title: Text(context.l10n.trashTitle),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  context.l10n.trashEmptyConfirmTitle,
                  context.l10n.trashEmptyConfirmBody(items.length),
                );
                if (ok) await actions.emptyTrash();
              },
              child: Text(context.l10n.trashEmpty),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.delete_outline,
              scene: ClearingScene.leaf,
              title: context.l10n.trashEmptyTitle,
              message: context.l10n.trashEmptyMessage,
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
                      <= 1 => context.l10n.trashPurgeTomorrow,
                      final days => context.l10n.trashPurgeInDays(days),
                    }),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: context.l10n.trashRestore,
                          onPressed: () => actions.restore(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined),
                          tooltip: context.l10n.trashDeleteForever,
                          onPressed: () async {
                            final ok = await _confirm(
                              context,
                              context.l10n.trashDeleteForeverConfirmTitle,
                              context.l10n.trashDeleteForeverConfirmBody(
                                item.title,
                              ),
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
