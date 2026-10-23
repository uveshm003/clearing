import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'application/notification_scheduler.dart';
import 'background.dart';
import 'core/providers.dart';
import 'core/error_log.dart';
import 'core/licenses.dart';
import 'core/router.dart';
import 'data/db/database.dart';
import 'data/home_widgets.dart';
import 'data/local_notifications.dart';
import 'domain/notification_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  // Errors stay on the phone; people may attach them to feedback.
  final errorLog = ErrorLog(
    File('${(await getApplicationSupportDirectory()).path}/errors.log'),
  );
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLog.record(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    errorLog.record(error, stack);
    return false;
  };

  final notifications = LocalNotifications();
  final container = ProviderContainer(
    overrides: [
      errorLogProvider.overrideWithValue(errorLog),
      databaseProvider.overrideWithValue(AppDatabase.open()),
      notificationGatewayProvider.overrideWithValue(notifications),
      homeWidgetGatewayProvider.overrideWithValue(const HomeWidgets()),
    ],
  );

  void respond(NotificationResponse response) {
    final action = NotificationAction.byName(response.actionId);
    if (action != null) {
      container
          .read(notificationActionsProvider)
          .handle(action, response.payload);
      return;
    }
    switch (payloadKind(response.payload)) {
      case NotificationKind.review:
        container.read(routerProvider).push(Routes.review);
      case NotificationKind.backup:
        container.read(routerProvider).push(Routes.backup);
      case NotificationKind.digest:
        container.read(routerProvider).go(Routes.today);
      case NotificationKind.block:
        if (payloadListId(response.payload) case final listId?) {
          container.read(routerProvider).push(Routes.list(listId));
        }
      case NotificationKind.reminder:
        if (parsePayload(response.payload) case (
          :final itemId,
          reminderId: _,
        )) {
          container.read(routerProvider).push(Routes.item(itemId));
        }
      case null:
        break;
    }
  }

  NotificationResponse? launch;
  try {
    await notifications.initialize(
      onTap: respond,
      onBackgroundAction: onBackgroundNotificationAction,
    );
    launch = await notifications.launchResponse();
    await HomeWidget.registerInteractivityCallback(onWidgetAction);
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
