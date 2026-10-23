import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/backup.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// Backup and restore (FR-17). Nothing leaves the phone unless the user
/// exports it, and importing never overwrites without asking.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const Scaffold();
    final theme = Theme.of(context);
    final today =
        ref.watch(todayProvider).value ??
        LocalDate.fromDateTime(DateTime.now());
    final last = settings.lastExportAt;
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    Future<void> export({required bool toFolder}) async {
      try {
        if (await actions.export(toFolder: toFolder)) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.backupSaved)));
        }
      } on Exception catch (error) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.backupExportFailed('$error'))),
          );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: pebbleSections([
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(l10n.backupIntro, style: theme.textTheme.bodyMedium),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.backupLast),
            subtitle: Text(
              last == null
                  ? l10n.backupNever
                  : '${dateLabel(LocalDate.fromDateTime(last), today)}, '
                        '${timeLabel(context, last.hour * 60 + last.minute)}',
            ),
          ),
          SectionHeader(l10n.backupExportSection),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.backupShare),
            subtitle: Text(l10n.backupShareHint),
            onTap: () => export(toFolder: false),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(l10n.backupSaveToFolder),
            onTap: () => export(toFolder: true),
          ),
          ChoiceTile<int?>(
            title: l10n.backupRemindExport,
            value: settings.exportReminderDays,
            options: [
              (14, l10n.backupEveryTwoWeeks),
              (30, l10n.backupMonthly),
              (null, l10n.backupNever),
              if (!const [14, 30, null].contains(settings.exportReminderDays))
                (
                  settings.exportReminderDays,
                  l10n.backupEveryDays(settings.exportReminderDays!),
                ),
            ],
            onChanged: (days) => ref
                .read(settingsRepositoryProvider)
                .save(settings.copyWith(exportReminderDays: () => days)),
          ),
          SectionHeader(l10n.backupRestoreSection),
          ListTile(
            leading: const Icon(Icons.restore_page_outlined),
            title: Text(l10n.backupRestoreFrom),
            subtitle: Text(l10n.backupRestoreFromHint),
            onTap: () => _restore(context, ref, today),
          ),
        ]),
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    LocalDate today,
  ) async {
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final Backup? backup;
    try {
      backup = await actions.pick();
    } on BackupFormatException catch (error) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.backupCantRestore),
            content: Text(error.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.commonOk),
              ),
            ],
          ),
        );
      }
      return;
    }
    if (backup == null || !context.mounted) return;

    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (context) => _PreviewDialog(backup: backup!, today: today),
    );
    if (mode == null || !context.mounted) return;
    if (mode == ImportMode.replace) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.backupReplaceAllTitle),
          content: Text(context.l10n.backupReplaceAllBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.backupReplace),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    await actions.restore(backup, mode);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  }
}

/// What's in the file, and the choice of merge or replace.
class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.backup, required this.today});

  final Backup backup;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final byStatus = backup.itemsByStatus;
    final open =
        (byStatus['inbox'] ?? 0) +
        (byStatus['active'] ?? 0) +
        (byStatus['waiting'] ?? 0);
    final exported = backup.exportedAt;
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(
        exported == null
            ? l10n.backupRestoreThis
            : l10n.backupFromDate(
                dateLabel(LocalDate.fromDateTime(exported), today),
              ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              l10n.backupPreviewItems(
                backup.count('items'),
                open,
                byStatus['someday'] ?? 0,
                byStatus['done'] ?? 0,
              ),
              l10n.backupPreviewLists(backup.count('lists')),
              l10n.backupPreviewRepeating(backup.count('series')),
            ].join('\n'),
          ),
          const SizedBox(height: 16),
          Text(l10n.backupMergeExplain),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImportMode.replace),
          child: Text(l10n.backupReplace),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ImportMode.merge),
          child: Text(l10n.backupMerge),
        ),
      ],
    );
  }
}
