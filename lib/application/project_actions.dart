import '../data/item_repository.dart';
import '../data/list_repository.dart';
import '../domain/item.dart';
import '../domain/item_list.dart';
import 'item_actions.dart';

/// Projects, lightly (§5.4): a list with an outcome. Only its next action
/// shows on Today and This week.
class ProjectActions {
  ProjectActions(this._lists, this._items, this._actions);

  final ListRepository _lists;
  final ItemRepository _items;
  final ItemActions _actions;

  /// Turns [item] into a project named after it. The item becomes the first
  /// step, keeping its plan; each of its subtasks becomes a step of its own.
  /// Nothing is lost.
  Future<ItemList> convert(Item item) async {
    final project = await _lists.create(
      item.title,
      isProject: true,
      outcome: item.doneMeans ?? item.title,
    );
    final first = await _actions.save(item.copyWith(listId: () => project.id));
    for (final subtask in await _items.subtasksOf(first.id)) {
      final [step] = await _actions.capture(subtask.title, listId: project.id);
      if (subtask.done) {
        await _actions.complete(step);
      } else {
        await _actions.planAnytime(step);
      }
      await _items.deleteSubtask(subtask.id);
    }
    return project;
  }

  /// A new list that's a project from the start.
  Future<ItemList> create(String name, {String? outcome}) =>
      _lists.create(name, isProject: true, outcome: outcome);
}
