import 'dart:convert';

import 'package:meta/meta.dart';

import 'app_settings.dart';
import 'batch_block.dart';
import 'enums.dart';
import 'item.dart';
import 'local_date.dart';
import 'reminder.dart';
import 'review_rules.dart';
import 'today_rules.dart';

/// How far ahead notifications are scheduled (PRD §8.3). A rolling window
/// keeps well under iOS's 64 pending notifications later.
const notificationWindow = Duration(days: 14);

/// What a notification is for.
enum NotificationKind {
  /// An item's reminder, with Done and Snooze buttons.
  reminder,

  /// The weekly review nudge (FR-11); tapping opens the review.
  review,

  /// The periodic nudge to export a backup (FR-17); tapping opens Backup.
  backup,

  /// The start of a batch block (FR-05); tapping opens its list.
  block,

  /// The optional morning summary of Today; tapping opens Today.
  digest,
}

/// One notification the device should have pending.
@immutable
class PlannedNotification {
  const PlannedNotification({
    required String this.itemId,
    required String this.reminderId,
    required this.fireAt,
    required this.title,
    required this.silent,
    this.body,
  }) : kind = NotificationKind.reminder,
       listId = null,
       _key = null;

  /// [key] tells apart each block on each date.
  const PlannedNotification.block({
    required String this.listId,
    required String this._key,
    required this.fireAt,
    required this.title,
    required this.silent,
    this.body,
  }) : kind = NotificationKind.block,
       itemId = null,
       reminderId = null;

  const PlannedNotification.digest({
    required String this._key,
    required this.fireAt,
    required String this.body,
    required this.silent,
  }) : kind = NotificationKind.digest,
       itemId = null,
       reminderId = null,
       listId = null,
       title = 'Today';

  const PlannedNotification.review({required this.fireAt, required this.silent})
    : kind = NotificationKind.review,
      itemId = null,
      reminderId = null,
      listId = null,
      _key = null,
      title = 'Time for your weekly review',
      body = 'About 15 minutes to clear your head and plan the week.';

  const PlannedNotification.backup({required this.fireAt, required this.silent})
    : kind = NotificationKind.backup,
      itemId = null,
      reminderId = null,
      listId = null,
      _key = null,
      title = 'Time to back up',
      body = 'Export a copy, so a lost phone doesn’t mean lost plans.';

  final NotificationKind kind;

  /// Set for [NotificationKind.reminder] only.
  final String? itemId;
  final String? reminderId;

  /// Set for [NotificationKind.block] only.
  final String? listId;
  final String? _key;

  bool get isReminder => kind == NotificationKind.reminder;

  /// Local wall-clock time.
  final DateTime fireAt;
  final String title;
  final String? body;

  /// Gentle intensity posts to a silent channel (FR-09).
  final bool silent;

  /// Stable across runs, so reconciling can match it with what is pending.
  int get id =>
      notificationIdFor(reminderId ?? _key ?? 'clearing-${kind.name}');

  /// Everything that identifies this notification, so a pending one whose
  /// payload differs is out of date.
  String get payload => jsonEncode({
    if (isReminder) ...{
      'item': itemId,
      'reminder': reminderId,
    } else ...{
      'kind': kind.name,
      'list': ?listId,
    },
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

/// The kind of notification a payload belongs to, or null if it isn't ours.
NotificationKind? payloadKind(String? payload) {
  if (payload == null) return null;
  try {
    final json = jsonDecode(payload);
    if (json is! Map) return null;
    if (json.containsKey('reminder')) return NotificationKind.reminder;
    return NotificationKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
  } on FormatException {
    return null;
  }
}

/// The list a batch block notification opens.
String? payloadListId(String? payload) {
  if (payload == null) return null;
  try {
    final json = jsonDecode(payload);
    return json is Map && json['list'] is String
        ? json['list'] as String
        : null;
  } on FormatException {
    return null;
  }
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
/// that land in quiet hours wait until quiet hours end (FR-09). The weekly
/// review reminder, when on, fires at the chosen day and time (FR-11), and
/// the backup reminder at [backupDueAt] (FR-17).
List<PlannedNotification> planNotifications(
  Iterable<(Item, Reminder)> reminders, {
  required AppSettings settings,
  required DateTime now,
  DateTime? backupDueAt,
  Iterable<({BatchBlock block, String listName})> blocks = const [],
  Iterable<Item> openItems = const [],
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
  if (settings.reviewReminder) {
    planned.add(
      PlannedNotification.review(
        fireAt: nextReviewAt(settings, now),
        silent: silent,
      ),
    );
  }
  for (final (:block, :listName) in blocks) {
    final from = LocalDate.fromDateTime(now);
    for (final day in block.datesBetween(from, from.addDays(14))) {
      final fireAt = day.atMinutes(block.time);
      if (!fireAt.isAfter(now) || fireAt.isAfter(until)) continue;
      planned.add(
        PlannedNotification.block(
          listId: block.listId,
          key: 'block-${block.id}-${day.toIso()}',
          fireAt: fireAt,
          title: '$listName time',
          body: 'Work through $listName in one go.',
          silent: silent,
        ),
      );
    }
  }
  if (settings.morningDigest) {
    // Today's and tomorrow's only: later ones would be guesses, and the
    // nightly reconcile writes each one fresh.
    final day = LocalDate.fromDateTime(now);
    for (final date in [day, day.addDays(1)]) {
      final fireAt = date.atMinutes(settings.morningDigestTime);
      final body = morningDigest(openItems, date);
      if (body == null || !fireAt.isAfter(now)) continue;
      planned.add(
        PlannedNotification.digest(
          key: 'digest-${date.toIso()}',
          fireAt: fireAt,
          body: body,
          silent: silent,
        ),
      );
    }
  }
  if (backupDueAt != null && !backupDueAt.isAfter(until)) {
    planned.add(
      PlannedNotification.backup(fireAt: backupDueAt, silent: silent),
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

/// When to next suggest exporting (FR-17): every [days] days counted from
/// the last export, or from [firstUse] if there hasn't been one, at 10:00.
/// Null when the reminder is off or there's nothing worth backing up yet.
DateTime? nextBackupReminder({
  required int? days,
  required DateTime? lastExport,
  required DateTime? firstUse,
  required DateTime now,
}) {
  final anchor = lastExport ?? firstUse;
  if (days == null || days <= 0 || anchor == null) return null;
  var due = DateTime(anchor.year, anchor.month, anchor.day + days, 10);
  while (!due.isAfter(now)) {
    due = DateTime(due.year, due.month, due.day + days, 10);
  }
  return due;
}

/// The morning summary for [day], e.g. "2 must-dos: Pay rent, Call the
/// dentist · 3 more today". Null on a clear day: no news needs no message.
String? morningDigest(Iterable<Item> items, LocalDate day) {
  final view = buildTodayView(items, day);
  final others = view.alsoToday.length + view.carriedOver.length;
  if (view.mustDo.isEmpty && others == 0) return null;
  final parts = [
    if (view.mustDo.isNotEmpty)
      '${view.mustDo.length} must-do${view.mustDo.length == 1 ? '' : 's'}: '
          '${view.mustDo.map((i) => i.title).join(', ')}',
    if (others > 0)
      view.mustDo.isEmpty ? '$others on Today' : '$others more today',
  ];
  return parts.join(' · ');
}
