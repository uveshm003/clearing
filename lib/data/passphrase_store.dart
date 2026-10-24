import 'dart:io';

/// The passphrase for encrypted automatic backups. Kept in a file in the
/// app's private storage, never in the database, so it never goes into a
/// backup itself.
class PassphraseStore {
  PassphraseStore(this._file);

  final Future<File> Function() _file;

  Future<String?> read() async {
    final file = await _file();
    if (!file.existsSync()) return null;
    final text = await file.readAsString();
    return text.isEmpty ? null : text;
  }

  Future<void> write(String passphrase) async {
    final file = await _file();
    await file.writeAsString(passphrase, flush: true);
  }

  Future<void> clear() async {
    final file = await _file();
    if (file.existsSync()) await file.delete();
  }
}

/// In memory, for tests.
class MemoryPassphraseStore implements PassphraseStore {
  String? _value;

  @override
  Future<File> Function() get _file => throw UnimplementedError();

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String passphrase) async => _value = passphrase;

  @override
  Future<void> clear() async => _value = null;
}
