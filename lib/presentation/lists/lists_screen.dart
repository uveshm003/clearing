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
import '../guidance/tip_card.dart';
import '../widgets/choice_sheet.dart';
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
  _ when list.isProject => Icons.flag_outlined,
  ListKind.lifeAdmin => Icons.receipt_long_outlined,
  ListKind.errands => Icons.shopping_bag_outlined,
  ListKind.user => Icons.label_outline,
};

/// A list's icon, in its colour when it has one.
Widget listIconWidget(BuildContext context, ItemList list) =>
    Icon(listIcon(list), color: ListColour.byName(list.colour)?.of(context));

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider).value ?? const [];
    final counts = ref.watch(_countsProvider);
    final visible = lists.where((l) => !l.archived).toList();
    final hidden = lists.where((l) => l.archived).toList();
    final pinned = visible.where((l) => l.pinned).toList();
    final projects = visible.where((l) => l.isProject && !l.pinned).toList();
    final plain = visible.where((l) => !l.isProject && !l.pinned).toList();
    final saved = ref.watch(savedSearchesProvider).value ?? const [];
    final grove = ref.watch(settingsProvider).value?.groveEnabled ?? false;

    Widget tile(ItemList list) => ListTile(
      leading: listIconWidget(context, list),
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
            TipCard(id: Tips.listsBlock, text: context.l10n.tipListsBlock),
            if (pinned.isNotEmpty) ...[
              SectionHeader(context.l10n.listPinned),
              Pebble(children: [for (final list in pinned) tile(list)]),
              const SizedBox(height: GladeSpace.lg),
            ],
            Pebble(
              children: [
                for (final list in plain) tile(list),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(context.l10n.listsNewList),
                  onTap: () => _createList(context, ref),
                ),
              ],
            ),
            SectionHeader(context.l10n.projectsSection),
            Pebble(
              children: [
                for (final list in projects) tile(list),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(context.l10n.projectNew),
                  onTap: () => _createList(context, ref, project: true),
                ),
              ],
            ),
            if (saved.isNotEmpty) ...[
              SectionHeader(context.l10n.savedSearchesSection),
              Pebble(
                children: [
                  for (final search in saved)
                    ListTile(
                      leading: const Icon(Icons.saved_search),
                      title: Text(search.name),
                      onTap: () => context.push(Routes.savedSearch(search.id)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: GladeSpace.lg),
            if (grove) ...[
              Pebble(
                children: [
                  ListTile(
                    leading: const Icon(Icons.park_outlined),
                    title: Text(context.l10n.groveTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.grove),
                  ),
                ],
              ),
            ],
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
            if (ref
                    .watch(settingsProvider)
                    .value
                    ?.seenTips
                    .contains(Tips.listsBlock) ??
                false)
              TipCard(id: Tips.glossSomeday, text: context.l10n.glossSomeday),
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
                  leading: const Icon(Icons.layers_outlined),
                  title: Text(context.l10n.groveCairnTitle),
                  onTap: () => context.push(Routes.cairn),
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

Future<void> _createList(
  BuildContext context,
  WidgetRef ref, {
  bool project = false,
}) async {
  final name = await _askName(
    context,
    title: project ? context.l10n.projectNew : context.l10n.listsNewList,
  );
  if (name == null) return;
  await ref.read(listRepositoryProvider).create(name, isProject: project);
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
          ListTile(
            leading: Icon(
              list.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            title: Text(
              list.pinned
                  ? sheetContext.l10n.listUnpin
                  : sheetContext.l10n.listPin,
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              repo.save(list.copyWith(pinned: !list.pinned));
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(sheetContext.l10n.listColour),
            onTap: () async {
              Navigator.pop(sheetContext);
              final picked = await showChoiceSheet<String?>(
                context,
                title: context.l10n.listColour,
                selected: list.colour,
                options: [
                  (null, context.l10n.listColourNone),
                  for (final colour in ListColour.values)
                    (colour.name, listColourName(context.l10n, colour)),
                ],
              );
              if (picked != null) {
                await repo.save(list.copyWith(colour: () => picked.value));
              }
            },
          ),
          if (!list.isSystem)
            SwitchListTile(
              secondary: const Icon(Icons.flag_outlined),
              title: Text(sheetContext.l10n.projectMakeList),
              value: list.isProject,
              onChanged: (on) {
                Navigator.pop(sheetContext);
                repo.save(list.copyWith(isProject: on));
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

String listColourName(AppLocalizations l, ListColour colour) =>
    switch (colour) {
      ListColour.moss => l.listColourMoss,
      ListColour.dawn => l.listColourDawn,
      ListColour.sky => l.listColourSky,
      ListColour.clay => l.listColourClay,
      ListColour.heather => l.listColourHeather,
    };
