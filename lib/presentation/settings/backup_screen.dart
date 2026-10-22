import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/backup.dart';
import '../../domain/local_date.dart';
import '../format.dart';
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

    Future<void> export({required bool toFolder}) async {
      try {
        if (await actions.export(toFolder: toFolder)) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Backup saved')));
        }
      } on Exception catch (error) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Couldn’t export: $error')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              'Everything stays on this phone, with no account and no cloud. '
              'Uninstalling Clearing or losing the phone deletes your data '
              'unless you’ve exported a copy.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Last backup'),
            subtitle: Text(
              last == null
                  ? 'Never'
                  : '${dateLabel(LocalDate.fromDateTime(last), today)}, '
                        '${timeLabel(context, last.hour * 60 + last.minute)}',
            ),
          ),
          const SectionHeader('Export'),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share a backup'),
            subtitle: const Text('Send it to email, Drive, or another app'),
            onTap: () => export(toFolder: false),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to a folder'),
            onTap: () => export(toFolder: true),
          ),
          ListTile(
            title: const Text('Remind me to export'),
            trailing: DropdownButton<int?>(
              value: settings.exportReminderDays,
              underline: const SizedBox.shrink(),
              items: [
                for (final (days, label) in const [
                  (14, 'Every 2 weeks'),
                  (30, 'Monthly'),
                  (null, 'Never'),
                ])
                  DropdownMenuItem(value: days, child: Text(label)),
                if (!const [14, 30, null].contains(settings.exportReminderDays))
                  DropdownMenuItem(
                    value: settings.exportReminderDays,
                    child: Text('Every ${settings.exportReminderDays} days'),
                  ),
              ],
              onChanged: (days) => ref
                  .read(settingsRepositoryProvider)
                  .save(settings.copyWith(exportReminderDays: () => days)),
            ),
          ),
          const SectionHeader('Restore'),
          ListTile(
            leading: const Icon(Icons.restore_page_outlined),
            title: const Text('Restore from a backup'),
            subtitle: const Text(
              'You’ll see what’s in it before anything '
              'changes',
            ),
            onTap: () => _restore(context, ref, today),
          ),
        ],
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
    final Backup? backup;
    try {
      backup = await actions.pick();
    } on BackupFormatException catch (error) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Can’t restore this file'),
            content: Text(error.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
          title: const Text('Replace everything?'),
          content: const Text(
            'Everything now in Clearing on this phone will be replaced by '
            'the backup. This can’t be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    await actions.restore(backup, mode);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Backup restored')));
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
    String n(int count, String one) => '$count $one${count == 1 ? '' : 's'}';

    return AlertDialog(
      title: Text(
        exported == null
            ? 'Restore this backup?'
            : 'Backup from ${dateLabel(LocalDate.fromDateTime(exported), today)}',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              '${n(backup.count('items'), 'item')}: $open open, '
                  '${byStatus['someday'] ?? 0} someday, '
                  '${byStatus['done'] ?? 0} done',
              n(backup.count('lists'), 'list'),
              n(backup.count('series'), 'repeating item'),
            ].join('\n'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Merge adds what’s missing and keeps the newer copy of anything '
            'on both. Replace makes this phone match the backup exactly.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImportMode.replace),
          child: const Text('Replace'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ImportMode.merge),
          child: const Text('Merge'),
        ),
      ],
    );
  }
}
