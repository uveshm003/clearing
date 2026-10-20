import 'package:clearing/data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fresh in-memory database for each test.
AppDatabase memoryDatabase({DateTime Function()? now}) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory(), now: now);
}

/// Tears down a widget test that used [db].
///
/// Drift schedules stream clean-up on timers inside the test's fake-async
/// zone, so they must be pumped or `close()` never completes.
Future<void> closeDatabase(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
  final closing = db.close();
  await tester.pump(Duration.zero);
  await closing;
}
