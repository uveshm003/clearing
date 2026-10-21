import 'dart:convert';

import '../domain/app_settings.dart';
import 'db/database.dart';

/// Persists [AppSettings] as one row per key.
class SettingsRepository {
  SettingsRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<AppSettings> watch() => _db
      .select(_db.settings)
      .watch()
      .map(
        (rows) => AppSettings.fromJson({
          for (final row in rows) row.key: jsonDecode(row.value),
        }),
      );

  Future<AppSettings> get() => watch().first;

  Future<void> save(AppSettings settings) {
    final now = _now();
    return _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.settings, [
        for (final MapEntry(:key, :value) in settings.toJson().entries)
          SettingsCompanion.insert(
            key: key,
            value: jsonEncode(value),
            updatedAt: now,
          ),
      ]);
    });
  }
}
