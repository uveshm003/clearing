import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/notification_scheduler.dart';
import 'package:clearing/application/series_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/data/reminder_repository.dart';
import 'package:clearing/data/series_repository.dart';
import 'package:clearing/data/settings_repository.dart';
import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/notification_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Records what the scheduler asks the device to do.
class FakeGateway extends NoNotifications {
  final scheduled = <int, PlannedNotification>{};
  var scheduleCalls = 0;
  var cancelCalls = 0;

  @override
  Future<Map<int, String?>> pending() async => {
    for (final MapEntry(:key, :value) in scheduled.entries) key: value.payload,
  };

  @override
  Future<void> schedule(PlannedNotification notification) async {
    scheduleCalls++;
    scheduled[notification.id] = notification;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    scheduled.remove(id);
  }
}

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late ReminderRepository reminders;
  late SettingsRepository settings;
  late ItemActions actions;
  late FakeGateway gateway;
  late NotificationScheduler scheduler;
  late NotificationActions buttons;
  final now = DateTime(2026, 10, 20, 9);
  final today = LocalDate(2026, 10, 20);

  setUp(() async {
    DateTime clock() => now;
    db = memoryDatabase(now: clock);
    items = ItemRepository(db, now: clock);
    reminders = ReminderRepository(db, now: clock);
    settings = SettingsRepository(db, now: clock);
    final series = SeriesActions(
      db,
      SeriesRepository(db, now: clock),
      items,
      reminders,
      now: clock,
    );
    actions = ItemActions(items, now: clock, series: series);
    gateway = FakeGateway();
    scheduler = NotificationScheduler(
      gateway,
      reminders,
      settings,
      items,
      now: clock,
    );
    buttons = NotificationActions(
      actions,
      reminders,
      settings,
      scheduler,
      now: clock,
    );
    await settings.save(
      const AppSettings(
        notificationIntensity: NotificationIntensity.standard,
        reviewReminder: false,
      ),
    );
  });
  tearDown(() => db.close());

  Future<Item> dentistAtNoon() async {
    final [captured] = await actions.capture('Call dentist');
    return actions.planOnDate(captured, today, time: 12 * 60);
  }

  List<DateTime> scheduledTimes() =>
      [for (final n in gateway.scheduled.values) n.fireAt]..sort();

  test('schedules what the database says, then nothing more', () async {
    final item = await dentistAtNoon();
    await reminders.add(item.id, offsetMinutes: 0);
    await reminders.add(item.id, offsetMinutes: 60);

    await scheduler.reconcile();
    expect(scheduledTimes(), [
      DateTime(2026, 10, 20, 11),
      DateTime(2026, 10, 20, 12),
    ]);

    await scheduler.reconcile();
    expect(gateway.scheduleCalls, 2, reason: 'idempotent');
    expect(gateway.cancelCalls, 0);
  });

  test('reschedules when the item moves and cancels when done', () async {
    final item = await dentistAtNoon();
    await reminders.add(item.id, offsetMinutes: 0);
    await scheduler.reconcile();

    final moved = await actions.planOnDate(item, today, time: 15 * 60);
    await scheduler.reconcile();
    expect(scheduledTimes(), [DateTime(2026, 10, 20, 15)]);

    await actions.complete(moved);
    await scheduler.reconcile();
    expect(gateway.scheduled, isEmpty);
  });

  test('cancels everything when notifications are turned off', () async {
    final item = await dentistAtNoon();
    await reminders.add(item.id, offsetMinutes: 0);
    await scheduler.reconcile();

    await settings.save(
      const AppSettings(notificationIntensity: NotificationIntensity.off),
    );
    await scheduler.reconcile();
    expect(gateway.scheduled, isEmpty);
  });

  test('removes notifications it no longer knows about', () async {
    gateway.scheduled[42] = PlannedNotification(
      itemId: 'gone',
      reminderId: 'gone',
      fireAt: DateTime(2026, 10, 21),
      title: 'Stale',
      silent: false,
    );
    await scheduler.reconcile();
    expect(gateway.scheduled, isEmpty);
  });

  test('schedules the weekly review reminder without buttons', () async {
    await settings.save(
      const AppSettings(notificationIntensity: NotificationIntensity.standard),
    );
    await scheduler.reconcile();
    final review = gateway.scheduled.values.single;
    expect(review.kind, NotificationKind.review);
    expect(payloadKind(review.payload), NotificationKind.review);
    expect(parsePayload(review.payload), isNull);
    // Tuesday 20 Oct 09:00 → Sunday 25 Oct 18:00.
    expect(review.fireAt, DateTime(2026, 10, 25, 18));
  });

  group('buttons', () {
    Future<PlannedNotification> scheduledDentist() async {
      final item = await dentistAtNoon();
      await reminders.add(item.id, offsetMinutes: 0);
      await scheduler.reconcile();
      return gateway.scheduled.values.single;
    }

    test('Done completes the item and clears its reminders', () async {
      final n = await scheduledDentist();
      await buttons.handle(NotificationAction.done, n.payload);
      expect((await items.getItem(n.itemId!))!.status, ItemStatus.done);
      expect(gateway.scheduled, isEmpty);
    });

    test('Snooze 1 h fires again an hour from now', () async {
      final n = await scheduledDentist();
      await buttons.handle(NotificationAction.snoozeHour, n.payload);
      expect(scheduledTimes(), [DateTime(2026, 10, 20, 12)]);
      // The reminder's own time is noon too, so the later of the two wins.
      expect(
        (await reminders.get(n.reminderId!))!.snoozedUntil,
        DateTime(2026, 10, 20, 10),
      );
    });

    test('Tomorrow fires at 9:00 tomorrow', () async {
      final n = await scheduledDentist();
      await buttons.handle(NotificationAction.snoozeTomorrow, n.payload);
      expect(scheduledTimes(), [DateTime(2026, 10, 21, 9)]);
    });

    test('ignores payloads that are not ours', () async {
      await buttons.handle(NotificationAction.done, 'nonsense');
      await buttons.handle(NotificationAction.done, null);
    });
  });
}
