// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:clearing/data/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 to v2 keeps items and reminders, with no snooze', () async {
    const stamp = '2026-10-20T09:00:00.000';
    const oldItem = v1.ItemsData(
      id: 'i1',
      title: 'Pay rent',
      status: 'active',
      doDate: '2026-11-01',
      mustDo: 0,
      sortOrder: 0,
      createdAt: stamp,
      updatedAt: stamp,
      archived: 0,
    );
    const oldReminder = v1.RemindersData(
      id: 'r1',
      itemId: 'i1',
      offsetMinutes: 60,
      enabled: 1,
      updatedAt: stamp,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.items, oldItem);
        batch.insert(oldDb.reminders, oldReminder);
      },
      validateItems: (newDb) async {
        final items = await newDb.select(newDb.items).get();
        expect(items.single.toJson(), oldItem.toJson());
        expect(await newDb.select(newDb.reminders).get(), [
          const v2.RemindersData(
            id: 'r1',
            itemId: 'i1',
            offsetMinutes: 60,
            enabled: 1,
            updatedAt: stamp,
          ),
        ]);
      },
    );
  });
}
