import 'package:meta/meta.dart';

import 'item.dart';

/// An item may have at most this many reminders (FR-08).
const maxRemindersPerItem = 3;

/// The time of day an offset reminder counts back from when its item has a
/// date but no time.
const defaultReminderTime = 9 * 60;

/// The offsets offered in the reminder picker, in minutes before (FR-08).
const reminderOffsetPresets = [0, 10, 60, 24 * 60];

/// A "remind me" for an item, separate from its do-date and deadline (FR-08).
///
/// Either relative ([offsetMinutes] before the item's date and time) or
/// absolute ([fireAt]), never both.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.itemId,
    this.offsetMinutes,
    this.fireAt,
    this.enabled = true,
    this.snoozedUntil,
  }) : assert((offsetMinutes == null) != (fireAt == null));

  final String id;
  final String itemId;
  final int? offsetMinutes;

  /// A local wall-clock time, so it stays "9:00" after a time-zone change.
  final DateTime? fireAt;
  final bool enabled;

  /// Set by Snooze; wins when it is later than the reminder's own time.
  final DateTime? snoozedUntil;

  bool get isRelative => offsetMinutes != null;

  /// When this reminder fires for [item], in local time. Null for a relative
  /// reminder on an item without a date.
  DateTime? fireTimeFor(Item item) {
    final offset = offsetMinutes;
    final date = item.doDate;
    final base = offset == null
        ? fireAt
        : date?.atMinutes((item.doTime ?? defaultReminderTime) - offset);
    final snoozed = snoozedUntil;
    if (snoozed != null && (base == null || snoozed.isAfter(base))) {
      return snoozed;
    }
    return base;
  }

  Reminder copyWith({bool? enabled, DateTime? Function()? snoozedUntil}) =>
      Reminder(
        id: id,
        itemId: itemId,
        offsetMinutes: offsetMinutes,
        fireAt: fireAt,
        enabled: enabled ?? this.enabled,
        snoozedUntil: snoozedUntil != null ? snoozedUntil() : this.snoozedUntil,
      );

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.itemId == itemId &&
      other.offsetMinutes == offsetMinutes &&
      other.fireAt == fireAt &&
      other.enabled == enabled &&
      other.snoozedUntil == snoozedUntil;

  @override
  int get hashCode =>
      Object.hash(id, itemId, offsetMinutes, fireAt, enabled, snoozedUntil);
}
