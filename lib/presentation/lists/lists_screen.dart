import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../domain/enums.dart';
import '../../domain/item_list.dart';
import '../../l10n/l10n.dart';
import '../widgets/search_button.dart';
import '../../core/glade.dart';
import '../widgets/glade_header.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// Open-item counts per list id, and the number of Someday items.
final _countsProvider = Provider<({Map<String, int> byList, int someday})>((
  ref,
) {
  return (
    byList: ref.watch(listCountsProvider).value ?? const {},
    someday: ref.watch(somedayCountProvider).value ?? 0,
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
      // Only a count worth reading: an empty list shows none.
      trailing: switch (counts.byList[list.id]) {
        final n? when n > 0 => Text('$n'),
        _ => null,
      },
      onTap: () => context.push(Routes.list(list.id)),
      onLongPress: () => _showListMenu(context, ref, list),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            GladeHeader(
              title: context.l10n.tabLists,
              subtitle: context.l10n.listsSubtitle,
              actions: [
                const SearchButton(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: context.l10n.commonSettings,
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
            Pebble(
              children: [
                for (final list in visible) tile(list),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(context.l10n.listsNewList),
                  onTap: () => _createList(context, ref),
                ),
              ],
            ),
            const SizedBox(height: GladeSpace.lg),
            Pebble(
              children: [
                ListTile(
                  leading: const Icon(Icons.checklist),
                  title: Text(context.l10n.listsRoutinesTitle),
                  subtitle: Text(context.l10n.listsRoutinesSubtitle),
                  onTap: () => context.push(Routes.templates),
                ),
              ],
            ),
            SectionHeader(context.l10n.listsNotNow),
            Pebble(
              children: [
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(context.l10n.someday),
                  subtitle: Text(context.l10n.listsSomedaySubtitle),
                  trailing: counts.someday > 0
                      ? Text('${counts.someday}')
                      : null,
                  onTap: () => context.push(Routes.someday),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(context.l10n.listsDoneTitle),
                  subtitle: Text(context.l10n.listsDoneSubtitle),
                  onTap: () => context.push(Routes.archive),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(context.l10n.listsTrashTitle),
                  subtitle: Text(context.l10n.listsTrashSubtitle),
                  onTap: () => context.push(Routes.trash),
                ),
              ],
            ),
            if (hidden.isNotEmpty) ...[
              const SizedBox(height: GladeSpace.lg),
              Pebble(
                children: [
                  ExpansionTile(
                    leading: const Icon(Icons.visibility_off_outlined),
                    title: Text(context.l10n.listsHiddenLists(hidden.length)),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    children: [for (final list in hidden) tile(list)],
                  ),
                ],
              ),
            ],
          ],
        ),
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
        decoration: InputDecoration(hintText: context.l10n.commonName),
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

Future<void> _createList(BuildContext context, WidgetRef ref) async {
  final name = await _askName(context, title: context.l10n.listsNewList);
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
            title: Text(sheetContext.l10n.listsRename),
            onTap: () async {
              Navigator.pop(sheetContext);
              final name = await _askName(
                context,
                title: context.l10n.listsRenameList,
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
            title: Text(
              list.archived
                  ? sheetContext.l10n.listsShow
                  : sheetContext.l10n.listsHide,
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              repo.save(list.copyWith(archived: !list.archived));
            },
          ),
          if (!list.isSystem)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(sheetContext.l10n.listsDeleteList),
              subtitle: Text(sheetContext.l10n.listsDeleteListSubtitle),
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
