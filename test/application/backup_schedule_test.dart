import 'dart:convert';
import 'dart:typed_data';

import 'package:clearing/application/backup_schedule.dart';
import 'package:clearing/data/backup.dart';
import 'package:clearing/data/backup_crypto.dart';
import 'package:clearing/data/backup_folder.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/passphrase_store.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

class FakeFolder implements BackupFolder {
  final files = <String, String>{};
  bool battery = true;

  @override
  Future<String?> pick() async => 'content://folder';

  @override
  Future<String?> describe(String folder) async => 'Folder';

  @override
  Future<void> write(String folder, String name, Uint8List bytes) async =>
      files[name] = utf8.decode(bytes);

  @override
  Future<List<FolderFile>> list(String folder) async => [
    for (final name in files.keys)
      (name: name, size: files[name]!.length, modified: DateTime(2026)),
  ];

  @override
  Future<String?> read(String folder, String name) async => files[name];

  @override
  Future<void> delete(String folder, String name) async => files.remove(name);

  @override
  Future<bool> batteryOk() async => battery;
}

void main() {
  test('keeps a week of dailies and four weeklies', () {
    final names = [
      for (var day = 1; day <= 40; day++)
        autoBackupName(DateTime(2026, 10, 1).add(Duration(days: day))),
      'notes.txt',
    ];
    final keep = backupsToKeep(names);
    expect(keep, hasLength(11));
    expect(keep, contains(autoBackupName(DateTime(2026, 11, 10))));
    expect(keep, isNot(contains('notes.txt')));
    expect(keep, isNot(contains(autoBackupName(DateTime(2026, 10, 2)))));
  });

  group('BackupSchedule', () {
    late AppDatabase db;
    late FakeFolder folder;
    late SettingsRepository settings;
    late MemoryPassphraseStore passphrase;
    var now = DateTime(2026, 10, 21, 0, 5);

    BackupSchedule schedule() => BackupSchedule(
      BackupService(db, now: () => now),
      folder,
      settings,
      passphrase,
      now: () => now,
    );

    setUp(() async {
      db = memoryDatabase(now: () => now);
      folder = FakeFolder();
      settings = SettingsRepository(db, now: () => now);
      passphrase = MemoryPassphraseStore();
      await ItemRepository(db, now: () => now).capture('Pay rent');
    });

    tearDown(() => db.close());

    test('does nothing while off', () async {
      expect(await schedule().runIfDue(), isFalse);
      expect(folder.files, isEmpty);
    });

    test('backs up once a day, and not on a low battery', () async {
      await settings.save(
        (await settings.get()).copyWith(
          autoBackup: true,
          autoBackupFolder: () => 'content://folder',
        ),
      );
      folder.battery = false;
      expect(await schedule().runIfDue(), isFalse);
      folder.battery = true;
      expect(await schedule().runIfDue(), isTrue);
      expect(await schedule().runIfDue(), isFalse);
      expect(folder.files.keys, [autoBackupName(now)]);
      expect(folder.files.values.single, contains(backupFormat));
      expect((await settings.get()).lastAutoBackupAt, now);

      now = now.add(const Duration(days: 1));
      expect(await schedule().runIfDue(), isTrue);
      expect(folder.files, hasLength(2));
    });

    test('encrypted backups need the passphrase to open', () async {
      await settings.save(
        (await settings.get()).copyWith(
          autoBackup: true,
          autoBackupFolder: () => 'content://folder',
          autoBackupEncrypt: true,
        ),
      );
      // No passphrase yet: no readable copy is written instead.
      expect(await schedule().backUpNow(), isFalse);
      await passphrase.write('correct horse');
      expect(await schedule().backUpNow(), isTrue);
      final text = folder.files.values.single;
      expect(BackupCrypto.isEncrypted(text), isTrue);
      expect(text, isNot(contains('Pay rent')));
      await expectLater(
        BackupCrypto.decrypt(text, 'wrong'),
        throwsA(isA<BackupPassphraseException>()),
      );
      final plain = await BackupCrypto.decrypt(text, 'correct horse');
      expect(plain, contains('Pay rent'));
    });
  });
}
