import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/today_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final today = LocalDate(2026, 10, 20);
final yesterday = today.addDays(-1);
final tomorrow = today.addDays(1);

var _seq = 0;

Item item({
  String? title,
  ItemStatus status = ItemStatus.active,
  WhenHorizon? horizon,
  LocalDate? horizonSetOn,
  LocalDate? doDate,
  int? doTime,
  bool mustDo = false,
  double sortOrder = 0,
}) {
  final n = _seq++;
  final created = DateTime(2026, 10, 1).add(Duration(minutes: n));
  return Item(
    id: 'id$n',
    title: title ?? 'item $n',
    status: status,
    horizon: horizon,
    horizonSetOn: horizonSetOn,
    doDate: doDate,
    doTime: doTime,
    mustDo: mustDo,
    sortOrder: sortOrder,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  group('isOnToday', () {
    test('includes Today horizon and dates on or before today', () {
      expect(isOnToday(item(horizon: WhenHorizon.today), today), isTrue);
      expect(isOnToday(item(doDate: today), today), isTrue);
      expect(isOnToday(item(doDate: yesterday), today), isTrue);
    });

    test('excludes future dates, other horizons and non-active items', () {
      expect(isOnToday(item(doDate: tomorrow), today), isFalse);
      expect(isOnToday(item(horizon: WhenHorizon.thisWeek), today), isFalse);
      expect(isOnToday(item(horizon: WhenHorizon.anytime), today), isFalse);
      for (final status in ItemStatus.values.where(
        (s) => s != ItemStatus.active,
      )) {
        expect(
          isOnToday(item(status: status, doDate: today), today),
          isFalse,
          reason: '$status must never appear on Today',
        );
      }
    });

    test('a date wins over a horizon', () {
      final i = item(horizon: WhenHorizon.today, doDate: tomorrow);
      expect(i.when, When.onDate);
      expect(isOnToday(i, today), isFalse);
    });
  });

  group('buildTodayView', () {
    test('splits items into must-do, also today and carried over', () {
      final must = item(doDate: today, mustDo: true);
      final mustCarried = item(doDate: yesterday, mustDo: true);
      final also = item(horizon: WhenHorizon.today, horizonSetOn: today);
      final carriedDate = item(doDate: yesterday);
      final carriedHorizon = item(
        horizon: WhenHorizon.today,
        horizonSetOn: yesterday,
      );
      final week = item(horizon: WhenHorizon.thisWeek);
      final future = item(doDate: tomorrow);
      final someday = item(status: ItemStatus.someday);

      final view = buildTodayView([
        must,
        mustCarried,
        also,
        carriedDate,
        carriedHorizon,
        week,
        future,
        someday,
      ], today);

      expect(view.mustDo, unorderedEquals([must, mustCarried]));
      expect(view.alsoToday, [also]);
      expect(view.carriedOver, unorderedEquals([carriedDate, carriedHorizon]));
      expect(view.thisWeekCount, 1);
      expect(view.isEmpty, isFalse);
    });

    test('dated This-week items are not counted in the week row', () {
      final view = buildTodayView([
        item(horizon: WhenHorizon.thisWeek, doDate: tomorrow),
      ], today);
      expect(view.thisWeekCount, 0);
    });

    test('orders timed items first by time, then manual order', () {
      final late = item(doDate: today, doTime: 17 * 60);
      final early = item(doDate: today, doTime: 9 * 60);
      final untimedB = item(horizon: WhenHorizon.today, sortOrder: 2);
      final untimedA = item(horizon: WhenHorizon.today, sortOrder: 1);
      final view = buildTodayView([untimedB, late, untimedA, early], today);
      expect(view.alsoToday, [early, late, untimedA, untimedB]);
    });

    test('empty input gives an empty view', () {
      expect(buildTodayView(const [], today).isEmpty, isTrue);
    });
  });

  group('checkMustDoCap', () {
    test('allows flagging below the cap', () {
      final items = [item(doDate: today, mustDo: true)];
      expect(checkMustDoCap(items, today, 3), isA<MustDoAllowed>());
    });

    test('asks to swap at the cap instead of refusing silently', () {
      final current = [
        for (var i = 0; i < 3; i++) item(doDate: today, mustDo: true),
      ];
      final notToday = item(doDate: tomorrow, mustDo: true);
      final result = checkMustDoCap([...current, notToday], today, 3);
      expect(result, isA<MustDoNeedsSwap>());
      expect((result as MustDoNeedsSwap).current, unorderedEquals(current));
    });
  });

  group('weeks', () {
    test('weekdays start on the chosen day', () {
      expect(weekdaysFrom(DateTime.monday), [1, 2, 3, 4, 5, 6, 7]);
      expect(weekdaysFrom(DateTime.sunday), [7, 1, 2, 3, 4, 5, 6]);
      expect(weekdaysFrom(DateTime.saturday), [6, 7, 1, 2, 3, 4, 5]);
    });

    test('This week items from an earlier week are told apart', () {
      // Tuesday 20 Oct 2026.
      final lastWeek = item(
        horizon: WhenHorizon.thisWeek,
        horizonSetOn: LocalDate(2026, 10, 18),
      );
      final thisWeek = item(
        horizon: WhenHorizon.thisWeek,
        horizonSetOn: LocalDate(2026, 10, 19),
      );
      expect(isFromEarlierWeek(lastWeek, today, DateTime.monday), isTrue);
      expect(isFromEarlierWeek(thisWeek, today, DateTime.monday), isFalse);
      // With Sunday starts, Sunday 18 Oct is this week.
      expect(isFromEarlierWeek(lastWeek, today, DateTime.sunday), isFalse);
    });
  });
}
