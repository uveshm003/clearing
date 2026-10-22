import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalises overflowing days and months', () {
    expect(LocalDate(2026, 1, 32), LocalDate(2026, 2, 1));
    expect(LocalDate(2026, 13, 1), LocalDate(2027, 1, 1));
    expect(LocalDate(2026, 3, 0), LocalDate(2026, 2, 28));
  });

  test('handles leap years', () {
    expect(LocalDate(2028, 2, 28).addDays(1), LocalDate(2028, 2, 29));
    expect(LocalDate(2026, 2, 28).addDays(1), LocalDate(2026, 3, 1));
  });

  test('round-trips ISO text', () {
    final date = LocalDate(2026, 10, 5);
    expect(date.toIso(), '2026-10-05');
    expect(LocalDate.parse('2026-10-05'), date);
    expect(() => LocalDate.parse('2026/10/05'), throwsFormatException);
  });

  test('compares and measures distance', () {
    final a = LocalDate(2026, 10, 20);
    final b = LocalDate(2026, 11, 2);
    expect(a.isBefore(b), isTrue);
    expect(b.isAfter(a), isTrue);
    expect(a.daysUntil(b), 13);
    expect(b.daysUntil(a), -13);
  });

  test('daysUntil ignores daylight-saving shifts', () {
    // 25 Oct 2026 is a DST change in Europe; dates are zone-free.
    expect(LocalDate(2026, 10, 24).daysUntil(LocalDate(2026, 10, 26)), 2);
  });

  test('startOfWeek honours the configured first day', () {
    final tuesday = LocalDate(2026, 10, 20);
    expect(tuesday.weekday, DateTime.tuesday);
    expect(tuesday.startOfWeek(DateTime.monday), LocalDate(2026, 10, 19));
    expect(tuesday.startOfWeek(DateTime.sunday), LocalDate(2026, 10, 18));
    expect(tuesday.startOfWeek(DateTime.tuesday), tuesday);
  });
}
