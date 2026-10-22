import 'dart:convert';

import 'package:clearing/app.dart';
import 'package:clearing/application/backup_actions.dart';
import 'package:clearing/core/providers.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers.dart';

/// Keeps the exported file in memory and hands it back on "pick".
class _MemoryFiles implements BackupFiles {
  String? file;

  @override
  Future<bool> share(String name, Uint8List bytes) async {
    file = utf8.decode(bytes);
    return true;
  }

  @override
  Future<bool> save(String name, Uint8List bytes) => share(name, bytes);

  @override
  Future<String?> pick() async => file;
}

/// The end-to-end path from PRD §9: capture → clarify → complete → export →
/// import. Shared by `test/` (runs in CI) and `integration_test/` (runs on
/// a device).
void captureToRestore() {
  testWidgets('capture → clarify → complete → export → import', (tester) async {
    final now = DateTime(2026, 10, 20, 9);
    final db = memoryDatabase(now: () => now);
    final files = _MemoryFiles();

    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }
    }

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await settle();
    }

    Future<void> tab(String label) => tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );

    Future<void> capture(String thought) async {
      await tap(find.byTooltip('Capture'));
      await tester.enterText(find.byType(TextField), thought);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle();
      await tap(find.widgetWithText(TextButton, 'Done'));
    }

    Future<Map<String, ItemStatus>> statuses() async => {
      for (final row in (await tester.runAsync(
        () => db.select(db.items).get(),
      ))!)
        row.title: row.status,
    };

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
    await settle();

    // Capture.
    await capture('Passport');

    // Clarify into Today.
    await tab('Inbox');
    await tap(find.text('Passport'));
    await tap(find.text('Yes, there’s something to do'));
    await tester.enterText(find.byType(TextField), 'Book passport photo');
    await tap(find.text('Next'));
    await tap(find.text('No, I’ll do it'));
    await tap(find.text('Today'));
    await scrollTo(
      tester,
      find.widgetWithText(FilledButton, 'Done'),
      within: find.text('Anything else?'),
    );
    await tap(find.widgetWithText(FilledButton, 'Done'));

    // Complete.
    await tab('Today');
    expect(find.text('Book passport photo'), findsOneWidget);
    await tap(find.byType(Checkbox));
    expect(find.text('A clear day'), findsOneWidget);

    // Export.
    await tab('Lists');
    await tap(find.byTooltip('Settings'));
    await scrollTo(
      tester,
      find.text('Backup'),
      within: find.text('Must-do items per day'),
    );
    await tap(find.text('Backup'));
    await tap(find.text('Share a backup'));
    expect(files.file, isNotNull);

    // Something changes after the backup, then the backup is restored.
    await tester.pageBack();
    await settle();
    await tester.pageBack();
    await settle();
    await capture('Added after the backup');
    expect((await statuses()).keys, contains('Added after the backup'));

    await tab('Lists');
    await tap(find.byTooltip('Settings'));
    await scrollTo(
      tester,
      find.text('Backup'),
      within: find.text('Must-do items per day'),
    );
    await tap(find.text('Backup'));
    await tap(find.text('Restore from a backup'));
    expect(find.textContaining('1 item: 0 open'), findsOneWidget);
    await tap(find.widgetWithText(TextButton, 'Replace'));
    await tap(find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored'), findsOneWidget);

    expect(await statuses(), {'Book passport photo': ItemStatus.done});

    await closeDatabase(tester, db);
  });
}
