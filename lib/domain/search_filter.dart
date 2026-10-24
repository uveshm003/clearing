import 'package:collection/collection.dart';
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
    this.contextId,
    this.maxEffort,
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

  /// Only items with this context.
  final String? contextId;

  /// Only items that take at most this many minutes.
  final int? maxEffort;

  bool get hasDateRange => from != null || to != null;

  /// Anything beyond the default statuses and no text.
  bool get isNarrowed =>
      listId != null ||
      hasDateRange ||
      repeating != null ||
      contextId != null ||
      maxEffort != null ||
      !const SetEquality<ItemStatus>().equals(statuses, defaultStatuses);

  SearchFilter copyWith({
    String? text,
    Set<ItemStatus>? statuses,
    String? Function()? listId,
    LocalDate? Function()? from,
    LocalDate? Function()? to,
    bool? Function()? repeating,
    String? Function()? contextId,
    int? Function()? maxEffort,
  }) => SearchFilter(
    text: text ?? this.text,
    statuses: statuses ?? this.statuses,
    listId: listId != null ? listId() : this.listId,
    from: from != null ? from() : this.from,
    to: to != null ? to() : this.to,
    repeating: repeating != null ? repeating() : this.repeating,
    contextId: contextId != null ? contextId() : this.contextId,
    maxEffort: maxEffort != null ? maxEffort() : this.maxEffort,
  );

  Map<String, Object?> toJson() => {
    'text': text,
    'statuses': [for (final s in statuses) s.name]..sort(),
    'listId': listId,
    'from': from?.toIso(),
    'to': to?.toIso(),
    'repeating': repeating,
    'contextId': contextId,
    'maxEffort': maxEffort,
  };

  /// Tolerates missing or malformed keys, like [AppSettings.fromJson].
  factory SearchFilter.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    T? read<T>(String key) => map[key] is T ? map[key] as T : null;
    LocalDate? date(String key) {
      final value = read<String>(key);
      if (value == null) return null;
      try {
        return LocalDate.parse(value);
      } on FormatException {
        return null;
      }
    }

    final statuses = {
      for (final name in read<List<Object?>>('statuses') ?? const [])
        ...ItemStatus.values.where((s) => s.name == name),
    };
    return SearchFilter(
      text: read<String>('text') ?? '',
      statuses: statuses.isEmpty ? defaultStatuses : statuses,
      listId: read<String>('listId'),
      from: date('from'),
      to: date('to'),
      repeating: read<bool>('repeating'),
      contextId: read<String>('contextId'),
      maxEffort: read<int>('maxEffort'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SearchFilter &&
      other.text == text &&
      const SetEquality<ItemStatus>().equals(other.statuses, statuses) &&
      other.listId == listId &&
      other.from == from &&
      other.to == to &&
      other.repeating == repeating &&
      other.contextId == contextId &&
      other.maxEffort == maxEffort;

  @override
  int get hashCode => Object.hash(
    text,
    const SetEquality<ItemStatus>().hash(statuses),
    listId,
    from,
    to,
    repeating,
    contextId,
    maxEffort,
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
