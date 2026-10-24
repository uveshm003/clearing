import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/enums.dart';
import '../../domain/item.dart';
import '../../domain/item_list.dart';
import '../../l10n/l10n.dart';
import '../capture/capture_sheet.dart';

/// After a project's step is done (§5.4): "What's next?", with up to three
/// of its remaining steps to put on This week, or a new one to add.
Future<void> askNextStep(
  BuildContext context,
  WidgetRef ref,
  ItemList project,
  Item finished,
) {
  final remaining = [
    for (final item in ref.read(openItemsProvider).value ?? const <Item>[])
      if (item.listId == project.id &&
          item.id != finished.id &&
          (item.status == ItemStatus.active || item.status == ItemStatus.inbox))
        item,
  ];
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(
                l10n.projectNextTitle(project.name),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                remaining.isEmpty ? l10n.projectNextNone : l10n.projectNextHint,
              ),
            ),
            for (final item in remaining.take(3))
              ListTile(
                leading: const Icon(Icons.view_week_outlined),
                title: Text(item.title),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ref.read(itemActionsProvider).planThisWeek(item);
                },
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.projectAddStep),
              onTap: () {
                Navigator.pop(sheetContext);
                showCaptureSheet(context, listId: project.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
