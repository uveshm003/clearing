import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'enums.dart';
import 'local_date.dart';

/// What each new occurrence of a series starts with (PRD §3.2).
@immutable
class SeriesTemplate {
  const SeriesTemplate({
    required this.title,
    this.listId,
    this.doTime,
    this.reminderOffsets = const [],
    this.doneMeans,
    this.subtasks = const [],
  });

  final String title;
  final String? listId;

  /// Minutes from local midnight.
  final int? doTime;

  /// Minutes before the occurrence's date and time, as in [Reminder].
  final List<int> reminderOffsets;
  final String? doneMeans;
  final List<String> subtasks;

  SeriesTemplate copyWith({
    String? title,
    String? Function()? listId,
    int? Function()? doTime,
    List<int>? reminderOffsets,
    String? Function()? doneMeans,
    List<String>? subtasks,
  }) => SeriesTemplate(
    title: title ?? this.title,
    listId: listId != null ? listId() : this.listId,
    doTime: doTime != null ? doTime() : this.doTime,
    reminderOffsets: reminderOffsets ?? this.reminderOffsets,
    doneMeans: doneMeans != null ? doneMeans() : this.doneMeans,
    subtasks: subtasks ?? this.subtasks,
  );

  Map<String, Object?> toJson() => {
    'title': title,
    'listId': listId,
    'doTime': doTime,
    'reminderOffsets': reminderOffsets,
    'doneMeans': doneMeans,
    'subtasks': subtasks,
  };

  /// Tolerates missing or malformed keys, like [AppSettings.fromJson].
  factory SeriesTemplate.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    T? read<T>(String key) => map[key] is T ? map[key] as T : null;
    List<T> readList<T>(String key) =>
        (read<List<Object?>>(key) ?? const []).whereType<T>().toList();
    return SeriesTemplate(
      title: read<String>('title') ?? '',
      listId: read<String>('listId'),
      doTime: read<int>('doTime'),
      reminderOffsets: readList<int>('reminderOffsets'),
      doneMeans: read<String>('doneMeans'),
      subtasks: readList<String>('subtasks'),
    );
  }

  static const _listEquality = ListEquality<Object?>();

  @override
  bool operator ==(Object other) =>
      other is SeriesTemplate &&
      other.title == title &&
      other.listId == listId &&
      other.doTime == doTime &&
      _listEquality.equals(other.reminderOffsets, reminderOffsets) &&
      other.doneMeans == doneMeans &&
      _listEquality.equals(other.subtasks, subtasks);

  @override
  int get hashCode => Object.hash(
    title,
    listId,
    doTime,
    _listEquality.hash(reminderOffsets),
    doneMeans,
    _listEquality.hash(subtasks),
  );
}

/// A repeating commitment (FR-10). The series holds the rule; its items are
/// the occurrences, and at most one of them is open at any time.
@immutable
class RepeatSeries {
  RepeatSeries({
    required this.id,
    required this.freq,
    required this.startDate,
    required this.onMissed,
    required this.template,
    this.interval = 1,
    Set<int> weekdays = const {},
    this.monthDay,
    this.endDate,
    this.maxCount,
    this.mode = RepeatMode.fixed,
    this.paused = false,
  }) : assert(interval >= 1),
       assert(monthDay == null || (monthDay >= 1 && monthDay <= 31)),
       assert(weekdays.every((d) => d >= 1 && d <= 7)),
       weekdays = Set.unmodifiable(weekdays);

  final String id;
  final RepeatFrequency freq;

  /// Every [interval] days, weeks or months.
  final int interval;

  /// For weekly series, [DateTime.weekday] numbers (1 = Monday). Empty means
  /// the weekday of [startDate].
  final Set<int> weekdays;

  /// For monthly series, the day of the month, clamped to the month's end.
  /// Null means the day of [startDate].
  final int? monthDay;
  final LocalDate startDate;

  /// The last day an occurrence may fall on.
  final LocalDate? endDate;

  /// The total number of occurrences, counted from [startDate].
  final int? maxCount;

  /// [RepeatMode.fixed] follows the calendar; [RepeatMode.afterCompletion]
  /// counts [interval] units from the day the last occurrence was done, e.g.
  /// "every 6 weeks after a haircut" (FR-10).
  final RepeatMode mode;

  bool get isAfterCompletion => mode == RepeatMode.afterCompletion;
  final OnMissed onMissed;
  final bool paused;
  final SeriesTemplate template;

  RepeatSeries copyWith({
    RepeatFrequency? freq,
    int? interval,
    Set<int>? weekdays,
    int? Function()? monthDay,
    LocalDate? startDate,
    LocalDate? Function()? endDate,
    int? Function()? maxCount,
    RepeatMode? mode,
    OnMissed? onMissed,
    bool? paused,
    SeriesTemplate? template,
  }) => RepeatSeries(
    id: id,
    freq: freq ?? this.freq,
    interval: interval ?? this.interval,
    weekdays: weekdays ?? this.weekdays,
    monthDay: monthDay != null ? monthDay() : this.monthDay,
    startDate: startDate ?? this.startDate,
    endDate: endDate != null ? endDate() : this.endDate,
    maxCount: maxCount != null ? maxCount() : this.maxCount,
    mode: mode ?? this.mode,
    onMissed: onMissed ?? this.onMissed,
    paused: paused ?? this.paused,
    template: template ?? this.template,
  );

  static const _setEquality = SetEquality<int>();

  @override
  bool operator ==(Object other) =>
      other is RepeatSeries &&
      other.id == id &&
      other.freq == freq &&
      other.interval == interval &&
      _setEquality.equals(other.weekdays, weekdays) &&
      other.monthDay == monthDay &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.maxCount == maxCount &&
      other.mode == mode &&
      other.onMissed == onMissed &&
      other.paused == paused &&
      other.template == template;

  @override
  int get hashCode => Object.hash(
    id,
    freq,
    interval,
    _setEquality.hash(weekdays),
    monthDay,
    startDate,
    endDate,
    maxCount,
    mode,
    onMissed,
    paused,
    template,
  );

  @override
  String toString() => 'RepeatSeries($id, $freq/$interval from $startDate)';
}
