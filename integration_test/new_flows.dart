import 'dart:convert';

import 'package:clearing/app.dart';
import 'package:clearing/application/backup_schedule.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/data/backup.dart';
import 'package:clearing/data/backup_folder.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/passphrase_store.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers.dart';

/// A folder in memory, for automatic backups.
class _MemoryFolder implements BackupFolder {
  final files = <String, String>{};

  @override
  Future<String?> pick() async => 'memory://folder';

  @override
  Future<String?> describe(String folder) async => 'Folder';

  @override
  Future<void> write(String folder, String name, Uint8List bytes) async =>
      files[name] = utf8.decode(bytes);

  @override
  Future<List<FolderFile>> list(String folder) async => [
    for (final name in files.keys)
      (name: name, size: 0, modified: DateTime(2026, 10, 20)),
  ];

  @override
  Future<String?> read(String folder, String name) async => files[name];

  @override
  Future<void> delete(String folder, String name) async => files.remove(name);

  @override
  Future<bool> batteryOk() async => true;
}

/// The riskiest flows added after the beta (§8): smart capture straight to
/// Today, a bulk reschedule, an automatic backup restored, and a review that
/// ends with Look back. Shared by `test/` (runs in CI) and
/// `integration_test/` (runs on a device).
void newFlows() {
  final now = DateTime(2026, 10, 21, 9);

  Future<AppDatabase> start(
    WidgetTester tester, {
    _MemoryFolder? folder,
  }) async {
    final db = memoryDatabase(now: () => now);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate.fromDateTime(now)),
          ),
          if (folder != null) backupFolderProvider.overrideWithValue(folder),
        ],
        child: const ClearingApp(),
      ),
    );
    await settle(tester);
    return db;
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  Future<Map<String, (ItemStatus, String?)>> rows(
    WidgetTester tester,
    AppDatabase db,
  ) async => {
    for (final row in (await tester.runAsync(() => db.select(db.items).get()))!)
      row.title: (row.status, row.doDate?.toIso()),
  };

  testWidgets('typing a date and a flag plans it straight onto Today', (
    tester,
  ) async {
    final db = await start(tester);
    await tap(tester, find.byTooltip('Capture'));
    await tester.enterText(find.byType(TextField), 'Buy stamps today !');
    await settle(tester);
    expect(find.text('Must-do'), findsWidgets, reason: 'shown as a chip');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tap(tester, find.widgetWithText(TextButton, 'Done'));

    expect(find.text('Buy stamps'), findsOneWidget);
    final saved = await rows(tester, db);
    expect(saved['Buy stamps']!.$1, ItemStatus.active);
    await closeDatabase(tester, db);
  });

  testWidgets('select several and move them to this week at once', (
    tester,
  ) async {
    final db = await start(tester);
    await tap(tester, find.byTooltip('Capture'));
    await tester.enterText(find.byType(TextField), 'One\nTwo\nThree');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tap(tester, find.widgetWithText(TextButton, 'Done'));

    await tap(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Inbox'),
      ),
    );
    await tester.longPress(find.text('One'));
    await settle(tester);
    await tap(tester, find.text('Two'));
    expect(find.text('2 selected'), findsOneWidget);
    await tap(tester, find.byTooltip('This week'));

    final saved = await rows(tester, db);
    expect(saved['One']!.$1, ItemStatus.active);
    expect(saved['Two']!.$1, ItemStatus.active);
    expect(saved['Three']!.$1, ItemStatus.inbox);
    expect(find.text('2 planned'), findsOneWidget, reason: 'with Undo');
    await closeDatabase(tester, db);
  });

  test('an automatic backup can be restored', () async {
    final folder = _MemoryFolder();
    final db = memoryDatabase(now: () => now);
    final settings = SettingsRepository(db, now: () => now);
    final service = BackupService(db, now: () => now);
    await settings.save(
      (await settings.get()).copyWith(
        autoBackup: true,
        autoBackupFolder: () => 'memory://folder',
      ),
    );
    await ItemRepository(db, now: () => now).capture('Keep me');
    final schedule = BackupSchedule(
      service,
      folder,
      settings,
      MemoryPassphraseStore(),
      now: () => now,
    );
    expect(await schedule.runIfDue(), isTrue);

    // Lost after the backup, then brought back from the folder.
    await db.delete(db.items).go();
    final [found] = await schedule.found();
    final text = await schedule.read(found.name);
    await service.import(service.parse(text!), ImportMode.merge);
    final titles = [for (final r in await db.select(db.items).get()) r.title];
    expect(titles, ['Keep me']);
    await db.close();
  });

  testWidgets('a review ends with Look back', (tester) async {
    final db = await start(tester);
    await tap(tester, find.byTooltip('More'));
    await tap(tester, find.text('Weekly review'));
    await tap(tester, find.text('Quick (about 5 minutes)'));
    await tap(tester, find.widgetWithText(FilledButton, 'Next'));
    await tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.text('Look back'), findsOneWidget);
    expect(find.text('A quieter week.'), findsOneWidget);
    await tap(tester, find.text('Finish'));
    expect(find.text('Today'), findsWidgets);
    await closeDatabase(tester, db);
  });
}

/// Lets database streams and animations finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
  }
}
