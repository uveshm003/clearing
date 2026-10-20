import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults match the PRD', () {
    const s = AppSettings();
    expect(s.weekStart, DateTime.monday);
    expect(s.reviewWeekday, DateTime.sunday);
    expect(s.reviewTime, 18 * 60);
    expect(s.mustDoCap, 3);
    expect(s.notificationIntensity, NotificationIntensity.gentle);
    expect((s.quietHoursStart, s.quietHoursEnd), (22 * 60, 7 * 60));
    expect(s.autoArchiveDays, 7);
    expect(s.exportReminderDays, 30);
  });

  test('round-trips through JSON', () {
    final s = const AppSettings().copyWith(
      mustDoCap: 5,
      theme: ThemePreference.dark,
      exportReminderDays: () => null,
      notificationIntensity: NotificationIntensity.off,
    );
    expect(AppSettings.fromJson(s.toJson()), s);
  });

  test('falls back to defaults for missing or malformed values', () {
    final s = AppSettings.fromJson({
      'mustDoCap': 99,
      'theme': 'neon',
      'weekStart': 'monday',
    });
    expect(s.mustDoCap, AppSettings.maxMustDoCap);
    expect(s.theme, ThemePreference.system);
    expect(s.weekStart, DateTime.monday);
  });
}
