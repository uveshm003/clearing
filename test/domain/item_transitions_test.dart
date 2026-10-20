import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/item_transitions.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

final today = LocalDate(2026, 10, 20);

final inbox = Item(
  id: 'a',
  title: 'Renew passport',
  status: ItemStatus.inbox,
  createdAt: DateTime(2026, 10, 1),
  updatedAt: DateTime(2026, 10, 1),
);

void main() {
  test('planToday records when the horizon was set', () {
    final item = inbox.planToday(today);
    expect(item.status, ItemStatus.active);
    expect(item.when, When.today);
    expect(item.horizonSetOn, today);
  });

  test('planOnDate clears any horizon so the date wins', () {
    final item = inbox
        .planThisWeek(today)
        .planOnDate(today.addDays(3), time: 600);
    expect(item.when, When.onDate);
    expect(item.horizon, isNull);
    expect((item.doDate, item.doTime), (today.addDays(3), 600));
  });

  test('a horizon clears any date', () {
    final item = inbox.planOnDate(today, time: 600).planAnytime();
    expect(item.when, When.anytime);
    expect((item.doDate, item.doTime), (null, null));
  });

  test('snoozeToTomorrow keeps the time only for dated items', () {
    expect(
      inbox.planOnDate(today, time: 540).snoozeToTomorrow(today).doTime,
      540,
    );
    final fromHorizon = inbox.planToday(today).snoozeToTomorrow(today);
    expect((fromHorizon.doDate, fromHorizon.doTime), (today.addDays(1), null));
  });

  test('Someday drops dates and must-do so it never shows on Today', () {
    final item = inbox
        .planOnDate(today, time: 600)
        .copyWith(mustDo: true)
        .moveToSomeday();
    expect(item.status, ItemStatus.someday);
    expect(item.mustDo, isFalse);
    expect((item.doDate, item.doTime, item.horizon), (null, null, null));
  });

  test('waitFor records who and when to follow up', () {
    final item = inbox
        .planToday(today)
        .waitFor('  Sam ', followUp: today.addDays(2));
    expect(item.status, ItemStatus.waiting);
    expect(item.waitingOn, 'Sam');
    expect(item.followUpDate, today.addDays(2));
    expect(item.horizon, isNull);
  });

  test('planning a waiting item takes it back', () {
    final item = inbox.waitFor('Sam').planToday(today);
    expect(item.status, ItemStatus.active);
    expect(item.waitingOn, isNull);
  });

  test('complete and reopen', () {
    final now = DateTime(2026, 10, 20, 12);
    final done = inbox.planToday(today).complete(now);
    expect((done.status, done.completedAt), (ItemStatus.done, now));
    final reopened = done.reopen();
    expect((reopened.status, reopened.completedAt), (ItemStatus.active, null));
    expect(reopened.when, When.today);
  });

  test('trash records when, for the 30-day purge', () {
    final now = DateTime(2026, 10, 20, 12);
    final item = inbox.trash(now);
    expect((item.status, item.trashedAt), (ItemStatus.trashed, now));
  });
}
