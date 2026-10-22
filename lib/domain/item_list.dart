import 'package:meta/meta.dart';

import 'enums.dart';

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
  });

  final String id;
  final String name;
  final ListKind kind;

  /// A Material icon name; null uses the default for [kind].
  final String? icon;
  final double sortOrder;

  /// For system lists this means "hidden": they cannot be deleted (FR-05).
  final bool archived;

  bool get isSystem => kind != ListKind.user;

  ItemList copyWith({
    String? name,
    String? icon,
    double? sortOrder,
    bool? archived,
  }) => ItemList(
    id: id,
    name: name ?? this.name,
    kind: kind,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );

  @override
  bool operator ==(Object other) =>
      other is ItemList &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.icon == icon &&
      other.sortOrder == sortOrder &&
      other.archived == archived;

  @override
  int get hashCode => Object.hash(id, name, kind, icon, sortOrder, archived);
}
