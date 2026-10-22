import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../application/backup_actions.dart';

/// [BackupFiles] through share_plus and file_picker.
class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  static const _mimeType = 'application/json';

  @override
  Future<bool> share(String name, Uint8List bytes) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: _mimeType, name: name)],
        fileNameOverrides: [name],
        subject: 'Clearing backup',
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<bool> save(String name, Uint8List bytes) async =>
      await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: _mimeType,
        dialogTitle: 'Save backup',
      ) !=
      null;

  @override
  Future<String?> pick() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choose a Clearing backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    return utf8.decode(await files.single.readAsBytes(), allowMalformed: true);
  }
}
