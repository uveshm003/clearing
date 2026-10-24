import 'dart:async';
import 'dart:math';

import '../data/block_repository.dart';
import '../data/item_repository.dart';
import '../data/list_repository.dart';
import '../data/reminder_repository.dart';
import '../data/settings_repository.dart';
import '../domain/batch_block.dart';
import '../domain/enums.dart';
import '../domain/local_date.dart';
import '../domain/notification_plan.dart';
import '../domain/reminder.dart';
import 'item_actions.dart';

/// The device's notification system, as the scheduler sees it.
abstract interface class NotificationGateway {
  /// Pending notification ids and their payloads.
  Future<Map<int, String?>> pending();

  Future<void> schedule(PlannedNotification notification);

  Future<void> cancel(int id);

  Future<bool> areEnabled();

  /// Asks for permission to post notifications. Call it in context, the
  /// first time a reminder is added (FR-09), never at first launch.
  Future<bool> requestPermission();

  /// Whether reminders can fire on the minute. Without it they may arrive a
  /// few minutes late (PRD §7).
  Future<bool> canScheduleExact();

  /// Opens the system screen that grants exact timing.
  Future<void> requestExact();

  /// Whether notifications show their titles on the lock screen (FR-09a).
  set lockScreenPrivate(bool value);
}

/// Used where the platform has no notifications, and in tests.
class NoNotifications implements NotificationGateway {
  const NoNotifications();

  @override
  set lockScreenPrivate(bool value) {}

  @override
  Future<Map<int, String?>> pending() async => const {};

  @override
  Future<void> schedule(PlannedNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<bool> areEnabled() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> canScheduleExact() async => false;

  @override
  Future<void> requestExact() async {}
}

/// Keeps the device's pending notifications equal to what the database says
/// they should be (PRD §8.3).
class NotificationScheduler {
  /// The lock-screen privacy last applied, to notice a change.
  bool? _private;

  NotificationScheduler(
    this._gateway,
    this._reminders,
    this._settings,
    this._items, {
    required this._now,
    this._blocks,
    this._lists,
    NotificationTexts Function()? texts,
  }) : _texts = texts ?? (() => NotificationTexts.english);

  final NotificationGateway _gateway;
  final ItemRepository _items;
  final BlockRepository? _blocks;
  final ListRepository? _lists;

  /// Read on every run, so a language change shows in the next schedule.
  final NotificationTexts Function() _texts;
  final ReminderRepository _reminders;
  final SettingsRepository _settings;
  final DateTime Function() _now;
  Future<void> _running = Future.value();

  /// reconcileNotifications(): computes the desired notifications for the
  /// next 14 days, then cancels and schedules only the difference. Safe to
  /// call any number of times; overlapping calls run one after another.
  Future<void> reconcile() {
    final run = _running.then((_) => _reconcile());
    // A failed run is reported to its caller but doesn't block later ones.
    _running = run.catchError((Object _) {});
    return run;
  }

  /// Blocks whose list has something to do; an empty list needs no nudge.
  Future<List<({BatchBlock block, String listName})>> _blockNudges() async {
    final blocks = await _blocks?.getAll() ?? const <BatchBlock>[];
    if (blocks.isEmpty) return const [];
    final lists = {
      for (final list in await _lists!.watchAll().first) list.id: list.name,
    };
    final busy = {
      for (final item in await _items.watchOpen().first)
        if (item.status == ItemStatus.active) ?item.listId,
    };
    return [
      for (final block in blocks)
        if (busy.contains(block.listId) && lists[block.listId] != null)
          (block: block, listName: lists[block.listId]!),
    ];
  }

  Future<void> _reconcile() async {
    final settings = await _settings.get();
    final now = _now();
    final desired = {
      for (final n in planNotifications(
        await _reminders.enabledWithOpenItems(),
        settings: settings,
        now: now,
        backupDueAt: nextBackupReminder(
          days: settings.exportReminderDays,
          lastExport: settings.lastExportAt,
          firstUse: await _items.firstCreatedAt(),
          now: now,
        ),
        blocks: await _blockNudges(),
        texts: _texts(),
        openItems: settings.morningDigest
            ? await _items.watchOpen().first
            : const [],
      ))
        n.id: n,
    };
    _gateway.lockScreenPrivate = settings.hideOnLockScreen;
    var pending = await _gateway.pending();
    // Changing lock-screen privacy reposts everything with the new setting.
    final private = _private;
    _private = settings.hideOnLockScreen;
    if (private != null && private != settings.hideOnLockScreen) {
      for (final id in pending.keys) {
        await _gateway.cancel(id);
      }
      pending = const {};
    }
    for (final MapEntry(key: id, value: payload) in pending.entries) {
      if (desired[id]?.payload != payload) await _gateway.cancel(id);
    }
    for (final notification in desired.values) {
      if (pending[notification.id] != notification.payload) {
        await _gateway.schedule(notification);
      }
    }
  }
}

/// The buttons on a reminder notification (FR-09). Android shows at most
/// three, so Snooze offers an hour and tomorrow morning.
enum NotificationAction {
  done('Done'),
  snoozeHour('Snooze 1 h'),
  snoozeTomorrow('Tomorrow'),

  /// Opens the item to choose another time; handled by the app itself.
  pickTime('Pick a time'),

  /// A reply typed on the morning summary, captured to the Inbox.
  reply('Capture');

  const NotificationAction(this.label);
  final String label;

  static NotificationAction? byName(String? name) =>
      values.where((a) => a.name == name).firstOrNull;
}

/// Carries out a tapped notification button.
class NotificationActions {
  NotificationActions(
    this._items,
    this._reminders,
    this._settings,
    this._scheduler, {
    required this._now,
  });

  final ItemActions _items;
  final ReminderRepository _reminders;
  final SettingsRepository _settings;
  final NotificationScheduler _scheduler;
  final DateTime Function() _now;

  Future<void> handle(
    NotificationAction action,
    String? payload, {
    String? input,
  }) async {
    if (action == NotificationAction.reply) {
      if (input != null && input.trim().isNotEmpty) {
        await _items.capture(input);
      }
      return;
    }
    final target = parsePayload(payload);
    if (target == null) return;
    switch (action) {
      case NotificationAction.done:
        final item = await _items.get(target.itemId);
        if (item != null) await _items.complete(item);
      case NotificationAction.snoozeHour:
        await _reminders.snooze(
          target.reminderId,
          _now().add(const Duration(hours: 1)),
        );
      case NotificationAction.snoozeTomorrow:
        await _reminders.snooze(target.reminderId, await _tomorrowMorning());
      case NotificationAction.pickTime || NotificationAction.reply:
        // The app opens on the item; nothing to do here.
        return;
    }
    await _scheduler.reconcile();
  }

  /// 9:00 tomorrow, or the end of quiet hours if that is later.
  Future<DateTime> _tomorrowMorning() async {
    final settings = await _settings.get();
    final tomorrow = LocalDate.fromDateTime(_now()).addDays(1);
    final quietEnd = settings.quietHoursStart == settings.quietHoursEnd
        ? 0
        : settings.quietHoursEnd;
    return tomorrow.atMinutes(max(defaultReminderTime, quietEnd));
  }
}
