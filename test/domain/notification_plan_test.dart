import 'package:clearing/domain/app_settings.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/notification_plan.dart';
import 'package:clearing/domain/reminder.dart';
import 'package:clearing/domain/review_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 20, 9);
final today = LocalDate(2026, 10, 20);
const settings = AppSettings(
  notificationIntensity: NotificationIntensity.standard,
  reviewReminder: false,
);

Item item({
  String id = 'i1',
  ItemStatus status = ItemStatus.active,
  LocalDate? doDate,
  int? doTime,
  String? doneMeans,
}) => Item(
  id: id,
  title: 'Call dentist',
  status: status,
  doDate: doDate,
  doTime: doTime,
  doneMeans: doneMeans,
  createdAt: now,
  updatedAt: now,
);

Reminder offset(int minutes, {String id = 'r1', String itemId = 'i1'}) =>
    Reminder(id: id, itemId: itemId, offsetMinutes: minutes);

Reminder at(DateTime time, {String id = 'r1'}) =>
    Reminder(id: id, itemId: 'i1', fireAt: time);

List<DateTime> times(
  Iterable<(Item, Reminder)> reminders, {
  AppSettings settings = settings,
  DateTime? at,
}) => [
  for (final n in planNotifications(
    reminders,
    settings: settings,
    now: at ?? now,
  ))
    n.fireAt,
];

void main() {
  group('Reminder.fireTimeFor', () {
    test('counts back from the date and time', () {
      final i = item(doDate: today, doTime: 14 * 60);
      expect(offset(0).fireTimeFor(i), DateTime(2026, 10, 20, 14));
      expect(offset(60).fireTimeFor(i), DateTime(2026, 10, 20, 13));
      expect(offset(24 * 60).fireTimeFor(i), DateTime(2026, 10, 19, 14));
    });

    test('uses 9:00 for an item with a date but no time', () {
      final i = item(doDate: today);
      expect(offset(10).fireTimeFor(i), DateTime(2026, 10, 20, 8, 50));
    });

    test('a relative reminder needs a date', () {
      expect(offset(0).fireTimeFor(item()), isNull);
    });

    test('an absolute reminder ignores the date', () {
      final time = DateTime(2026, 10, 22, 18, 30);
      expect(at(time).fireTimeFor(item(doDate: today)), time);
    });

    test('a later snooze wins, an earlier one does not', () {
      final i = item(doDate: today, doTime: 10 * 60);
      final later = DateTime(2026, 10, 20, 11);
      final earlier = DateTime(2026, 10, 20, 9, 30);
      expect(
        offset(0).copyWith(snoozedUntil: () => later).fireTimeFor(i),
        later,
      );
      expect(
        offset(0).copyWith(snoozedUntil: () => earlier).fireTimeFor(i),
        DateTime(2026, 10, 20, 10),
      );
    });
  });

  group('planNotifications', () {
    final tomorrowNoon = item(doDate: today.addDays(1), doTime: 12 * 60);

    test('schedules future reminders in time order', () {
      expect(
        times([
          (tomorrowNoon, offset(60)),
          (tomorrowNoon, offset(0, id: 'r2')),
        ]),
        [DateTime(2026, 10, 21, 11), DateTime(2026, 10, 21, 12)],
      );
    });

    test('skips the past and anything beyond 14 days', () {
      final past = item(doDate: today, doTime: 8 * 60);
      final far = item(id: 'i2', doDate: today.addDays(15), doTime: 12 * 60);
      expect(
        times([(past, offset(0)), (far, offset(0, itemId: 'i2'))]),
        isEmpty,
      );
    });

    test('only active and waiting items notify', () {
      for (final status in ItemStatus.values) {
        final i = item(status: status, doDate: today, doTime: 12 * 60);
        final expected =
            status == ItemStatus.active || status == ItemStatus.waiting;
        expect(times([(i, offset(0))]), hasLength(expected ? 1 : 0));
      }
    });

    test('disabled reminders and intensity Off schedule nothing', () {
      expect(
        times([(tomorrowNoon, offset(0).copyWith(enabled: false))]),
        isEmpty,
      );
      expect(
        times(
          [(tomorrowNoon, offset(0))],
          settings: const AppSettings(
            notificationIntensity: NotificationIntensity.off,
          ),
        ),
        isEmpty,
      );
    });

    test('Gentle posts silently, Standard does not', () {
      List<bool> silent(NotificationIntensity intensity) => [
        for (final n in planNotifications(
          [(tomorrowNoon, offset(0))],
          settings: AppSettings(
            notificationIntensity: intensity,
            reviewReminder: false,
          ),
          now: now,
        ))
          n.silent,
      ];
      expect(silent(NotificationIntensity.gentle), [true]);
      expect(silent(NotificationIntensity.standard), [false]);
    });

    group('quiet hours (22:00–07:00)', () {
      test('defer a reminder that counts back into them', () {
        final early = item(doDate: today.addDays(1), doTime: 7 * 60 + 30);
        expect(times([(early, offset(60))]), [DateTime(2026, 10, 21, 7)]);
      });

      test('defer across midnight to the next morning', () {
        final i = item(doDate: today.addDays(1), doTime: 23 * 60);
        expect(times([(i, offset(24 * 60))]), [DateTime(2026, 10, 21, 7)]);
      });

      test('never move a reminder the user timed exactly', () {
        final late = item(doDate: today, doTime: 23 * 60);
        final custom = DateTime(2026, 10, 20, 22, 30);
        expect(times([(late, offset(0)), (late, at(custom, id: 'r2'))]), [
          custom,
          DateTime(2026, 10, 20, 23),
        ]);
      });

      test('two reminders deferred to the same minute notify once', () {
        final early = item(doDate: today.addDays(1), doTime: 6 * 60);
        expect(times([(early, offset(10)), (early, offset(60, id: 'r2'))]), [
          DateTime(2026, 10, 21, 7),
        ]);
      });

      test('equal start and end means no quiet hours', () {
        expect(
          const QuietHours(0, 0).contains(DateTime(2026, 1, 1, 3)),
          isFalse,
        );
      });

      test('can sit within one day', () {
        const lunch = QuietHours(12 * 60, 13 * 60);
        expect(lunch.contains(DateTime(2026, 1, 1, 12, 30)), isTrue);
        expect(lunch.contains(DateTime(2026, 1, 1, 13)), isFalse);
        expect(
          lunch.deferred(DateTime(2026, 1, 1, 12, 30)),
          DateTime(2026, 1, 1, 13),
        );
      });
    });

    test('payload names the item and reminder', () {
      final [n] = planNotifications(
        [
          (
            item(doDate: today, doTime: 12 * 60, doneMeans: 'booked'),
            offset(0),
          ),
        ],
        settings: settings,
        now: now,
      );
      expect(parsePayload(n.payload), (itemId: 'i1', reminderId: 'r1'));
      expect(n.body, 'Done means: booked');
      expect(parsePayload('not json'), isNull);
    });
  });

  group('weekly review reminder', () {
    test('comes at the chosen day and time', () {
      // Tuesday 09:00; default review is Sunday 18:00.
      expect(
        nextReviewAt(const AppSettings(), now),
        DateTime(2026, 10, 25, 18),
      );
      expect(
        nextReviewAt(
          const AppSettings(
            reviewWeekday: DateTime.tuesday,
            reviewTime: 9 * 60,
          ),
          now,
        ),
        DateTime(2026, 10, 27, 9),
        reason: 'exactly now has passed, so next week',
      );
      expect(
        nextReviewAt(
          const AppSettings(
            reviewWeekday: DateTime.tuesday,
            reviewTime: 20 * 60,
          ),
          now,
        ),
        DateTime(2026, 10, 20, 20),
      );
    });

    test('is planned unless turned off or notifications are off', () {
      List<PlannedNotification> plan(AppSettings s) =>
          planNotifications(const [], settings: s, now: now);
      expect(plan(const AppSettings()).single.isReview, isTrue);
      expect(plan(const AppSettings(reviewReminder: false)), isEmpty);
      expect(
        plan(
          const AppSettings(notificationIntensity: NotificationIntensity.off),
        ),
        isEmpty,
      );
    });
  });

  test('notification ids are stable 31-bit numbers', () {
    expect(notificationIdFor('abc'), notificationIdFor('abc'));
    expect(notificationIdFor('abc'), isNot(notificationIdFor('abd')));
    expect(notificationIdFor('0192f0a3-uuid'), inInclusiveRange(0, 0x7fffffff));
  });
}
