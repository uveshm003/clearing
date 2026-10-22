import 'enums.dart';
import 'item.dart';
import 'local_date.dart';

/// The placement decisions of the clarify flow and Today actions (PRD §4.2,
/// FR-03). Each returns a new item; persisting it is the caller's job.
///
/// Every transition keeps the invariant that an item has exactly one status
/// and one effective "When".
extension ItemTransitions on Item {
  /// Active, set to Today as a soft horizon.
  Item planToday(LocalDate today) =>
      _activate(horizon: WhenHorizon.today, horizonSetOn: today);

  Item planThisWeek(LocalDate today) =>
      _activate(horizon: WhenHorizon.thisWeek, horizonSetOn: today);

  Item planAnytime() => _activate(horizon: WhenHorizon.anytime);

  /// Active on [date], optionally at [time] minutes from midnight. A date
  /// always wins over a horizon, so the horizon is cleared.
  Item planOnDate(LocalDate date, {int? time}) => copyWith(
    status: ItemStatus.active,
    horizon: () => null,
    horizonSetOn: () => null,
    doDate: () => date,
    doTime: () => time,
    waitingOn: () => null,
    followUpDate: () => null,
  );

  /// Moves a dated or Today item to tomorrow, keeping its time of day.
  Item snoozeToTomorrow(LocalDate today) =>
      planOnDate(today.addDays(1), time: doDate != null ? doTime : null);

  /// Keeps the thought as an idea, not a commitment. Someday items never show
  /// in Today or Upcoming, so dates and the must-do flag are dropped.
  Item moveToSomeday() => copyWith(
    status: ItemStatus.someday,
    mustDo: false,
    horizon: () => null,
    horizonSetOn: () => null,
    doDate: () => null,
    doTime: () => null,
    waitingOn: () => null,
    followUpDate: () => null,
  );

  /// Someone else is doing it (replaces the draft's undefined "delegate").
  Item waitFor(String person, {LocalDate? followUp}) => copyWith(
    status: ItemStatus.waiting,
    mustDo: false,
    waitingOn: () => person.trim(),
    followUpDate: () => followUp,
    horizon: () => null,
    horizonSetOn: () => null,
    doDate: () => null,
    doTime: () => null,
  );

  Item complete(DateTime now) =>
      copyWith(status: ItemStatus.done, completedAt: () => now);

  /// Undoes [complete]; the item returns to wherever it was planned.
  Item reopen() => copyWith(
    status: ItemStatus.active,
    completedAt: () => null,
    archived: false,
  );

  Item trash(DateTime now) =>
      copyWith(status: ItemStatus.trashed, trashedAt: () => now);

  /// Takes an item out of Trash to wherever its placement says it was:
  /// Waiting with a person, active with a date or horizon, otherwise Inbox
  /// to be decided again (FR-18).
  Item restoreFromTrash() => copyWith(
    status: switch (this) {
      Item(waitingOn: _?) => ItemStatus.waiting,
      Item(doDate: _?) || Item(horizon: _?) => ItemStatus.active,
      _ => ItemStatus.inbox,
    },
    trashedAt: () => null,
  );

  Item _activate({required WhenHorizon horizon, LocalDate? horizonSetOn}) =>
      copyWith(
        status: ItemStatus.active,
        horizon: () => horizon,
        horizonSetOn: () => horizonSetOn,
        doDate: () => null,
        doTime: () => null,
        waitingOn: () => null,
        followUpDate: () => null,
      );
}
