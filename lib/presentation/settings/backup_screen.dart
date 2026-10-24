import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/backup_actions.dart';
import '../../core/providers.dart';
import '../../data/backup.dart';
import '../../data/backup_crypto.dart';
import '../../domain/app_settings.dart';
import '../../domain/local_date.dart';
import '../../l10n/l10n.dart';
import '../format.dart';
import '../guidance/field_notes_hooks.dart';
import '../widgets/choice_sheet.dart';
import '../widgets/pebble.dart';
import '../widgets/section_header.dart';

/// Backup and restore (FR-17). Nothing leaves the phone unless the user
/// exports it, and importing never overwrites without asking. Automatic
/// backups go to a folder the user picks (FR-17a), optionally locked with a
/// passphrase (FR-17b).
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

    String when(DateTime at) =>
        '${dateLabel(LocalDate.fromDateTime(at), today)}, '
        '${timeLabel(context, at.hour * 60 + at.minute)}';

    Future<void> export({required bool toFolder}) async {
      try {
        if (await actions.export(toFolder: toFolder)) {
          noteFieldNote(ref, FieldNote.safeKeeping);
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
            subtitle: Text(last == null ? l10n.backupNever : when(last)),
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
          // Automatic backups make the reminder unnecessary.
          if (!settings.autoBackup)
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
            onTap: () => restoreFromFile(context, ref),
          ),
          if (settings.autoBackupFolder != null)
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: Text(l10n.backupFoundTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickAutomatic(context, ref, today),
            ),
          SectionHeader(
            l10n.autoBackupSection,
            description: l10n.autoBackupHint,
          ),
          _AutoBackup(settings: settings, when: when),
          SectionHeader(l10n.moveSection),
          ListTile(
            leading: const Icon(Icons.phonelink_ring_outlined),
            title: Text(l10n.moveSend),
            subtitle: Text(l10n.moveSendHint),
            onTap: () => export(toFolder: false),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickAutomatic(
    BuildContext context,
    WidgetRef ref,
    LocalDate today,
  ) async {
    final schedule = ref.read(backupScheduleProvider);
    final found = await schedule.found();
    if (!context.mounted) return;
    final name = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            if (found.isEmpty)
              ListTile(title: Text(context.l10n.backupFoundNone))
            else
              for (final file in found)
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    dateLabel(LocalDate.fromDateTime(file.modified), today),
                  ),
                  subtitle: Text(file.name),
                  onTap: () => Navigator.pop(context, file.name),
                ),
          ],
        ),
      ),
    );
    if (name == null || !context.mounted) return;
    final text = await schedule.read(name);
    if (text == null || !context.mounted) return;
    await restoreFlow(context, ref, () async => text);
  }
}

/// The automatic backup controls.
class _AutoBackup extends ConsumerWidget {
  const _AutoBackup({required this.settings, required this.when});

  final AppSettings settings;
  final String Function(DateTime at) when;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repository = ref.read(settingsRepositoryProvider);
    final folders = ref.read(backupFolderProvider);
    final messenger = ScaffoldMessenger.of(context);
    final folder = settings.autoBackupFolder;
    final last = settings.lastAutoBackupAt;

    Future<String?> chooseFolder() async {
      final picked = await folders.pick();
      if (picked != null) {
        final latest = await repository.get();
        await repository.save(latest.copyWith(autoBackupFolder: () => picked));
      }
      return picked;
    }

    Future<void> backUpNow() async {
      try {
        if (await ref.read(backupScheduleProvider).backUpNow()) {
          noteFieldNote(ref, FieldNote.safeKeeping);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.autoBackupDone)));
        }
      } on Exception {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.autoBackupFailed)));
      }
    }

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.schedule),
          title: Text(l10n.autoBackupSwitch),
          subtitle: Text(
            !settings.autoBackup
                ? l10n.autoBackupHint
                : last == null
                ? l10n.autoBackupNotYet
                : l10n.autoBackupLast(when(last)),
          ),
          value: settings.autoBackup,
          onChanged: (on) async {
            if (on && folder == null && await chooseFolder() == null) return;
            final latest = await repository.get();
            await repository.save(latest.copyWith(autoBackup: on));
          },
        ),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(l10n.autoBackupFolder),
          subtitle: FutureBuilder(
            future: folder == null ? null : folders.describe(folder),
            builder: (context, snapshot) => Text(
              folder == null
                  ? l10n.autoBackupFolderNone
                  : snapshot.data ?? folder,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: TextButton(
            onPressed: chooseFolder,
            child: Text(l10n.autoBackupFolderChange),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.lock_outline),
          title: Text(l10n.autoBackupEncrypt),
          subtitle: Text(l10n.autoBackupEncryptHint),
          value: settings.autoBackupEncrypt,
          onChanged: (on) async {
            final store = ref.read(passphraseStoreProvider);
            if (on) {
              final passphrase = await _choosePassphrase(context);
              if (passphrase == null) return;
              await store.write(passphrase);
            } else {
              await store.clear();
            }
            final latest = await repository.get();
            await repository.save(latest.copyWith(autoBackupEncrypt: on));
          },
        ),
        if (settings.autoBackup && folder != null)
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.autoBackupNow),
            onTap: backUpNow,
          ),
      ],
    );
  }

  Future<String?> _choosePassphrase(BuildContext context) async {
    final first = TextEditingController();
    final second = TextEditingController();
    String? error;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.passphraseTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.passphraseWarning),
                const SizedBox(height: 12),
                TextField(
                  controller: first,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.passphraseField,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: second,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.passphraseAgain,
                    border: const OutlineInputBorder(),
                    errorText: error,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                if (first.text.length < 8) {
                  setState(() => error = context.l10n.passphraseShort);
                } else if (first.text != second.text) {
                  setState(() => error = context.l10n.passphraseMismatch);
                } else {
                  Navigator.pop(context, first.text);
                }
              },
              child: Text(context.l10n.commonSave),
            ),
          ],
        ),
      ),
    );
    first.dispose();
    second.dispose();
    return result;
  }
}

/// Picks a backup file and walks through restoring it. Also used by the
/// welcome, for someone moving from another phone.
Future<bool> restoreFromFile(BuildContext context, WidgetRef ref) async {
  final actions = ref.read(backupActionsProvider);
  try {
    final backup = await actions.pick();
    if (backup == null || !context.mounted) return false;
    return _confirmAndRestore(context, ref, backup);
  } on BackupNeedsPassphrase catch (locked) {
    if (!context.mounted) return false;
    return restoreFlow(context, ref, () async => locked.text);
  } on BackupFormatException catch (error) {
    if (context.mounted) await _cantRestore(context, error.message);
    return false;
  }
}

/// Restores the backup [load] returns, asking for a passphrase if it's
/// locked.
Future<bool> restoreFlow(
  BuildContext context,
  WidgetRef ref,
  Future<String> Function() load,
) async {
  final actions = ref.read(backupActionsProvider);
  final text = await load();
  try {
    String? passphrase;
    if (BackupCrypto.isEncrypted(text)) {
      if (!context.mounted) return false;
      passphrase = await _askPassphrase(context);
      if (passphrase == null) return false;
    }
    final backup = await actions.parse(text, passphrase: passphrase);
    if (!context.mounted) return false;
    return _confirmAndRestore(context, ref, backup);
  } on BackupPassphraseException {
    if (context.mounted) {
      await _cantRestore(context, context.l10n.passphraseWrong);
    }
  } on BackupFormatException catch (error) {
    if (context.mounted) await _cantRestore(context, error.message);
  }
  return false;
}

Future<String?> _askPassphrase(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.passphraseAsk),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.passphraseAskBody),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.l10n.passphraseField,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(context.l10n.passphraseUnlock),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<void> _cantRestore(BuildContext context, String message) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.backupCantRestore),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );

Future<bool> _confirmAndRestore(
  BuildContext context,
  WidgetRef ref,
  Backup backup,
) async {
  final actions = ref.read(backupActionsProvider);
  final messenger = ScaffoldMessenger.of(context);
  final restored = context.l10n.backupRestored;
  final today =
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now());
  final mode = await showDialog<ImportMode>(
    context: context,
    builder: (context) => _PreviewDialog(backup: backup, today: today),
  );
  if (mode == null || !context.mounted) return false;
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
    if (sure != true) return false;
  }
  await actions.restore(backup, mode);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(restored)));
  return true;
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
      content: SingleChildScrollView(
        child: Column(
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
            if (backup.fromNewerVersion) ...[
              const SizedBox(height: 12),
              Text(l10n.backupNewer),
            ],
            const SizedBox(height: 16),
            Text(l10n.backupMergeExplain),
          ],
        ),
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
