import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../application/backup_actions.dart';
import '../application/backup_schedule.dart';
import '../data/backup_folder.dart';
import '../data/passphrase_store.dart';
import '../application/day_records.dart';
import '../application/project_actions.dart';
import '../l10n/notification_texts.dart';
import 'error_log.dart';
import '../application/item_actions.dart';
import '../application/lifecycle_actions.dart';
import '../application/notification_scheduler.dart';
import '../application/reset_actions.dart';
import '../application/series_actions.dart';
import '../application/template_actions.dart';
import '../application/widget_sync.dart';
import '../data/attachment_repository.dart';
import '../data/authenticator.dart';
import '../data/context_repository.dart';
import '../data/day_record_repository.dart';
import '../data/device.dart';
import '../data/event_repository.dart';
import '../data/journal_repository.dart';
import '../data/saved_search_repository.dart';
import '../data/speech.dart';
import '../domain/attachment.dart';
import '../domain/day_record.dart';
import '../domain/grove.dart';
import '../domain/item_context.dart';
import '../domain/item_event.dart';
import '../domain/journal_entry.dart';
import '../domain/saved_search.dart';
import '../data/backup.dart';
import '../data/backup_files.dart';
import '../data/block_repository.dart';
import '../data/db/database.dart';
import '../data/item_repository.dart';
import '../data/list_repository.dart';
import '../data/reminder_repository.dart';
import '../data/review_repository.dart';
import '../data/series_repository.dart';
import '../data/settings_repository.dart';
import '../data/template_repository.dart';
import '../domain/app_settings.dart';
import '../domain/batch_block.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/item_list.dart';
import '../domain/local_date.dart';
import '../domain/reminder.dart';
import '../domain/repeat_series.dart';
import '../domain/starter_suggestion.dart';
import '../domain/subtask.dart';
import '../domain/template.dart';
import '../domain/today_rules.dart';
import '../domain/upcoming_rules.dart';

/// Overridden in `main()` with the opened database, and in tests with an
/// in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Overridden in `main()` with the log file on the phone.
final errorLogProvider = Provider<ErrorLog>((ref) => ErrorLog());

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

final reviewRepositoryProvider = Provider(
  (ref) => ReviewRepository(
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
    weekStart: () async =>
        (await ref.read(settingsRepositoryProvider).get()).weekStart,
  ),
);

final eventRepositoryProvider = Provider(
  (ref) => EventRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final itemActionsProvider = Provider(
  (ref) => ItemActions(
    ref.watch(itemRepositoryProvider),
    now: ref.watch(clockProvider),
    series: ref.watch(seriesActionsProvider),
    events: ref.watch(eventRepositoryProvider),
  ),
);

final projectActionsProvider = Provider(
  (ref) => ProjectActions(
    ref.watch(listRepositoryProvider),
    ref.watch(itemRepositoryProvider),
    ref.watch(itemActionsProvider),
  ),
);

final contextRepositoryProvider = Provider(
  (ref) => ContextRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final contextsProvider = StreamProvider<List<ItemContext>>(
  (ref) => ref.watch(contextRepositoryProvider).watchAll(),
);

/// Context ids per item id.
final itemContextsProvider = StreamProvider<Map<String, Set<String>>>(
  (ref) => ref.watch(contextRepositoryProvider).watchByItem(),
);

final dayRecordRepositoryProvider = Provider(
  (ref) => DayRecordRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final dayRecordActionsProvider = Provider(
  (ref) => DayRecordActions(
    ref.watch(itemRepositoryProvider),
    ref.watch(dayRecordRepositoryProvider),
    now: ref.watch(clockProvider),
  ),
);

final dayRecordsProvider = StreamProvider<List<DayRecord>>(
  (ref) => ref.watch(dayRecordRepositoryProvider).watchAll(),
);

final itemEventsProvider = StreamProvider.autoDispose
    .family<List<ItemEvent>, String>(
      (ref, itemId) => ref.watch(eventRepositoryProvider).watchForItem(itemId),
    );

final savedSearchRepositoryProvider = Provider(
  (ref) => SavedSearchRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final savedSearchesProvider = StreamProvider<List<SavedSearch>>(
  (ref) => ref.watch(savedSearchRepositoryProvider).watchAll(),
);

final journalRepositoryProvider = Provider(
  (ref) => JournalRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final journalProvider = StreamProvider<List<JournalEntry>>(
  (ref) => ref.watch(journalRepositoryProvider).watchAll(),
);

/// Where attachments are stored; tests override it with a temporary folder.
final attachmentsFolderProvider = Provider<Future<Directory> Function()>(
  (ref) =>
      () async => Directory(
        '${(await getApplicationSupportDirectory()).path}/attachments',
      ),
);

final attachmentRepositoryProvider = Provider(
  (ref) => AttachmentRepository(
    ref.watch(databaseProvider),
    folder: ref.watch(attachmentsFolderProvider),
    now: ref.watch(clockProvider),
  ),
);

final attachmentsProvider = StreamProvider.autoDispose
    .family<List<Attachment>, String>(
      (ref, itemId) =>
          ref.watch(attachmentRepositoryProvider).watchForItem(itemId),
    );

final resetActionsProvider = Provider(
  (ref) => ResetActions(
    ref.watch(itemActionsProvider),
    ref.watch(itemRepositoryProvider),
    now: ref.watch(clockProvider),
  ),
);

final blockRepositoryProvider = Provider(
  (ref) => BlockRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final blocksProvider = StreamProvider<List<BatchBlock>>(
  (ref) => ref.watch(blockRepositoryProvider).watchAll(),
);

final templateRepositoryProvider = Provider(
  (ref) => TemplateRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final templateActionsProvider = Provider(
  (ref) => TemplateActions(
    ref.watch(databaseProvider),
    ref.watch(templateRepositoryProvider),
    ref.watch(itemRepositoryProvider),
    ref.watch(itemActionsProvider),
    ref.watch(seriesRepositoryProvider),
    ref.watch(seriesActionsProvider),
  ),
);

final templatesProvider = StreamProvider<List<Template>>(
  (ref) => ref.watch(templateRepositoryProvider).watchAll(),
);

final templateProvider = StreamProvider.autoDispose.family<Template?, String>(
  (ref, id) => ref.watch(templateRepositoryProvider).watch(id),
);

final lifecycleActionsProvider = Provider(
  (ref) => LifecycleActions(
    ref.watch(itemRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    now: ref.watch(clockProvider),
    blocks: ref.watch(blockRepositoryProvider),
  ),
);

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const PlatformBackupFiles(),
);

final backupActionsProvider = Provider(
  (ref) => BackupActions(
    BackupService(
      ref.watch(databaseProvider),
      now: ref.watch(clockProvider),
      attachments: ref.watch(attachmentRepositoryProvider),
    ),
    ref.watch(backupFilesProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(seriesActionsProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Overridden in `main()` with the system folder picker.
final backupFolderProvider = Provider<BackupFolder>(
  (ref) => const NoBackupFolder(),
);

final passphraseStoreProvider = Provider<PassphraseStore>(
  (ref) => PassphraseStore(
    () async =>
        File('${(await getApplicationSupportDirectory()).path}/backup.key'),
  ),
);

final backupScheduleProvider = Provider(
  (ref) => BackupSchedule(
    BackupService(
      ref.watch(databaseProvider),
      now: ref.watch(clockProvider),
      attachments: ref.watch(attachmentRepositoryProvider),
    ),
    ref.watch(backupFolderProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(passphraseStoreProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Overridden in `main()` with the device's home-screen widgets.
final homeWidgetGatewayProvider = Provider<HomeWidgetGateway>(
  (ref) => const NoHomeWidgets(),
);

final widgetSyncProvider = Provider(
  (ref) => WidgetSync(
    ref.watch(itemRepositoryProvider),
    ref.watch(homeWidgetGatewayProvider),
    now: ref.watch(clockProvider),
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
    ref.watch(itemRepositoryProvider),
    now: ref.watch(clockProvider),
    blocks: ref.watch(blockRepositoryProvider),
    lists: ref.watch(listRepositoryProvider),
    texts: notificationTexts,
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

final inboxItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.inbox),
);

/// Only what Today shows, filtered by the database.
final todayItemsProvider = StreamProvider<List<Item>>((ref) {
  final today = ref.watch(todayProvider).value;
  if (today == null) return const Stream.empty();
  return ref.watch(itemRepositoryProvider).watchToday(today);
});

/// Only what Upcoming shows, filtered by the database.
final upcomingItemsProvider = StreamProvider<List<Item>>((ref) {
  final today = ref.watch(todayProvider).value;
  if (today == null) return const Stream.empty();
  return ref
      .watch(itemRepositoryProvider)
      .watchUpcoming(today, today.addDays(upcomingDays));
});

/// Open items per list id.
final listCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(itemRepositoryProvider).watchListCounts(),
);

final somedayCountProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchCount(ItemStatus.someday),
);

/// Planned items per list id, for batch blocks.
final activeListCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(itemRepositoryProvider).watchListCounts(activeOnly: true),
);

final todayViewProvider = Provider<AsyncValue<TodayView>>((ref) {
  final items = ref.watch(todayItemsProvider);
  final today = ref.watch(todayProvider);
  final projectIds = {
    for (final list in ref.watch(listsProvider).value ?? const <ItemList>[])
      if (list.isProject) list.id,
  };
  return switch ((items, today)) {
    (AsyncData(value: final items), AsyncData(value: final today)) => AsyncData(
      buildTodayView(nextProjectSteps(items, projectIds), today),
    ),
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});

/// Items finished today: how far the Today header's sky has cleared.
final doneTodayProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayProvider).value;
  if (today == null) return Stream.value(0);
  return ref
      .watch(itemRepositoryProvider)
      .watchCompletedSince(DateTime(today.year, today.month, today.day));
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

/// Overridden in `main()` with the phone's on-device speech recogniser.
final speechGatewayProvider = Provider<SpeechGateway>(
  (ref) => const NoSpeech(),
);

final speechAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(speechGatewayProvider).isAvailable(),
);

/// Done items, archived ones included, most recent first.
final doneItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchDone(),
);

/// When each weekly review was finished.
final completedReviewsProvider = StreamProvider<List<DateTime>>(
  (ref) =>
      ref.watch(reviewRepositoryProvider).watchCompleted(ReviewKind.weekly),
);

final completedResetsProvider = StreamProvider<List<DateTime>>(
  (ref) => ref.watch(reviewRepositoryProvider).watchCompleted(ReviewKind.reset),
);

final resolvedEventsProvider = StreamProvider<List<ItemEvent>>(
  (ref) => ref.watch(eventRepositoryProvider).watchKind(ItemEventKind.resolved),
);

/// What the Grove grows from (§6.2), all of it data the app already keeps.
final groveInputsProvider = Provider<GroveInputs?>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final done = ref.watch(doneItemsProvider).value;
  if (settings == null || done == null) return null;
  return GroveInputs(
    closed: [
      for (final item in done)
        if (item.completedAt case final completedAt?)
          ClosedThing(
            id: item.id,
            title: item.title,
            createdAt: item.createdAt,
            completedAt: completedAt,
          ),
    ],
    reviews: ref.watch(completedReviewsProvider).value ?? const [],
    resets: ref.watch(completedResetsProvider).value ?? const [],
    allClearDays: [
      for (final record in ref.watch(dayRecordsProvider).value ?? const [])
        if (record.allClear) record.date,
    ],
    resolved: [
      for (final event in ref.watch(resolvedEventsProvider).value ?? const [])
        event.at,
    ],
    backedUp:
        settings.lastExportAt != null || settings.lastAutoBackupAt != null,
    invitations: [
      for (final key in settings.invitationsDone)
        if (!key.endsWith(':skip')) ?LocalDate.tryParse(key.split(':').first),
    ],
    hemisphere: settings.hemisphere,
  );
});

/// This season's Grove.
final groveProvider = Provider<GroveState?>((ref) {
  final inputs = ref.watch(groveInputsProvider);
  final today = ref.watch(todayProvider).value;
  if (inputs == null || today == null) return null;
  return buildGrove(inputs, seasonOf(today, inputs.hemisphere));
});

/// The Glade variants earned so far.
final earnedVariantsProvider = Provider<Set<GladeVariant>>(
  (ref) => ref.watch(groveProvider)?.totals.earned ?? const {},
);

/// Overridden in `main()` with the phone.
final deviceGatewayProvider = Provider<DeviceGateway>(
  (ref) => const NoDevice(),
);

/// Overridden in `main()` with the phone's own lock.
final authenticatorProvider = Provider<Authenticator>(
  (ref) => const NoAuthenticator(),
);

/// A flexible routine's progress this week: done so far, and the target.
final flexibleProgressProvider = Provider.autoDispose
    .family<({int done, int target})?, String>((ref, seriesId) {
      final series = ref.watch(seriesProvider(seriesId)).value;
      final target = series?.weeklyTarget;
      final today = ref.watch(todayProvider).value;
      if (target == null || today == null) return null;
      final weekStart = ref.watch(settingsProvider).value?.weekStart ?? 1;
      final start = today.startOfWeek(weekStart);
      final done = (ref.watch(doneItemsProvider).value ?? const <Item>[])
          .where(
            (i) =>
                i.seriesId == seriesId &&
                i.completedAt != null &&
                !LocalDate.fromDateTime(i.completedAt!).isBefore(start),
          )
          .length;
      return (done: done, target: target);
    });
