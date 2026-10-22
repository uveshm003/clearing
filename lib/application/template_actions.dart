import '../core/ids.dart';
import '../data/db/database.dart';
import '../data/item_repository.dart';
import '../data/series_repository.dart';
import '../data/template_repository.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/repeat_series.dart';
import '../domain/template.dart';
import 'item_actions.dart';
import 'series_actions.dart';

/// Templates and routines (FR-13).
class TemplateActions {
  TemplateActions(
    this._db,
    this._templates,
    this._items,
    this._itemActions,
    this._seriesRepo,
    this._series,
  );

  final AppDatabase _db;
  final TemplateRepository _templates;
  final ItemRepository _items;
  final ItemActions _itemActions;
  final SeriesRepository _seriesRepo;
  final SeriesActions _series;

  Future<Template> create(
    String name, {
    List<String> steps = const [],
    String? doneMeans,
  }) => _templates.save(
    Template(
      id: newId(),
      name: name.trim(),
      steps: steps,
      doneMeans: doneMeans,
    ),
  );

  /// Saves edits. A routine's future occurrences follow them; items already
  /// made from it stay as they are.
  Future<void> save(Template template) => _db.transaction(() async {
    await _templates.save(template);
    final seriesId = template.seriesId;
    if (seriesId == null) return;
    final series = await _seriesRepo.get(seriesId);
    if (series == null) return;
    await _seriesRepo.save(
      series.copyWith(template: _seriesTemplate(template, series.template)),
    );
  });

  /// "Start now": a new inbox item that is a copy of the checklist. The
  /// caller then places it like any captured item.
  Future<Item> start(Template template) => _db.transaction(() async {
    final [item] = await _itemActions.capture(
      template.name,
      listId: template.listId,
    );
    for (final step in template.steps) {
      await _items.addSubtask(item.id, step);
    }
    return _itemActions.save(
      item.copyWith(doneMeans: () => template.doneMeans),
    );
  });

  /// Attaches [template] to a new series built from [rule]: from then on each
  /// occurrence arrives as a fresh checklist.
  Future<Template> makeRoutine(Template template, RepeatSeries rule) =>
      _db.transaction(() async {
        final series = await _seriesRepo.save(
          rule.copyWith(
            template: _seriesTemplate(
              template,
              const SeriesTemplate(title: ''),
            ),
          ),
        );
        final routine = await _templates.save(
          template.copyWith(seriesId: () => series.id),
        );
        await _series.advance(series.id);
        return routine;
      });

  /// Ends the routine. The template and past items stay.
  Future<Template> stopRoutine(Template template) => _db.transaction(() async {
    final seriesId = template.seriesId;
    if (seriesId != null) {
      for (final item in await _seriesRepo.occurrences(seriesId)) {
        // The open checklist is still a commitment; it just stops repeating.
        if (item.status != ItemStatus.done) {
          await _items.save(item.copyWith(seriesId: () => null));
        }
      }
      await _seriesRepo.delete(seriesId);
    }
    return _templates.save(template.copyWith(seriesId: () => null));
  });

  Future<void> delete(Template template) async {
    if (template.isRoutine) await stopRoutine(template);
    await _templates.delete(template.id);
  }

  static SeriesTemplate _seriesTemplate(
    Template template,
    SeriesTemplate current,
  ) => current.copyWith(
    title: template.name,
    listId: () => template.listId,
    doneMeans: () => template.doneMeans,
    subtasks: template.steps,
  );
}
