import 'package:meta/meta.dart';

import 'local_date.dart';

/// Something the user was glad they did, noted at the end of a weekly
/// review. Private; shown only in the Grove.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.body,
  });

  final String id;
  final LocalDate date;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is JournalEntry &&
      other.id == id &&
      other.date == date &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, date, body);
}
