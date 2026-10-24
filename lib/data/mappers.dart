import 'package:drift/drift.dart';

import '../domain/item.dart';
import '../domain/item_list.dart';
import '../domain/reminder.dart';
import '../domain/repeat_series.dart';
import '../domain/starter_suggestion.dart';
import '../domain/subtask.dart';
import 'db/database.dart';

extension ItemRowMapper on ItemRow {
  Item toDomain() => Item(
    id: id,
    title: title,
    notes: notes,
    doneMeans: doneMeans,
    status: status,
    horizon: whenHorizon,
    horizonSetOn: horizonSetOn,
    doDate: doDate,
    doTime: doTime,
    deadline: deadline,
    mustDo: mustDo,
    listId: listId,
    waitingOn: waitingOn,
    followUpDate: followUpDate,
    seriesId: seriesId,
    occurrenceDate: occurrenceDate,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    completedAt: completedAt,
    archived: archived,
    trashedAt: trashedAt,
    effort: effort,
    firstStep: firstStep,
  );
}

extension ItemMapper on Item {
  ItemsCompanion toCompanion() => ItemsCompanion(
    id: Value(id),
    title: Value(title),
    notes: Value(notes),
    doneMeans: Value(doneMeans),
    status: Value(status),
    whenHorizon: Value(horizon),
    horizonSetOn: Value(horizonSetOn),
    doDate: Value(doDate),
    doTime: Value(doTime),
    deadline: Value(deadline),
    mustDo: Value(mustDo),
    listId: Value(listId),
    waitingOn: Value(waitingOn),
    followUpDate: Value(followUpDate),
    seriesId: Value(seriesId),
    occurrenceDate: Value(occurrenceDate),
    sortOrder: Value(sortOrder),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    completedAt: Value(completedAt),
    archived: Value(archived),
    trashedAt: Value(trashedAt),
    effort: Value(effort),
    firstStep: Value(firstStep),
  );
}

extension SubtaskRowMapper on SubtaskRow {
  Subtask toDomain() => Subtask(
    id: id,
    itemId: itemId,
    title: title,
    done: done,
    sortOrder: sortOrder,
  );
}

extension ListRowMapper on ListRow {
  ItemList toDomain() => ItemList(
    id: id,
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    archived: archived,
    colour: colour,
    pinned: pinned,
    isProject: isProject,
    outcome: outcome,
    targetDate: targetDate,
  );
}

extension StarterSuggestionRowMapper on StarterSuggestionRow {
  StarterSuggestion toDomain() => StarterSuggestion(
    id: id,
    title: title,
    listKind: listKind,
    enabled: enabled,
    userCreated: userCreated,
  );
}

extension ReminderRowMapper on ReminderRow {
  Reminder toDomain() => Reminder(
    id: id,
    itemId: itemId,
    offsetMinutes: offsetMinutes,
    fireAt: fireAt,
    enabled: enabled,
    snoozedUntil: snoozedUntil,
  );
}

extension SeriesRowMapper on SeriesRow {
  RepeatSeries toDomain() => RepeatSeries(
    id: id,
    freq: freq,
    interval: interval,
    weekdays: weekdaysFromMask(weekdays ?? 0),
    monthDay: monthDay,
    startDate: startDate,
    endDate: endDate,
    maxCount: maxCount,
    mode: mode,
    onMissed: onMissed,
    paused: paused,
    template: SeriesTemplate.fromJson(template),
    weeklyTarget: weeklyTarget,
  );
}

extension SeriesMapper on RepeatSeries {
  SeriesCompanion toCompanion(DateTime updatedAt) => SeriesCompanion(
    id: Value(id),
    freq: Value(freq),
    interval: Value(interval),
    weekdays: Value(weekdays.isEmpty ? null : weekdaysToMask(weekdays)),
    monthDay: Value(monthDay),
    startDate: Value(startDate),
    endDate: Value(endDate),
    maxCount: Value(maxCount),
    mode: Value(mode),
    onMissed: Value(onMissed),
    paused: Value(paused),
    template: Value(template.toJson()),
    weeklyTarget: Value(weeklyTarget),
    updatedAt: Value(updatedAt),
  );
}

/// Bit 0 = Monday … bit 6 = Sunday, as stored in `series.weekdays`.
int weekdaysToMask(Set<int> weekdays) =>
    weekdays.fold(0, (mask, day) => mask | 1 << (day - 1));

Set<int> weekdaysFromMask(int mask) => {
  for (var day = 1; day <= 7; day++)
    if (mask & 1 << (day - 1) != 0) day,
};
