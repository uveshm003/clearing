import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'application/notification_scheduler.dart';
import 'background.dart';
import 'core/providers.dart';
import 'core/router.dart';
import 'data/db/database.dart';
import 'data/local_notifications.dart';
import 'domain/notification_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = LocalNotifications();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(AppDatabase.open()),
      notificationGatewayProvider.overrideWithValue(notifications),
    ],
  );

  void respond(NotificationResponse response) {
    final action = NotificationAction.byName(response.actionId);
    if (action != null) {
      container
          .read(notificationActionsProvider)
          .handle(action, response.payload);
    } else if (parsePayload(response.payload) case (
      :final itemId,
      reminderId: _,
    )) {
      container.read(routerProvider).push(Routes.item(itemId));
    }
  }

  NotificationResponse? launch;
  try {
    await notifications.initialize(
      onTap: respond,
      onBackgroundAction: onBackgroundNotificationAction,
    );
    launch = await notifications.launchResponse();
  } catch (error, stack) {
    // The app works without reminders; never block start-up on them.
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const ClearingApp()),
  );
  if (launch != null) respond(launch);
}
