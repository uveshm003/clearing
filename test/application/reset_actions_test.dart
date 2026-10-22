import 'package:clearing/application/item_actions.dart';
import 'package:clearing/application/reset_actions.dart';
import 'package:clearing/data/db/database.dart';
import 'package:clearing/data/item_repository.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/reset_rules.dart';
import 'package:clearing/domain/today_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository items;
  late ItemActions actions;
  late ResetActions reset;
  final now = DateTime(2026, 10, 20, 9);
  final today = LocalDate(2026, 10, 20);

  setUp(() {
    db = memoryDatabase(now: () => now);
    items = ItemRepository(db, now: () => now);
    actions = ItemActions(items, now: () => now);
    reset = ResetActions(actions, items, now: () => now);
  });
  tearDown(() => db.close());

  test('candidates leave out later dates, Waiting and Someday', () async {
    final [inbox, later, waiting, idea, carried] = await actions.capture(
      'A\nB\nC\nD\nE',
    );
    final l = await actions.planOnDate(later, today.addDays(3));
    final w = await actions.waitFor(waiting, 'Sam');
    final s = await actions.moveToSomeday(idea);
    final c = await actions.planOnDate(carried, today.addDays(-2));
    expect(isResetCandidate(inbox, today), isTrue);
    expect(isResetCandidate(c, today), isTrue);
    for (final item in [l, w, s]) {
      expect(isResetCandidate(item, today), isFalse);
    }
  });

  test('chosen items become the only must-dos on Today', () async {
    final [a, b, carried] = await actions.capture('Pay rent\nOld must\nLate');
    final old = await actions.save(
      (await actions.planToday(b)).copyWith(mustDo: true),
    );
    final late = await actions.planOnDate(
      carried,
      today.addDays(-1),
      time: 10 * 60,
    );
    await reset.mustHappenToday([a, old, late], {a.id, late.id});

    final pay = (await items.getItem(a.id))!;
    expect(pay.mustDo, isTrue);
    expect(isOnToday(pay, today), isTrue);
    expect((await items.getItem(b.id))!.mustDo, isFalse);
    final moved = (await items.getItem(late.id))!;
    expect(moved.doDate, today, reason: 'no longer carried over');
    expect(moved.doTime, 10 * 60);
  });

  test('this week and let go', () async {
    final [a, b, c] = await actions.capture('Week\nIdea\nGone');
    await reset.thisWeek([a, b, c], {a.id});
    await reset.letGo([b], delete: false);
    await reset.letGo([c], delete: true);
    expect(isThisWeek((await items.getItem(a.id))!), isTrue);
    expect((await items.getItem(b.id))!.status, ItemStatus.someday);
    expect((await items.getItem(c.id))!.status, ItemStatus.trashed);
  });

  test('the tiny first step goes before existing steps', () async {
    final [a] = await actions.capture('Taxes');
    await items.addSubtask(a.id, 'Fill in form');
    await reset.addFirstStep(a, 'Find last year’s letter');
    expect((await items.subtasksOf(a.id)).map((s) => s.title), [
      'Find last year’s letter',
      'Fill in form',
    ]);
  });

  test('let-go defaults spare dated and repeating items', () async {
    final [a, b] = await actions.capture('Loose\nDentist');
    final dated = await actions.planOnDate(b, today);
    expect(letGoByDefault(a), isTrue);
    expect(letGoByDefault(dated), isFalse);
  });
}
