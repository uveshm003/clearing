import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../domain/saved_search.dart';
import '../../l10n/l10n.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';

final _savedProvider = StreamProvider.autoDispose.family<SavedSearch?, String>(
  (ref, id) => ref.watch(savedSearchRepositoryProvider).watch(id),
);

/// What a saved search matches now, re-run whenever items change.
final _resultsProvider = FutureProvider.autoDispose.family<List<Item>, String>((
  ref,
  id,
) async {
  // Re-run when anything open or done changes.
  ref.watch(openItemsProvider);
  ref.watch(doneItemsProvider);
  final saved = await ref.watch(_savedProvider(id).future);
  if (saved == null) return const [];
  return ref.watch(itemRepositoryProvider).search(saved.filter);
});

/// A smart list (§4.9): a saved search, kept in the Lists tab.
class SavedSearchScreen extends ConsumerWidget {
  const SavedSearchScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(_savedProvider(id)).value;
    final results = ref.watch(_resultsProvider(id)).value ?? const <Item>[];
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(saved?.name ?? ''),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.commonMore,
            onSelected: (_) async {
              final navigator = Navigator.of(context);
              await ref.read(savedSearchRepositoryProvider).delete(id);
              navigator.pop();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.savedSearchDelete),
              ),
            ],
          ),
        ],
      ),
      body: results.isEmpty
          ? EmptyState(
              icon: Icons.saved_search,
              title: saved?.name ?? '',
              message: l10n.savedSearchEmpty,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                for (final item in results) ItemTile(item: item, swipe: true),
              ],
            ),
    );
  }
}
