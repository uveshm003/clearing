import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../domain/item.dart';

/// One undoable change: what it was called, and the items as they were.
@immutable
class ChangeEntry {
  const ChangeEntry({
    required this.id,
    required this.message,
    required this.previous,
    required this.at,
    this.undone = false,
  });

  final int id;
  final String message;
  final List<Item> previous;
  final DateTime at;
  final bool undone;

  ChangeEntry markUndone() => ChangeEntry(
    id: id,
    message: message,
    previous: previous,
    at: at,
    undone: true,
  );
}

/// The last ten changes made this session (FR-23), newest first, so a
/// mis-swipe noticed after the snackbar has gone can still be undone. Kept
/// in memory only.
class ChangeHistory extends Notifier<List<ChangeEntry>> {
  static const limit = 10;
  var _next = 0;

  @override
  List<ChangeEntry> build() => const [];

  ChangeEntry record(String message, List<Item> previous, DateTime at) {
    final entry = ChangeEntry(
      id: _next++,
      message: message,
      previous: previous,
      at: at,
    );
    state = [entry, ...state].take(limit).toList();
    return entry;
  }

  void markUndone(int id) => state = [
    for (final entry in state) entry.id == id ? entry.markUndone() : entry,
  ];
}

final changeHistoryProvider =
    NotifierProvider<ChangeHistory, List<ChangeEntry>>(ChangeHistory.new);
