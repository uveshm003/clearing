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

  /// Rough minutes the item takes (5, 15, 30, 60, or more). Added in schema
  /// version 4.
  IntColumn get effort => integer().nullable()();

  /// The smallest first step, pinned at the top of Focus. Added in schema
  /// version 4.
  TextColumn get firstStep => text().nullable()();

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

  // Added in schema version 4.

  /// A colour name from the curated, contrast-checked set.
  TextColumn get colour => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// A project is a list with an outcome; only its next action shows on
  /// Today and This week.
  BoolColumn get isProject => boolean().withDefault(const Constant(false))();
  TextColumn get outcome => text().nullable()();
  TextColumn get targetDate =>
      text().map(const LocalDateConverter()).nullable()();

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

  /// A flexible routine: this many times a week, on any days. Added in
  /// schema version 4.
  IntColumn get weeklyTarget => integer().nullable()();

  /// Title, list, time, reminder offsets, done-means and subtasks to copy
  /// into each new occurrence.
  TextColumn get template => text().map(const JsonConverter())();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A time slot for working through a whole list, e.g. "Errands, Saturday
/// 10:00" (FR-05). Either one date, or weekly on [weekday]. Added in schema
/// version 3.
@DataClassName('BatchBlockRow')
class BatchBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get listId =>
      text().references(Lists, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().map(const LocalDateConverter()).nullable()();

  /// [DateTime.weekday] numbering; repeats weekly when set.
  IntColumn get weekday => integer().nullable()();

  /// Minutes from local midnight.
  IntColumn get time => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((date IS NULL) != (weekday IS NULL))',
  ];
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

/// Where or how something can be done: at home, out, low energy (FR-22).
/// Added in schema version 4.
@DataClassName('ContextRow')
class Contexts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<ContextKind>()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Which contexts an item has. The id is `itemId|contextId`, so a backup
/// can upsert rows by id like every other table.
@DataClassName('ItemContextRow')
@TableIndex(name: 'item_contexts_item_idx', columns: {#itemId})
class ItemContexts extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get contextId =>
      text().references(Contexts, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per finished day, written at the day's end: how Today went.
/// The id is the date. Added in schema version 4.
@DataClassName('DayRecordRow')
class DayRecords extends Table {
  TextColumn get id => text()();
  IntColumn get mustDoPlanned => integer().withDefault(const Constant(0))();
  IntColumn get mustDoDone => integer().withDefault(const Constant(0))();
  IntColumn get closed => integer().withDefault(const Constant(0))();
  BoolColumn get allClear => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// What happened to an item and when, for its activity line. Added in
/// schema version 4.
@DataClassName('ItemEventRow')
@TableIndex(name: 'item_events_item_idx', columns: {#itemId})
class ItemEvents extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ItemEventKind>()();
  DateTimeColumn get at => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A photo kept with an item, stored in the app's own files. Added in
/// schema version 4.
@DataClassName('AttachmentRow')
@TableIndex(name: 'attachments_item_idx', columns: {#itemId})
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// The file's name inside the attachments folder.
  TextColumn get fileName => text()();
  TextColumn get mime => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A search kept as a smart list. Added in schema version 4.
@DataClassName('SavedSearchRow')
class SavedSearches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get filter => text().map(const JsonConverter())();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A private note from the weekly review: something the user is glad they
/// did. Added in schema version 4.
@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
