import 'package:meta/meta.dart';

@immutable
class Subtask {
  const Subtask({
    required this.id,
    required this.itemId,
    required this.title,
    this.done = false,
    this.sortOrder = 0,
  });

  final String id;
  final String itemId;
  final String title;
  final bool done;
  final double sortOrder;

  Subtask copyWith({String? title, bool? done, double? sortOrder}) => Subtask(
    id: id,
    itemId: itemId,
    title: title ?? this.title,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  @override
  bool operator ==(Object other) =>
      other is Subtask &&
      other.id == id &&
      other.itemId == itemId &&
      other.title == title &&
      other.done == done &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(id, itemId, title, done, sortOrder);
}

/// "2 of 5" style progress for an item's subtasks (FR-07).
@immutable
class SubtaskProgress {
  const SubtaskProgress(this.done, this.total);

  factory SubtaskProgress.of(Iterable<Subtask> subtasks) =>
      SubtaskProgress(subtasks.where((s) => s.done).length, subtasks.length);

  final int done;
  final int total;

  bool get isEmpty => total == 0;
  bool get isComplete => total > 0 && done == total;

  @override
  String toString() => '$done of $total';
}
