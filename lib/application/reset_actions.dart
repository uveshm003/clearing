import '../data/item_repository.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';
import 'item_actions.dart';

/// The decisions of the overwhelm reset (FR-12, PRD §4.4).
class ResetActions {
  ResetActions(this._actions, this._items, {required this._now});

  final ItemActions _actions;
  final ItemRepository _items;
  final DateTime Function() _now;

  /// [chosen] become today's must-dos; every other candidate stops being
  /// one, so Today ends up with only what was just picked.
  Future<void> mustHappenToday(
    Iterable<Item> candidates,
    Set<String> chosen,
  ) async {
    for (final item in candidates) {
      if (chosen.contains(item.id)) {
        final today = LocalDate.fromDateTime(_now());
        final planned = switch (item.doDate) {
          null => await _actions.planToday(item),
          // A carried-over date moves to today, keeping its time.
          final date when date.isBefore(today) => await _actions.planOnDate(
            item,
            today,
            time: item.doTime,
          ),
          _ => item,
        };
        await _actions.save(planned.copyWith(mustDo: true));
      } else if (item.mustDo) {
        await _actions.clearMustDo(item);
      }
    }
  }

  Future<void> thisWeek(Iterable<Item> candidates, Set<String> chosen) async {
    for (final item in candidates) {
      if (chosen.contains(item.id)) {
        await _actions.planThisWeek(item.copyWith(mustDo: false));
      }
    }
  }

  /// Moves [items] to Someday, or to Trash when [delete] is set.
  Future<void> letGo(Iterable<Item> items, {required bool delete}) async {
    for (final item in items) {
      delete ? await _actions.trash(item) : await _actions.moveToSomeday(item);
    }
  }

  /// Adds [step] as the item's first step, ahead of any others.
  Future<void> addFirstStep(Item item, String step) async {
    final existing = await _items.subtasksOf(item.id);
    final subtask = await _items.addSubtask(item.id, step);
    final first = existing.isEmpty ? 0.0 : existing.first.sortOrder - 1;
    await _items.saveSubtask(subtask.copyWith(sortOrder: first));
    // Also pinned at the top of Focus, where the reset ends.
    final latest = await _items.getItem(item.id);
    if (latest != null) {
      await _items.save(latest.copyWith(firstStep: () => step.trim()));
    }
  }
}
