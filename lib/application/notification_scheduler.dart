import 'dart:async';
import 'dart:math';

import '../data/reminder_repository.dart';
import '../data/settings_repository.dart';
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
}

/// Used where the platform has no notifications, and in tests.
class NoNotifications implements NotificationGateway {
  const NoNotifications();

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
  NotificationScheduler(
    this._gateway,
    this._reminders,
    this._settings, {
    required this._now,
  });

  final NotificationGateway _gateway;
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

  Future<void> _reconcile() async {
    final desired = {
      for (final n in planNotifications(
        await _reminders.enabledWithOpenItems(),
        settings: await _settings.get(),
        now: _now(),
      ))
        n.id: n,
    };
    final pending = await _gateway.pending();
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
  snoozeTomorrow('Tomorrow');

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

  Future<void> handle(NotificationAction action, String? payload) async {
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
