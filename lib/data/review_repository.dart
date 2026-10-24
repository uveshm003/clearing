import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/enums.dart';
import '../domain/review_session.dart';
import 'db/database.dart';

class ReviewRepository {
  ReviewRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static ReviewSession _toDomain(ReviewSessionRow row) => ReviewSession.fromRow(
    id: row.id,
    kind: row.kind,
    startedAt: row.startedAt,
    completedAt: row.completedAt,
    json: row.counts,
  );

  /// The most recently started session of [kind], finished or not.
  Future<ReviewSession?> latest(ReviewKind kind) async {
    final query = _db.select(_db.reviewSessions)
      ..where((t) => t.kind.equalsValue(kind))
      ..orderBy([
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// When each finished session of [kind] was finished, oldest first.
  Stream<List<DateTime>> watchCompleted(ReviewKind kind) {
    final query = _db.select(_db.reviewSessions)
      ..where((t) => t.kind.equalsValue(kind) & t.completedAt.isNotNull())
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt)]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.completedAt!],
    );
  }

  /// Finished sessions of [kind], newest first.
  Future<List<ReviewSession>> completed(
    ReviewKind kind, {
    int limit = 20,
  }) async {
    final query = _db.select(_db.reviewSessions)
      ..where((t) => t.kind.equalsValue(kind) & t.completedAt.isNotNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return [for (final row in await query.get()) _toDomain(row)];
  }

  Future<ReviewSession> start(ReviewKind kind) async {
    final session = ReviewSession(id: newId(), kind: kind, startedAt: _now());
    await save(session);
    return session;
  }

  Future<ReviewSession> save(ReviewSession session) async {
    await _db
        .into(_db.reviewSessions)
        .insertOnConflictUpdate(
          ReviewSessionsCompanion(
            id: Value(session.id),
            kind: Value(session.kind),
            startedAt: Value(session.startedAt),
            completedAt: Value(session.completedAt),
            counts: Value(session.toJson()),
            updatedAt: Value(_now()),
          ),
        );
    return session;
  }
}
