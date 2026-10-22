import 'package:clearing/domain/calendar_rules.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:flutter_test/flutter_test.dart';

final today = LocalDate(2026, 10, 21); // Wednesday
final monday = LocalDate(2026, 10, 19);
final now = DateTime(2026, 10, 21, 9);

Item item(
  String id, {
  ItemStatus status = ItemStatus.active,
  LocalDate? doDate,
  int? doTime,
  WhenHorizon? horizon,
  LocalDate? occurrenceDate,
}) => Item(
  id: id,
  title: id,
  status: status,
  doDate: doDate,
  doTime: doTime,
  horizon: horizon,
  occurrenceDate: occurrenceDate,
  createdAt: now,
  updatedAt: now,
);

void main() {
  test('the week timeline places items on their days', () {
    final week = weekTimeline(
      [
        item('late', doDate: today, doTime: 18 * 60),
        item('early', doDate: today, doTime: 8 * 60),
        item('untimed', doDate: today),
        item('today', horizon: WhenHorizon.today),
        item('fri', doDate: LocalDate(2026, 10, 23)),
        item('next week', doDate: LocalDate(2026, 10, 26)),
        item('any', horizon: WhenHorizon.thisWeek),
        item('idea', status: ItemStatus.someday),
      ],
      weekStart: monday,
      today: today,
    );
    expect(week.days, hasLength(7));
    expect(week.days[2].items.map((i) => i.id), [
      'early',
      'late',
      'untimed',
      'today',
    ]);
    expect(week.days[4].items.map((i) => i.id), ['fri']);
    expect(week.anyDay.map((i) => i.id), ['any']);
    final all = [for (final d in week.days) ...d.items.map((i) => i.id)];
    expect(all, isNot(contains('next week')));
  });

  test('"any day" only belongs to the current week', () {
    final next = weekTimeline(
      [item('any', horizon: WhenHorizon.thisWeek)],
      weekStart: monday.addDays(7),
      today: today,
    );
    expect(next.anyDay, isEmpty);
  });

  test('the series calendar marks past, open and planned dates', () {
    final series = RepeatSeries(
      id: 's',
      freq: RepeatFrequency.weekly,
      weekdays: const {DateTime.monday, DateTime.wednesday},
      startDate: LocalDate(2026, 10, 12),
      onMissed: OnMissed.skip,
      template: const SeriesTemplate(title: 'Gym'),
    );
    final marks = seriesCalendar(
      series,
      [
        item(
          'a',
          status: ItemStatus.done,
          occurrenceDate: LocalDate(2026, 10, 12),
        ),
        item(
          'b',
          status: ItemStatus.trashed,
          occurrenceDate: LocalDate(2026, 10, 14),
        ),
        item(
          'c',
          status: ItemStatus.done,
          occurrenceDate: LocalDate(2026, 10, 19),
        ),
        item('d', occurrenceDate: today),
      ],
      month: today,
      today: today,
    );
    expect(marks[LocalDate(2026, 10, 12)], OccurrenceMark.done);
    expect(marks[LocalDate(2026, 10, 14)], OccurrenceMark.skipped);
    expect(marks[today], OccurrenceMark.open);
    expect(marks[LocalDate(2026, 10, 26)], OccurrenceMark.planned);
    expect(marks[LocalDate(2026, 10, 28)], OccurrenceMark.planned);
    expect(marks.keys.where((d) => d.month != 10), isEmpty);
  });

  test('after-completion series show no planned dates', () {
    final series = RepeatSeries(
      id: 's',
      freq: RepeatFrequency.weekly,
      interval: 6,
      startDate: LocalDate(2026, 10, 1),
      mode: RepeatMode.afterCompletion,
      onMissed: OnMissed.carryOver,
      template: const SeriesTemplate(title: 'Haircut'),
    );
    final marks = seriesCalendar(
      series,
      [item('open', occurrenceDate: LocalDate(2026, 10, 30))],
      month: today,
      today: today,
    );
    expect(marks, {LocalDate(2026, 10, 30): OccurrenceMark.open});
  });
}
