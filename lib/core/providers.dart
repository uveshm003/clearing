import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_actions.dart';
import '../application/notification_scheduler.dart';
import '../application/series_actions.dart';
import '../data/db/database.dart';
import '../data/item_repository.dart';
import '../data/list_repository.dart';
import '../data/reminder_repository.dart';
import '../data/series_repository.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/item_list.dart';
import '../domain/local_date.dart';
import '../domain/reminder.dart';
import '../domain/repeat_series.dart';
import '../domain/starter_suggestion.dart';
import '../domain/subtask.dart';
import '../domain/today_rules.dart';

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

final reminderRepositoryProvider = Provider(
  (ref) => ReminderRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final seriesRepositoryProvider = Provider(
  (ref) => SeriesRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final seriesActionsProvider = Provider(
  (ref) => SeriesActions(
    ref.watch(databaseProvider),
    ref.watch(seriesRepositoryProvider),
    ref.watch(itemRepositoryProvider),
    ref.watch(reminderRepositoryProvider),
    now: ref.watch(clockProvider),
  ),
);

final itemActionsProvider = Provider(
  (ref) => ItemActions(
    ref.watch(itemRepositoryProvider),
    now: ref.watch(clockProvider),
    series: ref.watch(seriesActionsProvider),
  ),
);

/// Overridden in `main()` with the device's notifications.
final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => const NoNotifications(),
);

final notificationSchedulerProvider = Provider(
  (ref) => NotificationScheduler(
    ref.watch(notificationGatewayProvider),
    ref.watch(reminderRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    now: ref.watch(clockProvider),
  ),
);

final notificationActionsProvider = Provider(
  (ref) => NotificationActions(
    ref.watch(itemActionsProvider),
    ref.watch(reminderRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Every item that is neither done nor trashed.
final openItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchOpen(),
);

final inboxItemsProvider = Provider<AsyncValue<List<Item>>>(
  (ref) => ref
      .watch(openItemsProvider)
      .whenData(
        (items) => items.where((i) => i.status == ItemStatus.inbox).toList(),
      ),
);

final todayViewProvider = Provider<AsyncValue<TodayView>>((ref) {
  final items = ref.watch(openItemsProvider);
  final today = ref.watch(todayProvider);
  return switch ((items, today)) {
    (AsyncData(value: final items), AsyncData(value: final today)) => AsyncData(
      buildTodayView(items, today),
    ),
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});

final itemProvider = StreamProvider.autoDispose.family<Item?, String>(
  (ref, id) => ref.watch(itemRepositoryProvider).watchItem(id),
);

final subtasksProvider = StreamProvider.autoDispose
    .family<List<Subtask>, String>(
      (ref, itemId) => ref.watch(itemRepositoryProvider).watchSubtasks(itemId),
    );

final subtaskProgressProvider = StreamProvider<Map<String, SubtaskProgress>>(
  (ref) => ref.watch(itemRepositoryProvider).watchSubtaskProgress(),
);

final remindersProvider = StreamProvider.autoDispose
    .family<List<Reminder>, String>(
      (ref, itemId) =>
          ref.watch(reminderRepositoryProvider).watchForItem(itemId),
    );

final seriesProvider = StreamProvider.autoDispose.family<RepeatSeries?, String>(
  (ref, id) => ref.watch(seriesRepositoryProvider).watch(id),
);

final listsProvider = StreamProvider<List<ItemList>>(
  (ref) => ref.watch(listRepositoryProvider).watchAll(),
);

final suggestionsProvider = StreamProvider<List<StarterSuggestion>>(
  (ref) => ref.watch(listRepositoryProvider).watchSuggestions(),
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
