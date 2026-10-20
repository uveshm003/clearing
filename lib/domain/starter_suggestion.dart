import 'package:meta/meta.dart';

import 'enums.dart';

/// An editable quick-add chip shown on an empty inbox and in capture (FR-06).
@immutable
class StarterSuggestion {
  const StarterSuggestion({
    required this.id,
    required this.title,
    this.listKind,
    this.enabled = true,
    this.userCreated = false,
  });

  final String id;
  final String title;

  /// The system list a captured suggestion is filed under, if any.
  final ListKind? listKind;
  final bool enabled;
  final bool userCreated;

  StarterSuggestion copyWith({String? title, bool? enabled}) =>
      StarterSuggestion(
        id: id,
        title: title ?? this.title,
        listKind: listKind,
        enabled: enabled ?? this.enabled,
        userCreated: userCreated,
      );

  @override
  bool operator ==(Object other) =>
      other is StarterSuggestion &&
      other.id == id &&
      other.title == title &&
      other.listKind == listKind &&
      other.enabled == enabled &&
      other.userCreated == userCreated;

  @override
  int get hashCode => Object.hash(id, title, listKind, enabled, userCreated);
}

/// The default chips from FR-06.
const defaultStarterSuggestions = <(String, ListKind?)>[
  ('Pay a bill', ListKind.lifeAdmin),
  ('Reply to a message', null),
  ('Book an appointment', ListKind.lifeAdmin),
  ('Tidy a surface', null),
  ('Refill a prescription', ListKind.errands),
  ('Prepare tomorrow’s items', null),
  ('Review finances', ListKind.lifeAdmin),
  ('Plan meals', null),
];
