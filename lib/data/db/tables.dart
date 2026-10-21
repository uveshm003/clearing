import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import 'converters.dart';

// Schema from PRD §3.2. Every syncable row carries `updated_at` so a future
// sync layer can be added without changing what existing columns mean.

@DataClassName('ItemRow')
@TableIndex(name: 'items_status_idx', columns: {#status})
@TableIndex(name: 'items_do_date_idx', columns: {#doDate})
@TableIndex(name: 'items_list_idx', columns: {#listId})
@TableIndex(name: 'items_series_idx', columns: {#seriesId})
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get doneMeans => text().nullable()();
  TextColumn get status => textEnum<ItemStatus>()();
  TextColumn get whenHorizon => textEnum<WhenHorizon>().nullable()();
  TextColumn get horizonSetOn =>
      text().map(const LocalDateConverter()).nullable()();
  TextColumn get doDate => text().map(const LocalDateConverter()).nullable()();

  /// Minutes from local midnight.
  IntColumn get doTime => integer().nullable()();
  TextColumn get deadline =>
      text().map(const LocalDateConverter()).nullable()();
  BoolColumn get mustDo => boolean().withDefault(const Constant(false))();
  TextColumn get listId =>
      text().nullable().references(Lists, #id, onDelete: KeyAction.setNull)();
  TextColumn get waitingOn => text().nullable()();
  TextColumn get followUpDate =>
      text().map(const LocalDateConverter()).nullable()();
  TextColumn get seriesId =>
      text().nullable().references(Series, #id, onDelete: KeyAction.setNull)();
  TextColumn get occurrenceDate =>
      text().map(const LocalDateConverter()).nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SubtaskRow')
@TableIndex(name: 'subtasks_item_idx', columns: {#itemId})
class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ListRow')
class Lists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<ListKind>()();
  TextColumn get icon => text().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SeriesRow')
class Series extends Table {
  TextColumn get id => text()();
  TextColumn get freq => textEnum<RepeatFrequency>()();
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// Bit 0 = Monday … bit 6 = Sunday.
  IntColumn get weekdays => integer().nullable()();
  IntColumn get monthDay => integer().nullable()();
  TextColumn get startDate => text().map(const LocalDateConverter())();
  TextColumn get endDate => text().map(const LocalDateConverter()).nullable()();
  IntColumn get maxCount => integer().nullable()();
  TextColumn get mode =>
      textEnum<RepeatMode>().withDefault(Constant(RepeatMode.fixed.name))();
  TextColumn get onMissed => textEnum<OnMissed>()();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();

  /// Title, list, time, reminder offsets, done-means and subtasks to copy
  /// into each new occurrence.
  TextColumn get template => text().map(const JsonConverter())();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReminderRow')
@TableIndex(name: 'reminders_item_idx', columns: {#itemId})
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// Relative to the item's do-date and time; null when [fireAt] is used.
  IntColumn get offsetMinutes => integer().nullable()();
  DateTimeColumn get fireAt => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Set by Snooze on a notification; the reminder fires again at this time
  /// unless its own time is later. Added in schema version 2.
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((offset_minutes IS NULL) != (fire_at IS NULL))',
  ];
}

@DataClassName('TemplateRow')
class Templates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<TemplateKind>()();
  TextColumn get items => text().map(const JsonConverter())();
  TextColumn get seriesId =>
      text().nullable().references(Series, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StarterSuggestionRow')
class StarterSuggestions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get listKind => textEnum<ListKind>().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get userCreated => boolean().withDefault(const Constant(false))();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReviewSessionRow')
class ReviewSessions extends Table {
  TextColumn get id => text()();
  TextColumn get kind => textEnum<ReviewKind>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Per-step progress and counts, so a review can be resumed.
  TextColumn get counts => text().map(const JsonConverter())();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();

  /// JSON-encoded value; may be the literal `null`.
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
