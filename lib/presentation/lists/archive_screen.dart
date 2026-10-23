import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/item.dart';
import '../../l10n/l10n.dart';
import '../widgets/clearing_art.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/section_header.dart';

final _doneProvider = StreamProvider(
  (ref) => ref.watch(itemRepositoryProvider).watchDone(),
);

/// Done items (FR-18): recent ones, then the archive. Unticking one puts it
/// back where it was planned.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_doneProvider).value ?? const <Item>[];
    final days = ref.watch(settingsProvider).value?.autoArchiveDays ?? 7;
    final recent = items.where((i) => !i.archived).toList();
    final archived = items.where((i) => i.archived).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.archiveTitle)),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.inventory_2_outlined,
              scene: ClearingScene.cairn,
              title: context.l10n.archiveEmptyTitle,
              message: context.l10n.archiveEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (recent.isNotEmpty) ...[
                  SectionHeader(
                    context.l10n.archiveRecentlyDone,
                    trailing: days > 0
                        ? context.l10n.archiveArchivedAfter(days)
                        : null,
                  ),
                  for (final item in recent) ItemTile(item: item),
                ],
                if (archived.isNotEmpty) ...[
                  SectionHeader(context.l10n.archiveSection),
                  for (final item in archived) ItemTile(item: item),
                ],
              ],
            ),
    );
  }
}
