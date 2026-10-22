import 'dart:convert';
import 'dart:typed_data';

import '../data/backup.dart';
import '../data/settings_repository.dart';
import 'series_actions.dart';

/// Where backup files go to and come from: the share sheet, the system file
/// picker. Replaced in tests.
abstract interface class BackupFiles {
  /// Offers the file through the share sheet. True if the user picked a
  /// target.
  Future<bool> share(String name, Uint8List bytes);

  /// Saves the file where the user chooses. True if it was saved.
  Future<bool> save(String name, Uint8List bytes);

  /// Lets the user choose a backup file; null if they cancel.
  Future<String?> pick();
}

/// Export and import (FR-17).
class BackupActions {
  BackupActions(
    this._service,
    this._files,
    this._settings,
    this._series, {
    required this._now,
  });

  final BackupService _service;
  final BackupFiles _files;
  final SettingsRepository _settings;
  final SeriesActions _series;
  final DateTime Function() _now;

  /// Exports through the share sheet, or to a chosen folder when
  /// [toFolder]. Records the time, so the export reminder starts over.
  Future<bool> export({bool toFolder = false}) async {
    final now = _now();
    final bytes = Uint8List.fromList(utf8.encode(await _service.export()));
    final name = backupFileName(now);
    final done = toFolder
        ? await _files.save(name, bytes)
        : await _files.share(name, bytes);
    if (done) {
      final settings = await _settings.get();
      await _settings.save(settings.copyWith(lastExportAt: () => now));
    }
    return done;
  }

  /// Picks and checks a file. Throws [BackupFormatException] if it can't be
  /// imported; null if the user cancelled.
  Future<Backup?> pick() async {
    final text = await _files.pick();
    return text == null ? null : _service.parse(text);
  }

  /// Imports [backup]. Series then advance, in case the backup is old and
  /// its occurrences have passed.
  Future<void> restore(Backup backup, ImportMode mode) async {
    await _service.import(backup, mode);
    await _series.advanceAll();
  }
}
