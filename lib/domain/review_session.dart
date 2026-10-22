import 'package:meta/meta.dart';

import 'enums.dart';

/// A weekly review or overwhelm reset in progress or finished (PRD §4.3,
/// §4.4). [step] and [counts] are saved after every step, so a review can be
/// resumed where it was left.
@immutable
class ReviewSession {
  const ReviewSession({
    required this.id,
    required this.kind,
    required this.startedAt,
    this.completedAt,
    this.step = 0,
    this.counts = const {},
  });

  final String id;
  final ReviewKind kind;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int step;

  /// Tallies such as "cleared", "planned" and "skipped". No score.
  final Map<String, int> counts;

  bool get isComplete => completedAt != null;

  int count(String key) => counts[key] ?? 0;

  ReviewSession copyWith({int? step, DateTime? completedAt}) => ReviewSession(
    id: id,
    kind: kind,
    startedAt: startedAt,
    completedAt: completedAt ?? this.completedAt,
    step: step ?? this.step,
    counts: counts,
  );

  /// Adds [by] to [key].
  ReviewSession tally(String key, [int by = 1]) => ReviewSession(
    id: id,
    kind: kind,
    startedAt: startedAt,
    completedAt: completedAt,
    step: step,
    counts: {...counts, key: count(key) + by},
  );

  Map<String, Object?> toJson() => {'step': step, ...counts};

  factory ReviewSession.fromRow({
    required String id,
    required ReviewKind kind,
    required DateTime startedAt,
    DateTime? completedAt,
    required Object json,
  }) {
    final map = json is Map ? json : const {};
    return ReviewSession(
      id: id,
      kind: kind,
      startedAt: startedAt,
      completedAt: completedAt,
      step: map['step'] is int ? map['step'] as int : 0,
      counts: {
        for (final MapEntry(:key, :value) in map.entries)
          if (key is String && key != 'step' && value is int) key: value,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReviewSession &&
      other.id == id &&
      other.kind == kind &&
      other.startedAt == startedAt &&
      other.completedAt == completedAt &&
      other.step == step &&
      other.counts.length == counts.length &&
      counts.entries.every((e) => other.counts[e.key] == e.value);

  @override
  int get hashCode => Object.hash(id, kind, startedAt, completedAt, step);
}
