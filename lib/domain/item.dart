import 'package:meta/meta.dart';

import 'enums.dart';
import 'local_date.dart';

/// Signature used by `copyWith` to distinguish "leave unchanged" (omit the
/// argument) from "set to null" (pass `() => null`).
typedef Nullable<T> = T? Function();

/// A captured thought, commitment or idea (PRD §3).
@immutable
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.doneMeans,
    this.horizon,
    this.horizonSetOn,
    this.doDate,
    this.doTime,
    this.deadline,
    this.mustDo = false,
    this.listId,
    this.waitingOn,
    this.followUpDate,
    this.seriesId,
    this.occurrenceDate,
    this.sortOrder = 0,
    this.completedAt,
    this.archived = false,
    this.trashedAt,
    this.effort,
    this.firstStep,
  });

  final String id;
  final String title;
  final String? notes;
  final String? doneMeans;
  final ItemStatus status;

  /// Soft horizon; ignored when [doDate] is set.
  final WhenHorizon? horizon;

  /// The local date on which [horizon] was chosen. Lets Today tell a "Today"
  /// item set yesterday (carried over) from one set this morning.
  final LocalDate? horizonSetOn;

  final LocalDate? doDate;

  /// Minutes from local midnight; only meaningful with [doDate].
  final int? doTime;
  final LocalDate? deadline;
  final bool mustDo;
  final String? listId;
  final String? waitingOn;
  final LocalDate? followUpDate;
  final String? seriesId;
  final LocalDate? occurrenceDate;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool archived;
  final DateTime? trashedAt;

  /// Rough minutes the item takes; see [effortSteps].
  final int? effort;

  /// The smallest first step, pinned at the top of Focus.
  final String? firstStep;

  /// The effort choices offered, in minutes. 120 stands for "longer".
  static const effortSteps = [5, 15, 30, 60, 120];

  /// The effective "When": a date always wins over a horizon.
  When get when {
    if (doDate != null) return When.onDate;
    return switch (horizon) {
      WhenHorizon.today => When.today,
      WhenHorizon.thisWeek => When.thisWeek,
      WhenHorizon.anytime || null => When.anytime,
    };
  }

  Item copyWith({
    String? title,
    Nullable<String>? notes,
    Nullable<String>? doneMeans,
    ItemStatus? status,
    Nullable<WhenHorizon>? horizon,
    Nullable<LocalDate>? horizonSetOn,
    Nullable<LocalDate>? doDate,
    Nullable<int>? doTime,
    Nullable<LocalDate>? deadline,
    bool? mustDo,
    Nullable<String>? listId,
    Nullable<String>? waitingOn,
    Nullable<LocalDate>? followUpDate,
    Nullable<String>? seriesId,
    Nullable<LocalDate>? occurrenceDate,
    double? sortOrder,
    DateTime? updatedAt,
    Nullable<DateTime>? completedAt,
    bool? archived,
    Nullable<DateTime>? trashedAt,
    Nullable<int>? effort,
    Nullable<String>? firstStep,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      notes: notes != null ? notes() : this.notes,
      doneMeans: doneMeans != null ? doneMeans() : this.doneMeans,
      status: status ?? this.status,
      horizon: horizon != null ? horizon() : this.horizon,
      horizonSetOn: horizonSetOn != null ? horizonSetOn() : this.horizonSetOn,
      doDate: doDate != null ? doDate() : this.doDate,
      doTime: doTime != null ? doTime() : this.doTime,
      deadline: deadline != null ? deadline() : this.deadline,
      mustDo: mustDo ?? this.mustDo,
      listId: listId != null ? listId() : this.listId,
      waitingOn: waitingOn != null ? waitingOn() : this.waitingOn,
      followUpDate: followUpDate != null ? followUpDate() : this.followUpDate,
      seriesId: seriesId != null ? seriesId() : this.seriesId,
      occurrenceDate: occurrenceDate != null
          ? occurrenceDate()
          : this.occurrenceDate,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
      archived: archived ?? this.archived,
      trashedAt: trashedAt != null ? trashedAt() : this.trashedAt,
      effort: effort != null ? effort() : this.effort,
      firstStep: firstStep != null ? firstStep() : this.firstStep,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Item &&
      other.id == id &&
      other.title == title &&
      other.notes == notes &&
      other.doneMeans == doneMeans &&
      other.status == status &&
      other.horizon == horizon &&
      other.horizonSetOn == horizonSetOn &&
      other.doDate == doDate &&
      other.doTime == doTime &&
      other.deadline == deadline &&
      other.mustDo == mustDo &&
      other.listId == listId &&
      other.waitingOn == waitingOn &&
      other.followUpDate == followUpDate &&
      other.seriesId == seriesId &&
      other.occurrenceDate == occurrenceDate &&
      other.sortOrder == sortOrder &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.completedAt == completedAt &&
      other.archived == archived &&
      other.trashedAt == trashedAt &&
      other.effort == effort &&
      other.firstStep == firstStep;

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    notes,
    doneMeans,
    status,
    horizon,
    horizonSetOn,
    doDate,
    doTime,
    deadline,
    mustDo,
    listId,
    waitingOn,
    followUpDate,
    seriesId,
    occurrenceDate,
    sortOrder,
    createdAt,
    updatedAt,
    completedAt,
    archived,
    trashedAt,
    effort,
    firstStep,
  ]);

  @override
  String toString() => 'Item($id, "$title", $status, $when)';
}
