import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/item_repository.dart';
import '../data/list_repository.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/local_date.dart';

/// Overridden in `main()` with the opened database, and in tests with an
/// in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// The wall clock; tests override it to control "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final itemRepositoryProvider = Provider(
  (ref) => ItemRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final listRepositoryProvider = Provider(
  (ref) => ListRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Today's local date, re-emitted just after each local midnight so derived
/// views roll over while the app stays open.
final todayProvider = StreamProvider<LocalDate>((ref) async* {
  final now = ref.watch(clockProvider);
  while (true) {
    final current = now();
    yield LocalDate.fromDateTime(current);
    final midnight = DateTime(current.year, current.month, current.day + 1);
    await Future<void>.delayed(midnight.difference(current));
  }
});
