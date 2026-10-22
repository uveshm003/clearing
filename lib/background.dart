import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/notification_scheduler.dart';
import 'core/providers.dart';
import 'data/db/database.dart';
import 'data/home_widgets.dart';
import 'data/local_notifications.dart';

/// Entry points that run without the UI, in their own isolate.

/// Run by `SchedulerReceiver.kt` on boot, after an app update, on a time or
/// time-zone change, and just after local midnight (PRD §7, §8.3, §8.4).
@pragma('vm:entry-point')
Future<void> backgroundSync() async {
  try {
    await _withServices((container) async {
      await container.read(seriesActionsProvider).advanceAll();
      await container.read(lifecycleActionsProvider).tidy();
      await container.read(notificationSchedulerProvider).reconcile();
      await container.read(widgetSyncProvider).refresh();
    });
  } finally {
    await const MethodChannel('clearing/background').invokeMethod<void>('done');
  }
}

/// A notification button pressed while the app isn't in front (FR-09).
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationAction(
  NotificationResponse response,
) async {
  final action = NotificationAction.byName(response.actionId);
  if (action == null) return;
  await _withServices(
    (container) => container
        .read(notificationActionsProvider)
        .handle(action, response.payload),
  );
}

/// The Today widget's check mark (FR-14): completes the item without opening
/// the app, then refreshes the widget and reminders.
@pragma('vm:entry-point')
Future<void> onWidgetAction(Uri? uri) async {
  if (WidgetLink.parse(uri) case CompleteLink(:final id)) {
    await _withServices((container) async {
      final actions = container.read(itemActionsProvider);
      if (await actions.get(id) case final item?) await actions.complete(item);
      await container.read(widgetSyncProvider).refresh();
      await container.read(notificationSchedulerProvider).reconcile();
    });
  }
}

Future<void> _withServices(
  Future<void> Function(ProviderContainer container) run,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase.open();
  final notifications = LocalNotifications();
  await notifications.initialize(
    onTap: (_) {},
    onBackgroundAction: onBackgroundNotificationAction,
  );
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      notificationGatewayProvider.overrideWithValue(notifications),
      homeWidgetGatewayProvider.overrideWithValue(const HomeWidgets()),
    ],
  );
  try {
    await run(container);
  } finally {
    container.dispose();
    await db.close();
  }
}
