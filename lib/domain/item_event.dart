import 'package:meta/meta.dart';

import 'enums.dart';

/// One entry in an item's activity line: "Moved to This week, 14 Oct".
@immutable
class ItemEvent {
  const ItemEvent({
    required this.id,
    required this.itemId,
    required this.kind,
    required this.at,
  });

  final String id;
  final String itemId;
  final ItemEventKind kind;
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is ItemEvent &&
      other.id == id &&
      other.itemId == itemId &&
      other.kind == kind &&
      other.at == at;

  @override
  int get hashCode => Object.hash(id, itemId, kind, at);
}
