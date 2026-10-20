import 'package:drift/drift.dart';

import '../domain/item.dart';
import '../domain/item_list.dart';
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
