import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../change_history.dart';
import '../format.dart';
import '../item_commands.dart';
import '../widgets/empty_state.dart';

/// "Recently changed" (FR-23): the session's last ten changes, each with
/// Undo, for when the snackbar went before the mistake was noticed.
class ChangesScreen extends ConsumerWidget {
  const ChangesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(changeHistoryProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.undoHistoryTitle)),
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.history,
              title: context.l10n.undoHistoryTitle,
              message: context.l10n.undoHistoryEmpty,
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    context.l10n.undoHistoryHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final entry in entries)
                  ListTile(
                    title: Text(entry.message),
                    subtitle: Text(
                      [
                        timeLabel(
                          context,
                          entry.at.hour * 60 + entry.at.minute,
                        ),
                        entry.previous.map((i) => i.title).join(', '),
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: entry.undone
                        ? Text(context.l10n.undoHistoryUndone)
                        : TextButton(
                            onPressed: () => undoEntry(
                              ref.read(itemActionsProvider),
                              ref.read(changeHistoryProvider.notifier),
                              entry,
                            ),
                            child: Text(context.l10n.commonUndo),
                          ),
                  ),
              ],
            ),
    );
  }
}
