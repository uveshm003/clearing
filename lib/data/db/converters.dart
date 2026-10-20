import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/local_date.dart';

/// Stores [LocalDate] as ISO `YYYY-MM-DD` text: sortable, readable in exports
/// and free of time-zone meaning.
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

/// Stores a JSON object or array as text.
class JsonConverter extends TypeConverter<Object, String> {
  const JsonConverter();

  @override
  Object fromSql(String fromDb) => jsonDecode(fromDb) as Object;

  @override
  String toSql(Object value) => jsonEncode(value);
}
