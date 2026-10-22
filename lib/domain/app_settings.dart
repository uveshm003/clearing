import 'package:meta/meta.dart';

import 'enums.dart';

/// User preferences (FR-21). Stored as one JSON value per key so new settings
/// never need a schema migration, and all of them travel with an export.
@immutable
class AppSettings {
  const AppSettings({
    this.weekStart = DateTime.monday,
    this.reviewWeekday = DateTime.sunday,
    this.reviewTime = 18 * 60,
    this.reviewReminder = true,
    this.mustDoCap = 3,
    this.notificationIntensity = NotificationIntensity.gentle,
    this.quietHoursStart = 22 * 60,
    this.quietHoursEnd = 7 * 60,
    this.autoArchiveDays = 7,
    this.theme = ThemePreference.system,
    this.starterSuggestions = true,
    this.exportReminderDays = 30,
    this.lastExportAt,
    this.inboxBadge = true,
  }) : assert(mustDoCap >= minMustDoCap && mustDoCap <= maxMustDoCap);

  static const minMustDoCap = 1;
  static const maxMustDoCap = 5;

  /// [DateTime.weekday] numbering: 1 = Monday.
  final int weekStart;
  final int reviewWeekday;

  /// Minutes from local midnight.
  final int reviewTime;

  /// A gentle weekly nudge to review, at [reviewWeekday] and [reviewTime].
  final bool reviewReminder;
  final int mustDoCap;
  final NotificationIntensity notificationIntensity;
  final int quietHoursStart;
  final int quietHoursEnd;
  final int autoArchiveDays;
  final ThemePreference theme;
  final bool starterSuggestions;

  /// Null turns the export reminder off.
  final int? exportReminderDays;

  /// When a backup was last exported, which the export reminder counts from.
  final DateTime? lastExportAt;
  final bool inboxBadge;

  AppSettings copyWith({
    int? weekStart,
    int? reviewWeekday,
    int? reviewTime,
    bool? reviewReminder,
    int? mustDoCap,
    NotificationIntensity? notificationIntensity,
    int? quietHoursStart,
    int? quietHoursEnd,
    int? autoArchiveDays,
    ThemePreference? theme,
    bool? starterSuggestions,
    int? Function()? exportReminderDays,
    DateTime? Function()? lastExportAt,
    bool? inboxBadge,
  }) => AppSettings(
    weekStart: weekStart ?? this.weekStart,
    reviewWeekday: reviewWeekday ?? this.reviewWeekday,
    reviewTime: reviewTime ?? this.reviewTime,
    reviewReminder: reviewReminder ?? this.reviewReminder,
    mustDoCap: mustDoCap ?? this.mustDoCap,
    notificationIntensity: notificationIntensity ?? this.notificationIntensity,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    autoArchiveDays: autoArchiveDays ?? this.autoArchiveDays,
    theme: theme ?? this.theme,
    starterSuggestions: starterSuggestions ?? this.starterSuggestions,
    exportReminderDays: exportReminderDays != null
        ? exportReminderDays()
        : this.exportReminderDays,
    lastExportAt: lastExportAt != null ? lastExportAt() : this.lastExportAt,
    inboxBadge: inboxBadge ?? this.inboxBadge,
  );

  Map<String, Object?> toJson() => {
    'weekStart': weekStart,
    'reviewWeekday': reviewWeekday,
    'reviewTime': reviewTime,
    'reviewReminder': reviewReminder,
    'mustDoCap': mustDoCap,
    'notificationIntensity': notificationIntensity.name,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
    'autoArchiveDays': autoArchiveDays,
    'theme': theme.name,
    'starterSuggestions': starterSuggestions,
    'exportReminderDays': exportReminderDays,
    'lastExportAt': lastExportAt?.toIso8601String(),
    'inboxBadge': inboxBadge,
  };

  /// Unknown or malformed values fall back to defaults, so an older or
  /// hand-edited backup can never stop the app from starting.
  factory AppSettings.fromJson(Map<String, Object?> json) {
    const d = AppSettings();
    T read<T>(String key, T fallback) =>
        json[key] is T ? json[key] as T : fallback;
    E readEnum<E extends Enum>(String key, List<E> values, E fallback) =>
        values.where((v) => v.name == json[key]).firstOrNull ?? fallback;

    return AppSettings(
      weekStart: read('weekStart', d.weekStart),
      reviewWeekday: read('reviewWeekday', d.reviewWeekday),
      reviewTime: read('reviewTime', d.reviewTime),
      reviewReminder: read('reviewReminder', d.reviewReminder),
      mustDoCap: read(
        'mustDoCap',
        d.mustDoCap,
      ).clamp(minMustDoCap, maxMustDoCap),
      notificationIntensity: readEnum(
        'notificationIntensity',
        NotificationIntensity.values,
        d.notificationIntensity,
      ),
      quietHoursStart: read('quietHoursStart', d.quietHoursStart),
      quietHoursEnd: read('quietHoursEnd', d.quietHoursEnd),
      autoArchiveDays: read('autoArchiveDays', d.autoArchiveDays),
      theme: readEnum('theme', ThemePreference.values, d.theme),
      starterSuggestions: read('starterSuggestions', d.starterSuggestions),
      exportReminderDays: json.containsKey('exportReminderDays')
          ? json['exportReminderDays'] as int?
          : d.exportReminderDays,
      lastExportAt: DateTime.tryParse('${json['lastExportAt']}'),
      inboxBadge: read('inboxBadge', d.inboxBadge),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.weekStart == weekStart &&
      other.reviewWeekday == reviewWeekday &&
      other.reviewTime == reviewTime &&
      other.reviewReminder == reviewReminder &&
      other.mustDoCap == mustDoCap &&
      other.notificationIntensity == notificationIntensity &&
      other.quietHoursStart == quietHoursStart &&
      other.quietHoursEnd == quietHoursEnd &&
      other.autoArchiveDays == autoArchiveDays &&
      other.theme == theme &&
      other.starterSuggestions == starterSuggestions &&
      other.exportReminderDays == exportReminderDays &&
      other.lastExportAt == lastExportAt &&
      other.inboxBadge == inboxBadge;

  @override
  int get hashCode => Object.hash(
    weekStart,
    reviewWeekday,
    reviewTime,
    reviewReminder,
    mustDoCap,
    notificationIntensity,
    quietHoursStart,
    quietHoursEnd,
    autoArchiveDays,
    theme,
    starterSuggestions,
    exportReminderDays,
    lastExportAt,
    inboxBadge,
  );
}
