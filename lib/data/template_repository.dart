import 'package:drift/drift.dart';

import '../domain/template.dart';
import 'db/database.dart';

class TemplateRepository {
  TemplateRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static Template _toDomain(TemplateRow row) => Template.fromRow(
    id: row.id,
    name: row.name,
    items: row.items,
    seriesId: row.seriesId,
  );

  Stream<List<Template>> watchAll() {
    final query = _db.select(_db.templates)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Stream<Template?> watch(String id) =>
      (_db.select(_db.templates)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toDomain(row));

  Future<Template?> get(String id) async {
    final row = await (_db.select(
      _db.templates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<Template> save(Template template) async {
    await _db
        .into(_db.templates)
        .insertOnConflictUpdate(
          TemplatesCompanion(
            id: Value(template.id),
            name: Value(template.name),
            kind: Value(template.kind),
            items: Value(template.itemsJson()),
            seriesId: Value(template.seriesId),
            updatedAt: Value(_now()),
          ),
        );
    return template;
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
}
