import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../application/notification_scheduler.dart';
import '../domain/notification_plan.dart';

/// [NotificationGateway] backed by flutter_local_notifications (PRD §7).
class LocalNotifications implements NotificationGateway {
  LocalNotifications([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _standardChannel = AndroidNotificationChannel(
    'reminders',
    'Reminders',
    description: 'Reminders you set, with sound',
    importance: Importance.high,
  );

  /// Gentle intensity: shown in the shade without sound or vibration.
  static const _gentleChannel = AndroidNotificationChannel(
    'reminders_gentle',
    'Gentle reminders',
    description: 'Reminders you set, without sound',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Must run before anything else, in every isolate that schedules.
  /// [onTap] runs for taps while the app is open; [onBackgroundAction] for
  /// buttons pressed while it isn't, in a background isolate.
  Future<void> initialize({
    required DidReceiveNotificationResponseCallback onTap,
    required DidReceiveBackgroundNotificationResponseCallback
    onBackgroundAction,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onBackgroundAction,
    );
    for (final channel in [_standardChannel, _gentleChannel]) {
      await _android?.createNotificationChannel(channel);
    }
  }

  /// The response that launched the app, if a notification did.
  Future<NotificationResponse?> launchResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false
        ? details!.notificationResponse
        : null;
  }

  @override
  Future<bool> areEnabled() async =>
      await _android?.areNotificationsEnabled() ?? true;

  /// POST_NOTIFICATIONS on Android 13+; already granted below that.
  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  /// SCHEDULE_EXACT_ALARM; USE_EXACT_ALARM is reserved for alarm-clock and
  /// calendar apps (PRD §7).
  @override
  Future<void> requestExact() async => _android?.requestExactAlarmsPermission();

  @override
  Future<Map<int, String?>> pending() async => {
    for (final request in await _plugin.pendingNotificationRequests())
      request.id: request.payload,
  };

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> schedule(PlannedNotification notification) async {
    await _useDeviceTimeZone();
    final channel = notification.silent ? _gentleChannel : _standardChannel;
    final at = notification.fireAt;
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
      // The wall-clock time in the current zone, so "9:00" stays 9:00.
      scheduledDate: tz.TZDateTime(
        tz.local,
        at.year,
        at.month,
        at.day,
        at.hour,
        at.minute,
      ),
      androidScheduleMode: await canScheduleExact()
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: notification.silent ? Priority.low : Priority.high,
          playSound: !notification.silent,
          enableVibration: !notification.silent,
          category: AndroidNotificationCategory.reminder,
          actions: [
            if (!notification.isReview)
              for (final action in NotificationAction.values)
                AndroidNotificationAction(action.name, action.label),
          ],
        ),
      ),
    );
  }

  static bool _timeZonesLoaded = false;

  /// Points `tz.local` at the device's zone. Re-read on every call, so
  /// scheduling after travel uses the new zone.
  static Future<void> _useDeviceTimeZone() async {
    if (!_timeZonesLoaded) {
      tz_data.initializeTimeZones();
      _timeZonesLoaded = true;
    }
    final info = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on tz.LocationNotFoundException {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
