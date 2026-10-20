import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/item_transitions.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/upcoming_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final today = LocalDate(2026, 10, 20);
var _n = 0;

Item make(String title) => Item(
  id: '${_n++}',
  title: title,
  status: ItemStatus.inbox,
  createdAt: DateTime(2026, 10, 1).add(Duration(minutes: _n)),
  updatedAt: DateTime(2026, 10, 1),
);

void main() {
  test('groups dated items after today within 30 days by day', () {
    final tomorrowLate = make('late').planOnDate(today.addDays(1), time: 1000);
    final tomorrowEarly = make('early').planOnDate(today.addDays(1), time: 500);
    final inAWeek = make('week').planOnDate(today.addDays(7));
    final lastDay = make('edge').planOnDate(today.addDays(upcomingDays));
    final tooFar = make('far').planOnDate(today.addDays(upcomingDays + 1));
    final dueToday = make('today').planOnDate(today);
    final someday = make('idea').moveToSomeday();

    final view = buildUpcoming([
      inAWeek,
      tomorrowLate,
      tooFar,
      tomorrowEarly,
      dueToday,
      lastDay,
      someday,
    ], today);

    expect(view.days.map((d) => d.$1), [
      today.addDays(1),
      today.addDays(7),
      today.addDays(upcomingDays),
    ]);
    expect(view.days.first.$2, [tomorrowEarly, tomorrowLate]);
    expect(view.waiting, isEmpty);
  });

  test('lists waiting items by follow-up date, undated last', () {
    final noDate = make('a').waitFor('Ann');
    final later = make('b').waitFor('Bo', followUp: today.addDays(5));
    final sooner = make('c').waitFor('Cy', followUp: today.addDays(1));
    final view = buildUpcoming([noDate, later, sooner], today);
    expect(view.waiting, [sooner, later, noDate]);
  });
}
