import 'package:meta/meta.dart';

import 'enums.dart';
import 'local_date.dart';

/// What to search for and how to narrow it (FR-16).
@immutable
class SearchFilter {
  const SearchFilter({
    this.text = '',
    this.statuses = defaultStatuses,
    this.listId,
    this.from,
    this.to,
    this.repeating,
  });

  /// Everything except Trash; done and archived items included (FR-18).
  static const defaultStatuses = {
    ItemStatus.inbox,
    ItemStatus.active,
    ItemStatus.waiting,
    ItemStatus.someday,
    ItemStatus.done,
  };

  final String text;
  final Set<ItemStatus> statuses;
  final String? listId;

  /// Do-date range, inclusive at both ends.
  final LocalDate? from;
  final LocalDate? to;

  /// True for repeating items only, false for one-offs, null for both.
  final bool? repeating;

  bool get hasDateRange => from != null || to != null;

  SearchFilter copyWith({
    String? text,
    Set<ItemStatus>? statuses,
    String? Function()? listId,
    LocalDate? Function()? from,
    LocalDate? Function()? to,
    bool? Function()? repeating,
  }) => SearchFilter(
    text: text ?? this.text,
    statuses: statuses ?? this.statuses,
    listId: listId != null ? listId() : this.listId,
    from: from != null ? from() : this.from,
    to: to != null ? to() : this.to,
    repeating: repeating != null ? repeating() : this.repeating,
  );
}

/// Turns what the user typed into an FTS5 query: every word must match, as
/// a prefix, so "pass ren" finds "Renew passport". Quotes are dropped so no
/// input can be read as FTS syntax. Null when there is nothing to match.
String? ftsQuery(String text) {
  final words = text
      .replaceAll('"', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);
  if (words.isEmpty) return null;
  return words.map((w) => '"$w"*').join(' ');
}
