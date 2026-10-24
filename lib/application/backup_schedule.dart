import 'dart:convert';
import 'dart:typed_data';

import '../data/backup.dart';
import '../data/backup_crypto.dart';
import '../data/backup_folder.dart';
import '../data/passphrase_store.dart';
import '../data/settings_repository.dart';
import '../domain/local_date.dart';

/// `clearing-auto-YYYYMMDD.json`.
String autoBackupName(DateTime at) =>
    backupFileName(at).replaceFirst('clearing-backup-', 'clearing-auto-');

/// The date in an automatic backup's name, or null for other files.
LocalDate? autoBackupDate(String name) {
  final match = RegExp(
    r'^clearing-auto-(\d{4})(\d{2})(\d{2})\.json$',
  ).firstMatch(name);
  if (match == null) return null;
  return LocalDate(
    int.parse(match[1]!),
    int.parse(match[2]!),
    int.parse(match[3]!),
  );
}

/// Which automatic backups to keep: the last [daily] days' and, beyond
/// those, the newest from each of the last [weekly] weeks.
Set<String> backupsToKeep(
  Iterable<String> names, {
  int daily = 7,
  int weekly = 4,
}) {
  final dated = [
    for (final name in names)
      if (autoBackupDate(name) case final date?) (name: name, date: date),
  ]..sort((a, b) => b.date.compareTo(a.date));
  final keep = <String>{for (final f in dated.take(daily)) f.name};
  final weeks = <LocalDate>{};
  for (final f in dated.skip(daily)) {
    final week = f.date.startOfWeek(DateTime.monday);
    if (weeks.length >= weekly) break;
    if (weeks.add(week)) keep.add(f.name);
  }
  return keep;
}

/// Daily automatic backups (FR-17a), run from the background job at night
/// and when the app opens, whichever comes first each day.
class BackupSchedule {
  BackupSchedule(
    this._service,
    this._folder,
    this._settings,
    this._passphrase, {
    required this._now,
  });

  final BackupService _service;
  final BackupFolder _folder;
  final SettingsRepository _settings;
  final PassphraseStore _passphrase;
  final DateTime Function() _now;

  /// Backs up unless today's is done, it's off, or the battery is low.
  /// Returns whether a backup was written.
  Future<bool> runIfDue() async {
    final settings = await _settings.get();
    final folder = settings.autoBackupFolder;
    if (!settings.autoBackup || folder == null) return false;
    final last = settings.lastAutoBackupAt;
    final now = _now();
    if (last != null &&
        LocalDate.fromDateTime(last) == LocalDate.fromDateTime(now)) {
      return false;
    }
    if (!await _folder.batteryOk()) return false;
    return backUpNow();
  }

  /// Writes today's backup and prunes old ones.
  Future<bool> backUpNow() async {
    final settings = await _settings.get();
    final folder = settings.autoBackupFolder;
    if (folder == null) return false;
    final now = _now();
    var text = await _service.export();
    if (settings.autoBackupEncrypt) {
      final passphrase = await _passphrase.read();
      // Encryption on but no passphrase: don't write a readable copy.
      if (passphrase == null) return false;
      text = await BackupCrypto.encrypt(text, passphrase);
    }
    await _folder.write(
      folder,
      autoBackupName(now),
      Uint8List.fromList(utf8.encode(text)),
    );
    final files = await _folder.list(folder);
    final keep = backupsToKeep(files.map((f) => f.name));
    for (final file in files) {
      if (autoBackupDate(file.name) != null && !keep.contains(file.name)) {
        await _folder.delete(folder, file.name);
      }
    }
    final latest = await _settings.get();
    await _settings.save(latest.copyWith(lastAutoBackupAt: () => now));
    return true;
  }

  /// Automatic backups found in the folder, newest first.
  Future<List<FolderFile>> found() async {
    final folder = (await _settings.get()).autoBackupFolder;
    if (folder == null) return const [];
    final files = [
      for (final f in await _folder.list(folder))
        if (f.name.endsWith('.json')) f,
    ];
    return files..sort((a, b) => b.name.compareTo(a.name));
  }

  Future<String?> read(String name) async {
    final folder = (await _settings.get()).autoBackupFolder;
    return folder == null ? null : _folder.read(folder, name);
  }
}
