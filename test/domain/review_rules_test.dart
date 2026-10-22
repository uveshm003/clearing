import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:clearing/domain/review_rules.dart';
import 'package:clearing/domain/review_session.dart';
import 'package:flutter_test/flutter_test.dart';

final today = LocalDate(2026, 10, 25);
final now = DateTime(2026, 10, 25, 18);

Item item(
  String id, {
  ItemStatus status = ItemStatus.active,
  WhenHorizon? horizon,
  LocalDate? horizonSetOn,
  LocalDate? doDate,
}) => Item(
  id: id,
  title: id,
  status: status,
  horizon: horizon,
  horizonSetOn: horizonSetOn,
  doDate: doDate,
  createdAt: now,
  updatedAt: now,
);

void main() {
  test('last week’s open items: This week and carried over', () {
    final items = [
      item('week', horizon: WhenHorizon.thisWeek),
      item('carried', doDate: today.addDays(-2)),
      item(
        'stale today',
        horizon: WhenHorizon.today,
        horizonSetOn: today.addDays(-1),
      ),
      item('fresh today', horizon: WhenHorizon.today, horizonSetOn: today),
      item('dated today', doDate: today),
      item('idea', status: ItemStatus.someday),
    ];
    expect(lastWeekOpen(items, today).map((i) => i.id).toSet(), {
      'week',
      'carried',
      'stale today',
    });
  });

  test('next seven days excludes today and beyond a week', () {
    final items = [
      item('today', doDate: today),
      item('d3', doDate: today.addDays(3)),
      item('d1', doDate: today.addDays(1)),
      item('d7', doDate: today.addDays(7)),
      item('d8', doDate: today.addDays(8)),
    ];
    expect(nextSevenDays(items, today).map((i) => i.id), ['d1', 'd3', 'd7']);
  });

  group('canResume', () {
    ReviewSession session({DateTime? started, DateTime? completed}) =>
        ReviewSession(
          id: 's',
          kind: ReviewKind.weekly,
          startedAt: started ?? now.subtract(const Duration(days: 1)),
          completedAt: completed,
          step: 3,
        );

    test('an unfinished review from this week', () {
      expect(canResume(session(), now), isTrue);
    });

    test('not a finished one, an old one, or none', () {
      expect(canResume(session(completed: now), now), isFalse);
      expect(
        canResume(session(started: now.subtract(const Duration(days: 8))), now),
        isFalse,
      );
      expect(canResume(null, now), isFalse);
    });
  });

  test('sessions keep step and tallies through JSON', () {
    final s = ReviewSession(
      id: 's',
      kind: ReviewKind.weekly,
      startedAt: now,
    ).tally('cleared').tally('cleared').tally('planned').copyWith(step: 2);
    final back = ReviewSession.fromRow(
      id: s.id,
      kind: s.kind,
      startedAt: s.startedAt,
      json: s.toJson(),
    );
    expect(back, s);
    expect(back.count('cleared'), 2);
    expect(back.count('skipped'), 0);
  });
}
