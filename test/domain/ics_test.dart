import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/ics.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime(2026, 10, 1);
  Item item(String id, {LocalDate? day, int? time, ItemStatus? status}) => Item(
    id: id,
    title: 'Pay rent; and, bills',
    status: status ?? ItemStatus.active,
    doDate: day,
    doTime: time,
    createdAt: created,
    updatedAt: created,
  );

  test('dated active items become events', () {
    final ics = upcomingCalendar(
      [
        item('a', day: LocalDate(2026, 11, 1), time: 9 * 60),
        item('b', day: LocalDate(2026, 11, 2)),
        item('c'),
        item('d', day: LocalDate(2026, 11, 3), status: ItemStatus.someday),
      ],
      from: LocalDate(2026, 10, 21),
      now: DateTime.utc(2026, 10, 21, 9),
    );
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('DTSTART:20261101T090000'));
    expect(ics, contains('DTSTART;VALUE=DATE:20261102'));
    expect(ics, contains(r'SUMMARY:Pay rent\; and\, bills'));
    expect('BEGIN:VEVENT'.allMatches(ics), hasLength(2));
  });
}
