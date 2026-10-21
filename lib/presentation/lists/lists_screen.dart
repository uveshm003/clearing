import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item_list.dart';
import '../widgets/section_header.dart';

/// Open-item counts per list id, and the number of Someday items.
final _countsProvider = Provider<({Map<String, int> byList, int someday})>((
  ref,
) {
  final items = ref.watch(openItemsProvider).value ?? const [];
  final byList = <String, int>{};
  for (final item in items) {
    if (item.listId case final id?) byList[id] = (byList[id] ?? 0) + 1;
  }
  return (
    byList: byList,
    someday: items.where((i) => i.status == ItemStatus.someday).length,
  );
});

IconData listIcon(ItemList list) => switch (list.kind) {
  ListKind.lifeAdmin => Icons.receipt_long_outlined,
  ListKind.errands => Icons.shopping_bag_outlined,
  ListKind.user => Icons.label_outline,
};

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider).value ?? const [];
    final counts = ref.watch(_countsProvider);
    final visible = lists.where((l) => !l.archived).toList();
    final hidden = lists.where((l) => l.archived).toList();

    Widget tile(ItemList list) => ListTile(
      leading: Icon(listIcon(list)),
      title: Text(list.name),
      trailing: Text('${counts.byList[list.id] ?? 0}'),
      onTap: () => context.push(Routes.list(list.id)),
      onLongPress: () => _showListMenu(context, ref, list),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          for (final list in visible) tile(list),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New list'),
            onTap: () => _createList(context, ref),
          ),
          const SectionHeader('Not now'),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Someday'),
            subtitle: const Text('Ideas, not commitments'),
            trailing: Text('${counts.someday}'),
            onTap: () => context.push(Routes.someday),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Done'),
            subtitle: const Text('Recently done and the archive'),
            onTap: () => context.push(Routes.archive),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Trash'),
            subtitle: const Text('Kept for 30 days'),
            onTap: () => context.push(Routes.trash),
          ),
          if (hidden.isNotEmpty)
            ExpansionTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: Text('Hidden lists (${hidden.length})'),
              children: [for (final list in hidden) tile(list)],
            ),
        ],
      ),
    );
  }
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  String? initial,
}) async {
  final controller = TextEditingController(text: initial);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Name'),
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
  return name == null || name.trim().isEmpty ? null : name.trim();
}

Future<void> _createList(BuildContext context, WidgetRef ref) async {
  final name = await _askName(context, title: 'New list');
  if (name != null) await ref.read(listRepositoryProvider).create(name);
}

Future<void> _showListMenu(BuildContext context, WidgetRef ref, ItemList list) {
  final repo = ref.read(listRepositoryProvider);
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () async {
              Navigator.pop(sheetContext);
              final name = await _askName(
                context,
                title: 'Rename list',
                initial: list.name,
              );
              if (name != null) await repo.save(list.copyWith(name: name));
            },
          ),
          ListTile(
            leading: Icon(
              list.archived
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            title: Text(list.archived ? 'Show' : 'Hide'),
            onTap: () {
              Navigator.pop(sheetContext);
              repo.save(list.copyWith(archived: !list.archived));
            },
          ),
          if (!list.isSystem)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete list'),
              subtitle: const Text('Its items are kept, just unfiled'),
              onTap: () {
                Navigator.pop(sheetContext);
                repo.delete(list);
              },
            ),
        ],
      ),
    ),
  );
}
