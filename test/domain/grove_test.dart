import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/field_notes.dart';
import 'package:clearing/domain/grove.dart';
import 'package:clearing/domain/insights.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

ClosedThing thing(String id, DateTime created, DateTime completed) =>
    ClosedThing(id: id, title: id, createdAt: created, completedAt: completed);

void main() {
  group('seasons', () {
    test('northern', () {
      expect(
        seasonOf(LocalDate(2026, 10, 21), Hemisphere.north).season,
        Season.autumn,
      );
      expect(
        seasonOf(LocalDate(2027, 1, 5), Hemisphere.north).season,
        Season.winter,
      );
      final winter = seasonOf(LocalDate(2027, 1, 5), Hemisphere.north);
      expect(winter.start, LocalDate(2026, 12, 1));
      expect(winter.end, LocalDate(2027, 2, 28));
    });

    test('southern is six months on', () {
      expect(
        seasonOf(LocalDate(2026, 10, 21), Hemisphere.south).season,
        Season.spring,
      );
      expect(
        seasonOf(LocalDate(2026, 7, 1), Hemisphere.south).season,
        Season.winter,
      );
    });

    test('previous walks back a season', () {
      final autumn = seasonOf(LocalDate(2026, 10, 21), Hemisphere.north);
      expect(autumn.previous.season, Season.summer);
      expect(autumn.previous.start, LocalDate(2026, 6, 1));
      final south = seasonOf(LocalDate(2026, 10, 21), Hemisphere.south);
      expect(south.previous.season, Season.winter);
    });
  });

  group('buildGrove', () {
    final season = seasonOf(LocalDate(2026, 10, 21), Hemisphere.north);

    test('empty with nothing done', () {
      expect(buildGrove(const GroveInputs(), season).isEmpty, isTrue);
    });

    test('cairns per week, wildflowers for old tabs', () {
      final grove = buildGrove(
        GroveInputs(
          closed: [
            thing('a', DateTime(2026, 10, 19), DateTime(2026, 10, 19, 9)),
            thing('b', DateTime(2026, 10, 1), DateTime(2026, 10, 20, 9)),
            thing('c', DateTime(2026, 9, 1), DateTime(2026, 9, 2, 9)),
            // Last season: not here.
            thing('d', DateTime(2026, 8, 1), DateTime(2026, 8, 2, 9)),
          ],
        ),
        season,
      );
      expect(grove.closed, 3);
      expect(grove.count(GroveKind.cairn), 2);
      expect(grove.count(GroveKind.wildflower), 1);
      expect(grove.oldTabs, 1);
      final cairn = grove.elements.firstWhere(
        (e) => e.kind == GroveKind.cairn && e.date == LocalDate(2026, 10, 19),
      );
      expect(cairn.count, 2);
    });

    test('trees grow with later reviews; earlier ones stay standing', () {
      final reviews = [
        DateTime(2026, 7, 5),
        for (var i = 0; i < 7; i++) DateTime(2026, 9, 6 + i * 7),
      ];
      final grove = buildGrove(GroveInputs(reviews: reviews), season);
      final trees = grove.elements
          .where((e) => e.kind == GroveKind.tree)
          .toList();
      expect(trees, hasLength(7));
      expect(trees.first.growth, 2);
      expect(trees.last.growth, 0);
      expect(grove.count(GroveKind.oldTree), 1);
    });

    test('nothing is lost: a later season keeps every tree', () {
      final reviews = [DateTime(2026, 10, 4), DateTime(2026, 10, 11)];
      final autumn = buildGrove(GroveInputs(reviews: reviews), season);
      final winter = buildGrove(
        GroveInputs(reviews: reviews),
        season.previous.previous.previous,
      );
      expect(autumn.count(GroveKind.tree), 2);
      // Seasons before the reviews have none; seasons after keep them all.
      expect(winter.count(GroveKind.tree) + winter.count(GroveKind.oldTree), 0);
      final next = seasonOf(LocalDate(2027, 1, 10), Hemisphere.north);
      expect(
        buildGrove(
          GroveInputs(reviews: reviews),
          next,
        ).count(GroveKind.oldTree),
        2,
      );
    });

    test('stream and bench stay once there', () {
      final grove = buildGrove(
        GroveInputs(resets: [DateTime(2026, 3, 1)], backedUp: true),
        season,
      );
      expect(grove.count(GroveKind.stream), 1);
      expect(grove.count(GroveKind.bench), 1);
    });

    test('totals earn variants', () {
      final totals = GroveTotals(
        closed: 100,
        reviews: 10,
        oldTabs: 25,
        pastSeasons: 1,
      );
      expect(
        totals.earned,
        GladeVariant.values.toSet()..remove(GladeVariant.glade),
      );
      expect(const GroveTotals().earned, isEmpty);
    });
  });

  test('four seasons of reviews, at any pace', () {
    expect(
      reviewedFourSeasons([
        DateTime(2026, 1, 1),
        DateTime(2026, 4, 1),
        DateTime(2026, 7, 1),
      ], Hemisphere.north),
      isFalse,
    );
    expect(
      reviewedFourSeasons([
        DateTime(2026, 1, 1),
        DateTime(2026, 4, 1),
        DateTime(2026, 7, 1),
        DateTime(2026, 10, 1),
      ], Hemisphere.north),
      isTrue,
    );
  });

  test('derived field notes', () {
    final notes = derivedFieldNotes(
      GroveInputs(
        closed: [thing('a', DateTime(2026, 8, 1), DateTime(2026, 10, 1))],
        allClearDays: [LocalDate(2026, 10, 1)],
      ),
    );
    expect(notes, {FieldNote.oldTab, FieldNote.openSky});
  });

  group('invitations', () {
    final week = LocalDate(2026, 10, 19);

    test('the same all week, gone once taken up or skipped', () {
      final a = invitationFor(
        weekStart: week,
        found: const {},
        taken: const {},
      );
      final b = invitationFor(
        weekStart: week,
        found: const {},
        taken: const {},
      );
      expect(a, isNotNull);
      expect(a, b);
      expect(
        invitationFor(
          weekStart: week,
          found: const {},
          taken: {invitationKey(week, 'skip')},
        ),
        isNull,
      );
    });

    test('leans towards untried things', () {
      final found = {
        for (final note in FieldNote.values)
          if (note != FieldNote.deepBreath && note != FieldNote.justOneThing)
            note.name,
      };
      for (var i = 0; i < 10; i++) {
        final invitation = invitationFor(
          weekStart: week.addDays(7 * i),
          found: found,
          taken: const {},
        );
        expect(
          invitation,
          isIn([
            Invitation.tryReset,
            Invitation.tryFocus,
            Invitation.doneMeans,
            Invitation.parkAnIdea,
            Invitation.addEffort,
          ]),
        );
      }
    });
  });

  group('insights', () {
    test('busiest part of the day', () {
      final hours = List.filled(24, 0)
        ..[9] = 4
        ..[10] = 3
        ..[20] = 2;
      expect(busiestPart(hours), DayPart.morning);
      expect(busiestPart(List.filled(24, 0)), isNull);
    });

    test('median', () {
      expect(median([5, 1, 3]), 3);
      expect(median(const []), isNull);
    });
  });
}
