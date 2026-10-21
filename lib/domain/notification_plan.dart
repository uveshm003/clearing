import 'dart:convert';

import 'package:meta/meta.dart';

import 'app_settings.dart';
import 'enums.dart';
import 'item.dart';
import 'reminder.dart';

/// How far ahead notifications are scheduled (PRD §8.3). A rolling window
/// keeps well under iOS's 64 pending notifications later.
const notificationWindow = Duration(days: 14);

/// One notification the device should have pending.
@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.itemId,
    required this.reminderId,
    required this.fireAt,
    required this.title,
    required this.silent,
    this.body,
  });

  final String itemId;
  final String reminderId;

  /// Local wall-clock time.
  final DateTime fireAt;
  final String title;
  final String? body;

  /// Gentle intensity posts to a silent channel (FR-09).
  final bool silent;

  /// Stable across runs, so reconciling can match it with what is pending.
  int get id => notificationIdFor(reminderId);

  /// Everything that identifies this notification, so a pending one whose
  /// payload differs is out of date.
  String get payload => jsonEncode({
    'item': itemId,
    'reminder': reminderId,
    'at': fireAt.toIso8601String(),
    'title': title,
    'body': body,
    'silent': silent,
  });

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification && other.payload == payload;

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'PlannedNotification("$title" at $fireAt)';
}

/// The item and reminder a notification payload points at.
({String itemId, String reminderId})? parsePayload(String? payload) {
  if (payload == null) return null;
  try {
    final json = jsonDecode(payload);
    if (json case {'item': String item, 'reminder': String reminder}) {
      return (itemId: item, reminderId: reminder);
    }
  } on FormatException {
    // Not ours.
  }
  return null;
}

/// A 31-bit FNV-1a hash of [reminderId]. Android notification ids are 32-bit
/// ints, and [String.hashCode] is not guaranteed stable between runs.
int notificationIdFor(String reminderId) {
  var hash = 0x811c9dc5;
  for (final unit in reminderId.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// The notifications that should be pending at [now] (PRD §8.3).
///
/// Only active and waiting items notify. Reminders the user timed exactly
/// (at the item's time, at a custom time, or snoozed) fire as set; others
/// that land in quiet hours wait until quiet hours end (FR-09).
List<PlannedNotification> planNotifications(
  Iterable<(Item, Reminder)> reminders, {
  required AppSettings settings,
  required DateTime now,
}) {
  if (settings.notificationIntensity == NotificationIntensity.off) return [];
  final silent = settings.notificationIntensity == NotificationIntensity.gentle;
  final until = now.add(notificationWindow);
  final quiet = QuietHours(settings.quietHoursStart, settings.quietHoursEnd);
  final seen = <(String, DateTime)>{};
  final planned = <PlannedNotification>[];

  for (final (item, reminder) in reminders) {
    if (!reminder.enabled) continue;
    if (item.status != ItemStatus.active && item.status != ItemStatus.waiting) {
      continue;
    }
    var fireAt = reminder.fireTimeFor(item);
    if (fireAt == null) continue;
    final exact =
        reminder.offsetMinutes == 0 ||
        reminder.fireAt != null ||
        reminder.snoozedUntil == fireAt;
    if (!exact) fireAt = quiet.deferred(fireAt);
    if (!fireAt.isAfter(now) || fireAt.isAfter(until)) continue;
    // Two reminders deferred to the same minute notify once.
    if (!seen.add((item.id, fireAt))) continue;

    planned.add(
      PlannedNotification(
        itemId: item.id,
        reminderId: reminder.id,
        fireAt: fireAt,
        title: item.title,
        body: item.doneMeans == null ? null : 'Done means: ${item.doneMeans}',
        silent: silent,
      ),
    );
  }
  planned.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned;
}

/// A daily quiet period in minutes from midnight; it may wrap past midnight.
/// Equal start and end means no quiet hours.
@immutable
class QuietHours {
  const QuietHours(this.start, this.end);

  final int start;
  final int end;

  bool contains(DateTime time) {
    final minutes = time.hour * 60 + time.minute;
    if (start == end) return false;
    return start < end
        ? minutes >= start && minutes < end
        : minutes >= start || minutes < end;
  }

  /// [time], or the end of the quiet hours it falls in.
  DateTime deferred(DateTime time) {
    if (!contains(time)) return time;
    final minutes = time.hour * 60 + time.minute;
    final nextDay = start > end && minutes >= start;
    return DateTime(
      time.year,
      time.month,
      time.day + (nextDay ? 1 : 0),
      0,
      end,
    );
  }
}
