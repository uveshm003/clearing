import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'enums.dart';

/// A reusable checklist (FR-13), such as a packing list or a weekly reset.
/// Attached to a series, it is a routine: each occurrence arrives as a fresh
/// checklist.
///
/// Starting one copies it into a new item, so editing a template never
/// changes items made from it before.
@immutable
class Template {
  const Template({
    required this.id,
    required this.name,
    this.steps = const [],
    this.doneMeans,
    this.listId,
    this.seriesId,
  });

  final String id;
  final String name;
  final List<String> steps;
  final String? doneMeans;
  final String? listId;

  /// Set when the template is a routine.
  final String? seriesId;

  bool get isRoutine => seriesId != null;

  TemplateKind get kind =>
      isRoutine ? TemplateKind.routine : TemplateKind.checklist;

  Template copyWith({
    String? name,
    List<String>? steps,
    String? Function()? doneMeans,
    String? Function()? listId,
    String? Function()? seriesId,
  }) => Template(
    id: id,
    name: name ?? this.name,
    steps: steps ?? this.steps,
    doneMeans: doneMeans != null ? doneMeans() : this.doneMeans,
    listId: listId != null ? listId() : this.listId,
    seriesId: seriesId != null ? seriesId() : this.seriesId,
  );

  /// What the `templates.items` column holds.
  Map<String, Object?> itemsJson() => {
    'steps': steps,
    'doneMeans': doneMeans,
    'listId': listId,
  };

  factory Template.fromRow({
    required String id,
    required String name,
    required Object items,
    String? seriesId,
  }) {
    final map = items is Map ? items : const {};
    final steps = map['steps'];
    return Template(
      id: id,
      name: name,
      steps: steps is List ? steps.whereType<String>().toList() : const [],
      doneMeans: map['doneMeans'] is String ? map['doneMeans'] as String : null,
      listId: map['listId'] is String ? map['listId'] as String : null,
      seriesId: seriesId,
    );
  }

  static const _steps = ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      other is Template &&
      other.id == id &&
      other.name == name &&
      _steps.equals(other.steps, steps) &&
      other.doneMeans == doneMeans &&
      other.listId == listId &&
      other.seriesId == seriesId;

  @override
  int get hashCode =>
      Object.hash(id, name, _steps.hash(steps), doneMeans, listId, seriesId);
}

/// One-tap examples offered while there are no templates (FR-13).
const exampleTemplates = <(String, List<String>, String?)>[
  (
    'Morning routine',
    ['Glass of water', 'Stretch for five minutes', 'Look at Today'],
    null,
  ),
  (
    'Packing list',
    ['Charger', 'Toothbrush', 'Medication', 'Change of clothes', 'ID'],
    'Bag zipped and by the door',
  ),
  (
    'Weekly reset',
    [
      'Clear the kitchen counter',
      'Laundry',
      'Bins out',
      'Check the week ahead',
    ],
    null,
  ),
  (
    'Meal plan',
    ['Pick five dinners', 'Check the cupboards', 'Write the shopping list'],
    'Shopping list ready',
  ),
];
