import 'dart:convert';
import 'dart:typed_data';

import 'package:clearing/app.dart';
import 'package:clearing/application/backup_actions.dart';
import 'package:clearing/application/item_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/core/router.dart';
import 'package:clearing/data/backup.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers.dart';

class _FakeFiles implements BackupFiles {
  String? shared;
  String? toPick;

  @override
  Future<bool> share(String name, Uint8List bytes) async {
    shared = utf8.decode(bytes);
    return true;
  }

  @override
  Future<bool> save(String name, Uint8List bytes) async => false;

  @override
  Future<String?> pick() async => toPick;
}

/// Lets database work that runs outside fake time finish, then settles.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  late AppDatabase db;
  late _FakeFiles files;
  final now = DateTime(2026, 10, 20, 9);

  setUp(() {
    db = memoryDatabase(now: () => now);
    files = _FakeFiles();
  });

  Future<void> pumpBackup(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          todayProvider.overrideWith(
            (ref) => Stream.value(LocalDate.fromDateTime(now)),
          ),
          backupFilesProvider.overrideWithValue(files),
        ],
        child: const ClearingApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).push(Routes.backup);
    await tester.pumpAndSettle();
  }

  testWidgets('export records the date; restore previews then merges', (
    tester,
  ) async {
    final actions = ItemActions(
      ItemRepository(db, now: () => now),
      now: () => now,
    );
    await actions.capture('Pay rent\nCall Sam');
    await pumpBackup(tester);
    expect(find.text('Never'), findsOneWidget);

    await tester.tap(find.text('Share a backup'));
    await settle(tester);
    expect(files.shared, contains(backupFormat));
    expect(find.text('Today, 9:00 AM'), findsOneWidget);

    // A backup with one more item than this phone has.
    final backup = jsonDecode(files.shared!) as Map<String, Object?>;
    final tables = backup['tables']! as Map<String, Object?>;
    final rows = (tables['items']! as List).cast<Map<String, Object?>>();
    tables['items'] = [
      ...rows,
      {...rows.first, 'id': 'extra', 'title': 'From the old phone'},
    ];
    files.toPick = jsonEncode(backup);

    await scrollTo(
      tester,
      find.text('Restore from a backup'),
      within: find.text('Share a backup'),
    );
    await tester.tap(find.text('Restore from a backup'));
    await settle(tester);
    expect(find.text('Backup from Today'), findsOneWidget);
    expect(find.textContaining('3 items: 3 open'), findsOneWidget);
    await tester.tap(find.text('Merge'));
    await settle(tester);
    expect(find.text('Backup restored'), findsOneWidget);

    final titles = {
      for (final row in (await tester.runAsync(
        () => db.select(db.items).get(),
      ))!)
        row.title,
    };
    expect(titles, {'Pay rent', 'Call Sam', 'From the old phone'});

    await closeDatabase(tester, db);
  });

  testWidgets('a file that isn’t a backup is explained', (tester) async {
    files.toPick = 'not a backup';
    await pumpBackup(tester);
    await scrollTo(
      tester,
      find.text('Restore from a backup'),
      within: find.text('Share a backup'),
    );
    await tester.tap(find.text('Restore from a backup'));
    await tester.pumpAndSettle();
    expect(find.text('Can’t restore this file'), findsOneWidget);
    expect(find.text('This file isn’t a Clearing backup.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await closeDatabase(tester, db);
  });
}
