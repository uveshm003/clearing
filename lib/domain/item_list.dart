import 'package:meta/meta.dart';

import 'enums.dart';
import 'local_date.dart';

/// A context such as Life Admin or Errands. Lists are contexts, not time: an
/// item can be in a list and also be due Today.
@immutable
class ItemList {
  const ItemList({
    required this.id,
    required this.name,
    required this.kind,
    this.icon,
    this.sortOrder = 0,
    this.archived = false,
    this.colour,
    this.pinned = false,
    this.isProject = false,
    this.outcome,
    this.targetDate,
  });

  final String id;
  final String name;
  final ListKind kind;

  /// A Material icon name; null uses the default for [kind].
  final String? icon;
  final double sortOrder;

  /// For system lists this means "hidden": they cannot be deleted (FR-05).
  final bool archived;

  /// A name from [ListColour]; null is the theme's own.
  final String? colour;

  /// Pinned lists sit at the top of the Lists tab.
  final bool pinned;

  /// A project: an outcome made of steps, of which only the next shows on
  /// Today and This week.
  final bool isProject;
  final String? outcome;
  final LocalDate? targetDate;

  bool get isSystem => kind != ListKind.user;

  ItemList copyWith({
    String? name,
    String? icon,
    double? sortOrder,
    bool? archived,
    String? Function()? colour,
    bool? pinned,
    bool? isProject,
    String? Function()? outcome,
    LocalDate? Function()? targetDate,
  }) => ItemList(
    id: id,
    name: name ?? this.name,
    kind: kind,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
    colour: colour != null ? colour() : this.colour,
    pinned: pinned ?? this.pinned,
    isProject: isProject ?? this.isProject,
    outcome: outcome != null ? outcome() : this.outcome,
    targetDate: targetDate != null ? targetDate() : this.targetDate,
  );

  @override
  bool operator ==(Object other) =>
      other is ItemList &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.icon == icon &&
      other.sortOrder == sortOrder &&
      other.archived == archived &&
      other.colour == colour &&
      other.pinned == pinned &&
      other.isProject == isProject &&
      other.outcome == outcome &&
      other.targetDate == targetDate;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    icon,
    sortOrder,
    archived,
    colour,
    pinned,
    isProject,
    outcome,
    targetDate,
  );
}
