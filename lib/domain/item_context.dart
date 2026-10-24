import 'package:meta/meta.dart';

import 'enums.dart';

/// Where or how something can be done: at home, out, with low energy
/// (FR-22). Built-in contexts are shown translated by [kind].
@immutable
class ItemContext {
  const ItemContext({
    required this.id,
    required this.name,
    required this.kind,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final ContextKind kind;
  final double sortOrder;

  bool get isBuiltIn => kind != ContextKind.user;

  @override
  bool operator ==(Object other) =>
      other is ItemContext &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(id, name, kind, sortOrder);
}
