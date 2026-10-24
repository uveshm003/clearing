import 'package:meta/meta.dart';

import 'search_filter.dart';

/// A search kept as a smart list, e.g. "Waiting on Priya".
@immutable
class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final SearchFilter filter;
  final double sortOrder;

  @override
  bool operator ==(Object other) =>
      other is SavedSearch &&
      other.id == id &&
      other.name == name &&
      other.filter == filter &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(id, name, filter, sortOrder);
}
