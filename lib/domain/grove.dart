import 'dart:math';

import 'package:meta/meta.dart';

import 'enums.dart';
import 'field_notes.dart';
import 'local_date.dart';

/// The Grove (§6): a private landscape that grows as thoughts are closed and
/// reviews are done. It's built entirely from data the app already has, and
/// it only ever grows: nothing withers, resets or is taken away.

/// Days an item must have waited for closing it to grow a wildflower.
const wildflowerDays = 14;

enum Season { spring, summer, autumn, winter }

/// Three calendar months of one season.
@immutable
class SeasonSpan {
  const SeasonSpan(this.season, this.start, this.end);

  final Season season;
  final LocalDate start;

  /// The last day, inclusive.
  final LocalDate end;

  bool contains(LocalDate date) => !date.isBefore(start) && !date.isAfter(end);

  /// The season before this one.
  SeasonSpan get previous => seasonOf(start.addDays(-1), _hemisphereOf(this));

  String get key => start.toIso();

  @override
  bool operator ==(Object other) =>
      other is SeasonSpan && other.start == start && other.season == season;

  @override
  int get hashCode => Object.hash(season, start);

  @override
  String toString() => 'SeasonSpan($season from $start)';
}

/// Which hemisphere a span was made for, from its months.
Hemisphere _hemisphereOf(SeasonSpan span) {
  final north = switch (span.start.month) {
    3 => Season.spring,
    6 => Season.summer,
    9 => Season.autumn,
    _ => Season.winter,
  };
  return north == span.season ? Hemisphere.north : Hemisphere.south;
}

/// The meteorological season [date] falls in.
SeasonSpan seasonOf(LocalDate date, Hemisphere hemisphere) {
  // Seasons start in March, June, September and December.
  final startMonth = date.month == 12 || date.month <= 2
      ? 12
      : (date.month ~/ 3) * 3;
  final startYear = date.month <= 2 ? date.year - 1 : date.year;
  final start = LocalDate(startYear, startMonth, 1);
  final end = start.addMonths(3).addDays(-1);
  final north = switch (startMonth) {
    3 => Season.spring,
    6 => Season.summer,
    9 => Season.autumn,
    _ => Season.winter,
  };
  final season = hemisphere == Hemisphere.north
      ? north
      : Season.values[(north.index + 2) % 4];
  return SeasonSpan(season, start, end);
}

/// A thing closed, as the Grove sees it.
@immutable
class ClosedThing {
  const ClosedThing({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime completedAt;

  int get waitedDays => completedAt.difference(createdAt).inDays;
  LocalDate get day => LocalDate.fromDateTime(completedAt);
}

/// Everything the Grove is grown from.
@immutable
class GroveInputs {
  const GroveInputs({
    this.closed = const [],
    this.reviews = const [],
    this.resets = const [],
    this.allClearDays = const [],
    this.resolved = const [],
    this.backedUp = false,
    this.invitations = const [],
    this.hemisphere = Hemisphere.north,
  });

  final List<ClosedThing> closed;

  /// When each weekly review was finished.
  final List<DateTime> reviews;

  /// When each overwhelm reset was finished.
  final List<DateTime> resets;
  final List<LocalDate> allClearDays;

  /// When each waiting item came back.
  final List<DateTime> resolved;
  final bool backedUp;

  /// Days invitations were taken up.
  final List<LocalDate> invitations;
  final Hemisphere hemisphere;
}

enum GroveKind {
  /// A small pile of stones: one week's closed things.
  cairn,

  /// An old tab closed: waited [wildflowerDays] or more.
  wildflower,

  /// A weekly review. Grows as more reviews follow it.
  tree,

  /// A tree from an earlier season, still standing.
  oldTree,

  /// The first overwhelm reset.
  stream,

  /// A day with everything on Today done.
  bird,

  /// The first backup.
  bench,

  /// A waiting item resolved.
  lantern,

  /// An invitation taken up.
  steppingStone,
}

/// One thing in the Grove, with what it was for.
@immutable
class GroveElement {
  const GroveElement({
    required this.kind,
    required this.id,
    this.date,
    this.label,
    this.count = 1,
    this.growth = 0,
  });

  final GroveKind kind;

  /// Stable, so the element stays in the same place between visits.
  final String id;
  final LocalDate? date;

  /// What it was for, e.g. the item's title.
  final String? label;

  /// How many: stones in a cairn, days waited for a wildflower.
  final int count;

  /// A tree's size: 0 sapling, 1 tree, 2 old tree.
  final int growth;

  /// A stable hash of [id] (FNV-1a), the same on every run and platform.
  int get seed {
    var hash = 0x811c9dc5;
    for (final unit in id.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}

/// The Grove for one season, and the totals across all of them.
@immutable
class GroveState {
  const GroveState({
    required this.season,
    required this.elements,
    required this.closed,
    required this.reviews,
    required this.oldTabs,
    required this.totals,
  });

  final SeasonSpan season;
  final List<GroveElement> elements;

  /// This season's counts, for the caption.
  final int closed;
  final int reviews;
  final int oldTabs;
  final GroveTotals totals;

  int count(GroveKind kind) => elements.where((e) => e.kind == kind).length;

  bool get isEmpty => elements.isEmpty;
}

/// All-time counts: what unlocks the Glade variants.
@immutable
class GroveTotals {
  const GroveTotals({
    this.closed = 0,
    this.reviews = 0,
    this.oldTabs = 0,
    this.pastSeasons = 0,
  });

  final int closed;
  final int reviews;
  final int oldTabs;

  /// Earlier seasons with anything in them: pressed as season cards.
  final int pastSeasons;

  /// The Glade variants earned (§6.8). Rewards never gate accessibility:
  /// high contrast lives in Settings regardless.
  Set<GladeVariant> get earned => {
    if (pastSeasons >= 1) GladeVariant.autumn,
    if (reviews >= 10) GladeVariant.monsoon,
    if (oldTabs >= 25) GladeVariant.winter,
    if (closed >= 100) GladeVariant.nightSky,
  };
}

/// How many of each kind are drawn at most; more become a meadow, a grove.
const maxDrawn = {
  GroveKind.wildflower: 40,
  GroveKind.tree: 16,
  GroveKind.oldTree: 24,
  GroveKind.bird: 12,
  GroveKind.lantern: 12,
  GroveKind.steppingStone: 12,
};

/// Grows the Grove for [season] from [inputs].
GroveState buildGrove(GroveInputs inputs, SeasonSpan season) {
  bool inSeason(DateTime at) => season.contains(LocalDate.fromDateTime(at));
  final elements = <GroveElement>[];

  // Cairns: one per week with anything closed, stones = things closed.
  final closedHere = inputs.closed.where((c) => inSeason(c.completedAt));
  final byWeek = <LocalDate, int>{};
  for (final thing in closedHere) {
    final week = thing.day.startOfWeek(DateTime.monday);
    byWeek[week] = (byWeek[week] ?? 0) + 1;
  }
  for (final MapEntry(key: week, value: count) in byWeek.entries) {
    elements.add(
      GroveElement(
        kind: GroveKind.cairn,
        id: 'cairn-${week.toIso()}',
        date: week,
        count: count,
      ),
    );
  }

  // Wildflowers: old tabs closed.
  final oldTabs = closedHere.where((c) => c.waitedDays >= wildflowerDays);
  for (final thing in oldTabs) {
    elements.add(
      GroveElement(
        kind: GroveKind.wildflower,
        // From when and what, not the random id, so places are reproducible.
        id: 'flower-${thing.completedAt.toIso8601String()}-${thing.title}',
        date: thing.day,
        label: thing.title,
        count: thing.waitedDays,
      ),
    );
  }

  // Trees: a review each; each grows with the reviews that follow it.
  final reviewsHere = inputs.reviews.where(inSeason).toList()..sort();
  for (final (i, at) in reviewsHere.indexed) {
    final after = reviewsHere.length - 1 - i;
    elements.add(
      GroveElement(
        kind: GroveKind.tree,
        id: 'tree-${at.toIso8601String()}',
        date: LocalDate.fromDateTime(at),
        growth: after >= 5
            ? 2
            : after >= 2
            ? 1
            : 0,
      ),
    );
  }

  // Trees from earlier seasons keep standing, dressed for this one.
  final earlier = inputs.reviews
      .where((at) => LocalDate.fromDateTime(at).isBefore(season.start))
      .toList();
  for (final at in earlier) {
    elements.add(
      GroveElement(
        kind: GroveKind.oldTree,
        id: 'old-${at.toIso8601String()}',
        date: LocalDate.fromDateTime(at),
        growth: 2,
      ),
    );
  }

  // The stream and the bench stay once they've appeared.
  final firstReset = inputs.resets.where(
    (at) => !LocalDate.fromDateTime(at).isAfter(season.end),
  );
  if (firstReset.isNotEmpty) {
    elements.add(
      GroveElement(
        kind: GroveKind.stream,
        id: 'stream',
        date: LocalDate.fromDateTime(
          firstReset.reduce((a, b) => a.isBefore(b) ? a : b),
        ),
      ),
    );
  }
  if (inputs.backedUp) {
    elements.add(const GroveElement(kind: GroveKind.bench, id: 'bench'));
  }

  for (final day in inputs.allClearDays.where(season.contains)) {
    elements.add(
      GroveElement(kind: GroveKind.bird, id: 'bird-${day.toIso()}', date: day),
    );
  }
  for (final at in inputs.resolved.where(inSeason)) {
    elements.add(
      GroveElement(
        kind: GroveKind.lantern,
        id: 'lantern-${at.toIso8601String()}',
        date: LocalDate.fromDateTime(at),
      ),
    );
  }
  for (final day in inputs.invitations.where(season.contains)) {
    elements.add(
      GroveElement(
        kind: GroveKind.steppingStone,
        id: 'step-${day.toIso()}-${elements.length}',
        date: day,
      ),
    );
  }

  return GroveState(
    season: season,
    elements: elements,
    closed: closedHere.length,
    reviews: reviewsHere.length,
    oldTabs: oldTabs.length,
    totals: groveTotals(inputs, season),
  );
}

GroveTotals groveTotals(GroveInputs inputs, SeasonSpan current) {
  final seasons = <String>{};
  void note(DateTime at) {
    final span = seasonOf(LocalDate.fromDateTime(at), inputs.hemisphere);
    if (span.start.isBefore(current.start)) seasons.add(span.key);
  }

  for (final thing in inputs.closed) {
    note(thing.completedAt);
  }
  inputs.reviews.forEach(note);
  return GroveTotals(
    closed: inputs.closed.length,
    reviews: inputs.reviews.length,
    oldTabs: inputs.closed.where((c) => c.waitedDays >= wildflowerDays).length,
    pastSeasons: seasons.length,
  );
}

/// Earlier seasons that had anything in them, newest first: the album of
/// season cards.
List<GroveState> pastSeasons(
  GroveInputs inputs,
  SeasonSpan current, {
  int limit = 12,
}) {
  final first = [
    ...inputs.closed.map((c) => c.completedAt),
    ...inputs.reviews,
  ].fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
  if (first == null) return const [];
  final firstSpan = seasonOf(LocalDate.fromDateTime(first), inputs.hemisphere);
  final out = <GroveState>[];
  var span = current.previous;
  while (!span.end.isBefore(firstSpan.start) && out.length < limit) {
    final grove = buildGrove(inputs, span);
    if (grove.closed > 0 || grove.reviews > 0) out.add(grove);
    span = span.previous;
  }
  return out;
}

/// Whether reviews were done in four consecutive seasons, at any pace: the
/// *Four seasons* field note.
bool reviewedFourSeasons(List<DateTime> reviews, Hemisphere hemisphere) {
  final keys = {
    for (final at in reviews)
      seasonOf(LocalDate.fromDateTime(at), hemisphere).key,
  };
  for (final at in reviews) {
    var span = seasonOf(LocalDate.fromDateTime(at), hemisphere);
    var run = 1;
    while (run < 4 && keys.contains(span.previous.key)) {
      span = span.previous;
      run++;
    }
    if (run >= 4) return true;
  }
  return false;
}

/// The field notes the Grove can see for itself in [inputs].
Set<FieldNote> derivedFieldNotes(GroveInputs inputs) => {
  if (inputs.closed.any((c) => c.waitedDays >= oldTabDays)) FieldNote.oldTab,
  if (inputs.allClearDays.isNotEmpty) FieldNote.openSky,
  if (inputs.backedUp) FieldNote.safeKeeping,
  if (reviewedFourSeasons(inputs.reviews, inputs.hemisphere))
    FieldNote.fourSeasons,
};

/// Weekly invitations (§6.7): one optional, quiet suggestion a week.
enum Invitation {
  homeForThree,
  doneMeans,
  oldThought,
  parkAnIdea,
  tryFocus,
  tryReset,
  addEffort,
  backUp,
}

/// The field note each invitation leads towards, to favour untried things.
const _invitationNote = {
  Invitation.homeForThree: FieldNote.aHomeForEverything,
  Invitation.oldThought: FieldNote.oldTab,
  Invitation.tryFocus: FieldNote.justOneThing,
  Invitation.tryReset: FieldNote.deepBreath,
  Invitation.backUp: FieldNote.safeKeeping,
};

/// This week's invitation, or null if it was taken up or set aside. Picked
/// the same way all week, leaning towards what hasn't been tried yet.
Invitation? invitationFor({
  required LocalDate weekStart,
  required Set<String> found,
  required Set<String> taken,
}) {
  final week = weekStart.toIso();
  if (taken.any((t) => t.startsWith('$week:'))) return null;
  final untried = [
    for (final invitation in Invitation.values)
      if (!found.contains(_invitationNote[invitation]?.name)) invitation,
  ];
  final pool = untried.length >= 2 ? untried : Invitation.values;
  final index = Random(
    weekStart.daysUntil(LocalDate(2026, 1, 5)).abs(),
  ).nextInt(pool.length);
  return pool[index];
}

/// How an invitation is stored once taken up, or set aside (`skip`).
String invitationKey(LocalDate weekStart, String what) =>
    '${weekStart.toIso()}:$what';
