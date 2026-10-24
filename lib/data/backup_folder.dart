import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A backup file in the chosen folder.
typedef FolderFile = ({String name, int size, DateTime modified});

/// The folder automatic backups go to (FR-17a), chosen once through the
/// system picker. It can be anywhere the phone can write: its own storage,
/// an SD card, or a folder another app syncs. Clearing itself never sends
/// anything anywhere.
abstract interface class BackupFolder {
  /// Asks the user for a folder; returns its address, or null if cancelled.
  Future<String?> pick();

  /// A short, readable name for [folder], e.g. "Documents/Clearing".
  Future<String?> describe(String folder);

  Future<void> write(String folder, String name, Uint8List bytes);

  Future<List<FolderFile>> list(String folder);

  Future<String?> read(String folder, String name);

  Future<void> delete(String folder, String name);

  /// Whether now is a kind time to back up: charging, or battery above 30%.
  Future<bool> batteryOk();
}

/// Where there's no system folder picker, and in tests.
class NoBackupFolder implements BackupFolder {
  const NoBackupFolder();

  @override
  Future<String?> pick() async => null;

  @override
  Future<String?> describe(String folder) async => null;

  @override
  Future<void> write(String folder, String name, Uint8List bytes) async {}

  @override
  Future<List<FolderFile>> list(String folder) async => const [];

  @override
  Future<String?> read(String folder, String name) async => null;

  @override
  Future<void> delete(String folder, String name) async {}

  @override
  Future<bool> batteryOk() async => true;
}

/// The Storage Access Framework, through `FolderChannel.kt`.
class DeviceBackupFolder implements BackupFolder {
  const DeviceBackupFolder();

  static const _channel = MethodChannel('clearing/folder');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<String?> pick() async =>
      _supported ? _channel.invokeMethod<String>('pick') : null;

  @override
  Future<String?> describe(String folder) async => _supported
      ? _channel.invokeMethod<String>('describe', {'folder': folder})
      : null;

  @override
  Future<void> write(String folder, String name, Uint8List bytes) =>
      _channel.invokeMethod<void>('write', {
        'folder': folder,
        'name': name,
        'bytes': bytes,
      });

  @override
  Future<List<FolderFile>> list(String folder) async {
    final rows =
        await _channel.invokeListMethod<Map<Object?, Object?>>('list', {
          'folder': folder,
        }) ??
        const [];
    return [
      for (final row in rows)
        (
          name: '${row['name']}',
          size: (row['size'] as int?) ?? 0,
          modified: DateTime.fromMillisecondsSinceEpoch(
            (row['modified'] as int?) ?? 0,
          ),
        ),
    ];
  }

  @override
  Future<String?> read(String folder, String name) =>
      _channel.invokeMethod<String>('read', {'folder': folder, 'name': name});

  @override
  Future<void> delete(String folder, String name) =>
      _channel.invokeMethod<void>('delete', {'folder': folder, 'name': name});

  @override
  Future<bool> batteryOk() async {
    if (!_supported) return true;
    try {
      return await _channel.invokeMethod<bool>('batteryOk') ?? true;
    } on MissingPluginException {
      return true;
    }
  }
}
