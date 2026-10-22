import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/recurrence.dart';
import 'package:clearing/domain/repeat_series.dart';
import 'package:flutter_test/flutter_test.dart';

LocalDate d(String iso) => LocalDate.parse(iso);

RepeatSeries series(
  RepeatFrequency freq, {
  required String start,
  int interval = 1,
  Set<int> weekdays = const {},
  int? monthDay,
  String? end,
  int? maxCount,
}) => RepeatSeries(
  id: 's',
  freq: freq,
  interval: interval,
  weekdays: weekdays,
  monthDay: monthDay,
  startDate: d(start),
  endDate: end == null ? null : d(end),
  maxCount: maxCount,
  onMissed: OnMissed.carryOver,
  template: const SeriesTemplate(title: 'x'),
);

List<String> first(RepeatSeries s, int n) => [
  for (final date in s.occurrences.take(n)) date.toIso(),
];

void main() {
  group('occurrences', () {
    final cases = <(String, RepeatSeries, List<String>)>[
      (
        'daily',
        series(RepeatFrequency.daily, start: '2026-10-30'),
        ['2026-10-30', '2026-10-31', '2026-11-01'],
      ),
      (
        'every 3 days',
        series(RepeatFrequency.daily, start: '2026-02-27', interval: 3),
        ['2026-02-27', '2026-03-02', '2026-03-05'],
      ),
      (
        'weekly defaults to the start weekday',
        series(RepeatFrequency.weekly, start: '2026-10-21'), // a Wednesday
        ['2026-10-21', '2026-10-28', '2026-11-04'],
      ),
      (
        'weekly on Mon and Thu, starting mid-week',
        series(
          RepeatFrequency.weekly,
          start: '2026-10-21',
          weekdays: {DateTime.monday, DateTime.thursday},
        ),
        ['2026-10-22', '2026-10-26', '2026-10-29', '2026-11-02'],
      ),
      (
        'every 2 weeks on Sunday, counted from the start week',
        series(
          RepeatFrequency.weekly,
          start: '2026-10-19',
          interval: 2,
          weekdays: {DateTime.sunday},
        ),
        ['2026-10-25', '2026-11-08', '2026-11-22'],
      ),
      (
        'monthly on the 31st clamps to month end',
        series(RepeatFrequency.monthly, start: '2026-01-31'),
        ['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30'],
      ),
      (
        'monthly on the 29th in a leap year',
        series(RepeatFrequency.monthly, start: '2028-01-29'),
        ['2028-01-29', '2028-02-29', '2028-03-29'],
      ),
      (
        'monthly day before the start day begins next month',
        series(RepeatFrequency.monthly, start: '2026-10-21', monthDay: 1),
        ['2026-11-01', '2026-12-01', '2027-01-01'],
      ),
      (
        'every 5 months crosses years',
        series(RepeatFrequency.monthly, start: '2026-10-15', interval: 5),
        ['2026-10-15', '2027-03-15', '2027-08-15', '2028-01-15'],
      ),
      (
        'daily over a leap day',
        series(RepeatFrequency.daily, start: '2028-02-28'),
        ['2028-02-28', '2028-02-29', '2028-03-01'],
      ),
    ];
    for (final (name, s, expected) in cases) {
      test(name, () => expect(first(s, expected.length), expected));
    }

    test('stops at the end date, inclusive', () {
      final s = series(
        RepeatFrequency.daily,
        start: '2026-10-20',
        end: '2026-10-22',
      );
      expect(first(s, 10), ['2026-10-20', '2026-10-21', '2026-10-22']);
    });

    test('stops after the maximum count', () {
      final s = series(
        RepeatFrequency.weekly,
        start: '2026-10-20',
        maxCount: 2,
      );
      expect(first(s, 10), ['2026-10-20', '2026-10-27']);
    });
  });

  group('nextOccurrence', () {
    final daily = series(RepeatFrequency.daily, start: '2026-10-01');
    final rent = series(RepeatFrequency.monthly, start: '2026-01-01');

    test('skips past dates, so missed days never pile up', () {
      expect(daily.nextOccurrence(onOrAfter: d('2026-10-20')), d('2026-10-20'));
      expect(rent.nextOccurrence(onOrAfter: d('2026-10-03')), d('2026-11-01'));
    });

    test('is strictly after the last occurrence', () {
      expect(
        daily.nextOccurrence(
          onOrAfter: d('2026-10-20'),
          after: d('2026-10-20'),
        ),
        d('2026-10-21'),
      );
      // Completing tomorrow's occurrence early moves on to the day after.
      expect(
        daily.nextOccurrence(
          onOrAfter: d('2026-10-20'),
          after: d('2026-10-21'),
        ),
        d('2026-10-22'),
      );
    });

    test('a carried-over occurrence leads to today, not tomorrow', () {
      expect(
        daily.nextOccurrence(
          onOrAfter: d('2026-10-20'),
          after: d('2026-10-19'),
        ),
        d('2026-10-20'),
      );
    });

    test('is null once the series has ended', () {
      final ended = series(
        RepeatFrequency.daily,
        start: '2026-10-01',
        end: '2026-10-10',
      );
      expect(ended.nextOccurrence(onOrAfter: d('2026-10-11')), isNull);

      final counted = series(
        RepeatFrequency.daily,
        start: '2026-10-01',
        maxCount: 3,
      );
      expect(
        counted.nextOccurrence(
          onOrAfter: d('2026-10-01'),
          after: d('2026-10-03'),
        ),
        isNull,
      );
    });
  });

  group('SeriesTemplate JSON', () {
    test('round-trips', () {
      const template = SeriesTemplate(
        title: 'Water plants',
        listId: 'l1',
        doTime: 8 * 60,
        reminderOffsets: [0, 60],
        doneMeans: 'soil is damp',
        subtasks: ['balcony', 'kitchen'],
      );
      expect(SeriesTemplate.fromJson(template.toJson()), template);
    });

    test('tolerates malformed values', () {
      final template = SeriesTemplate.fromJson({
        'title': 7,
        'reminderOffsets': [10, 'x'],
        'subtasks': 'nope',
      });
      expect(template.title, '');
      expect(template.reminderOffsets, [10]);
      expect(template.subtasks, isEmpty);
    });
  });
}
