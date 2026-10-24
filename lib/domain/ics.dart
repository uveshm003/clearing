import 'enums.dart';
import 'item.dart';
import 'local_date.dart';

/// Upcoming as an iCalendar file (§5.10), one way only: for importing into
/// any calendar app by hand. Times are "floating" local times, so 9:00
/// stays 9:00 wherever the calendar is.
String upcomingCalendar(
  Iterable<Item> items, {
  required LocalDate from,
  required DateTime now,
  int days = 90,
}) {
  final until = from.addDays(days);
  String two(int n) => n.toString().padLeft(2, '0');
  String date(LocalDate d) => '${d.year}${two(d.month)}${two(d.day)}';
  String stamp(DateTime t) {
    final u = t.toUtc();
    return '${u.year}${two(u.month)}${two(u.day)}T'
        '${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }

  /// RFC 5545 text: escape \, ; , and newlines.
  String text(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');

  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Clearing//Upcoming//EN',
    'CALSCALE:GREGORIAN',
  ];
  for (final item in items) {
    final day = item.doDate;
    if (item.status != ItemStatus.active || day == null) continue;
    if (day.isBefore(from) || day.isAfter(until)) continue;
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${item.id}@clearing',
      'DTSTAMP:${stamp(now)}',
      if (item.doTime case final minutes?) ...[
        'DTSTART:${date(day)}T${two(minutes ~/ 60)}${two(minutes % 60)}00',
        'DURATION:PT${item.effort ?? 30}M',
      ] else ...[
        'DTSTART;VALUE=DATE:${date(day)}',
        'DTEND;VALUE=DATE:${date(day.addDays(1))}',
      ],
      'SUMMARY:${text(item.title)}',
      if (item.doneMeans case final means?) 'DESCRIPTION:${text(means)}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  // Lines end in CRLF, as the format requires.
  return '${lines.join('\r\n')}\r\n';
}
