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
    required this.title,
    required String this.body,
    required this.silent,
  }) : kind = NotificationKind.digest,
       itemId = null,
       reminderId = null,
       listId = null;

  const PlannedNotification.review({
    required this.fireAt,
    required this.silent,
    this.title = 'Time for your weekly review',
    this.body = 'About 15 minutes to clear your head and plan the week.',
  }) : kind = NotificationKind.review,
       itemId = null,
       reminderId = null,
       listId = null,
       _key = null;

  const PlannedNotification.backup({
    required this.fireAt,
    required this.silent,
    this.title = 'Time to back up',
    this.body = 'Export a copy, so a lost phone doesn’t mean lost plans.',
  }) : kind = NotificationKind.backup,
       itemId = null,
       reminderId = null,
       listId = null,
       _key = null;

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
  NotificationTexts texts = NotificationTexts.english,
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
        body: item.doneMeans == null ? null : texts.doneMeans(item.doneMeans!),
        silent: silent,
      ),
    );
  }
  if (settings.reviewReminder) {
    planned.add(
      PlannedNotification.review(
        title: texts.reviewTitle,
        body: texts.reviewBody,
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
          title: texts.blockTitle(listName),
          body: texts.blockBody(listName),
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
      final body = morningDigest(openItems, date, texts: texts);
      if (body == null || !fireAt.isAfter(now)) continue;
      planned.add(
        PlannedNotification.digest(
          title: texts.digestTitle,
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
      PlannedNotification.backup(
        fireAt: backupDueAt,
        silent: silent,
        title: texts.backupTitle,
        body: texts.backupBody,
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
String? morningDigest(
  Iterable<Item> items,
  LocalDate day, {
  NotificationTexts texts = NotificationTexts.english,
}) {
  final view = buildTodayView(items, day);
  final others = view.alsoToday.length + view.carriedOver.length;
  if (view.mustDo.isEmpty && others == 0) return null;
  final parts = [
    if (view.mustDo.isNotEmpty)
      texts.digestMustDos(
        view.mustDo.length,
        view.mustDo.map((i) => i.title).join(', '),
      ),
    if (others > 0)
      view.mustDo.isEmpty
          ? texts.digestOnToday(others)
          : texts.digestMoreToday(others),
  ];
  return parts.join(' · ');
}

/// The words notifications use, in the app's language. The domain stays
/// free of Flutter, so the app passes these in; [english] is the default.
@immutable
class NotificationTexts {
  const NotificationTexts({
    required this.reviewTitle,
    required this.reviewBody,
    required this.backupTitle,
    required this.backupBody,
    required this.digestTitle,
    required this.doneMeans,
    required this.blockTitle,
    required this.blockBody,
    required this.digestMustDos,
    required this.digestMoreToday,
    required this.digestOnToday,
  });

  final String reviewTitle;
  final String reviewBody;
  final String backupTitle;
  final String backupBody;
  final String digestTitle;
  final String Function(String doneMeans) doneMeans;
  final String Function(String list) blockTitle;
  final String Function(String list) blockBody;
  final String Function(int count, String titles) digestMustDos;
  final String Function(int count) digestMoreToday;
  final String Function(int count) digestOnToday;

  static const english = NotificationTexts(
    reviewTitle: 'Time for your weekly review',
    reviewBody: 'About 15 minutes to clear your head and plan the week.',
    backupTitle: 'Time to back up',
    backupBody: 'Export a copy, so a lost phone doesn’t mean lost plans.',
    digestTitle: 'Today',
    doneMeans: _doneMeans,
    blockTitle: _blockTitle,
    blockBody: _blockBody,
    digestMustDos: _digestMustDos,
    digestMoreToday: _digestMoreToday,
    digestOnToday: _digestOnToday,
  );
}

String _doneMeans(String text) => 'Done means: $text';
String _blockTitle(String list) => '$list time';
String _blockBody(String list) => 'Work through $list in one go.';
String _digestMustDos(int count, String titles) =>
    '$count must-do${count == 1 ? '' : 's'}: $titles';
String _digestMoreToday(int count) => '$count more today';
String _digestOnToday(int count) => '$count on Today';
