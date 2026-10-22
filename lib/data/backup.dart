import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import 'db/database.dart';

/// The backup file format (FR-17). Versioned separately from the database
/// schema so the file layout and the tables can change independently.
const backupFormat = 'clearing-backup';
const backupVersion = 1;

/// Tables in an order that satisfies foreign keys on insert.
const backupTables = [
  'lists',
  'series',
  'items',
  'subtasks',
  'reminders',
  'templates',
  'starter_suggestions',
  'review_sessions',
  'settings',
];

/// `clearing-backup-YYYYMMDD.json`.
String backupFileName(DateTime now) =>
    'clearing-backup-'
    '${now.year.toString().padLeft(4, '0')}'
    '${now.month.toString().padLeft(2, '0')}'
    '${now.day.toString().padLeft(2, '0')}.json';

/// Why a file can't be imported.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

enum ImportMode {
  /// Adds what's missing and keeps the newer copy of anything in both.
  merge,

  /// Makes this device an exact copy of the backup.
  replace,
}

/// A parsed backup, ready to preview and import.
@immutable
class Backup {
  const Backup._({
    required this.exportedAt,
    required this.schemaVersion,
    required this.tables,
  });

  final DateTime? exportedAt;

  /// The database schema the rows were exported from.
  final int schemaVersion;
  final Map<String, List<Map<String, Object?>>> tables;

  int count(String table) => tables[table]?.length ?? 0;

  /// Items by status, for the import preview.
  Map<String, int> get itemsByStatus {
    final counts = <String, int>{};
    for (final row in tables['items'] ?? const <Map<String, Object?>>[]) {
      final status = '${row['status']}';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Parses and checks a backup file, before anything is changed.
  factory Backup.parse(String text, {required int currentSchemaVersion}) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const BackupFormatException('This file isn’t a Clearing backup.');
    }
    if (json is! Map || json['format'] != backupFormat) {
      throw const BackupFormatException('This file isn’t a Clearing backup.');
    }
    final version = json['version'];
    if (version is! int || version > backupVersion) {
      throw const BackupFormatException(
        'This backup was made by a newer version of Clearing. Update the '
        'app, then try again.',
      );
    }
    final schema = json['schemaVersion'];
    if (schema is! int || schema > currentSchemaVersion) {
      throw const BackupFormatException(
        'This backup was made by a newer version of Clearing. Update the '
        'app, then try again.',
      );
    }
    final rawTables = json['tables'];
    if (rawTables is! Map) {
      throw const BackupFormatException('This backup is incomplete.');
    }
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in backupTables) {
      final rows = rawTables[table] ?? const [];
      if (rows is! List || rows.any((r) => r is! Map)) {
        throw BackupFormatException('This backup is damaged ($table).');
      }
      tables[table] = [
        for (final row in rows) Map<String, Object?>.from(row as Map),
      ];
    }
    return Backup._(
      exportedAt: DateTime.tryParse('${json['exportedAt']}'),
      schemaVersion: schema,
      tables: tables,
    );
  }
}

/// Writes and reads backups as the database's own rows, so a round trip
/// reproduces every value exactly.
class BackupService {
  BackupService(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<String> export() async {
    final tables = <String, Object?>{};
    for (final table in backupTables) {
      final rows = await _db.customSelect('SELECT * FROM $table').get();
      tables[table] = [for (final row in rows) row.data];
    }
    return const JsonEncoder.withIndent(' ').convert({
      'format': backupFormat,
      'version': backupVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': _now().toIso8601String(),
      'tables': tables,
    });
  }

  Backup parse(String text) =>
      Backup.parse(text, currentSchemaVersion: _db.schemaVersion);

  Future<void> import(Backup backup, ImportMode mode) =>
      _db.transaction(() async {
        final rows = mode == ImportMode.merge
            ? await _matchSystemRows(backup)
            : backup.tables;
        if (mode == ImportMode.replace) {
          for (final table in backupTables.reversed) {
            await _db.customStatement('DELETE FROM $table');
          }
        }
        for (final table in backupTables) {
          final columns = await _columns(table);
          for (final row in rows[table]!) {
            await _write(table, columns, row, merge: mode == ImportMode.merge);
          }
        }
        _db.notifyUpdates({
          for (final table in _db.allTables) TableUpdate.onTable(table),
        });
      });

  /// Column names of [table] on this device. Backups from an older schema
  /// may lack some (they take their defaults); unknown ones are ignored.
  Future<Set<String>> _columns(String table) async => {
    for (final row in await _db.customSelect('PRAGMA table_info($table)').get())
      row.read<String>('name'),
  };

  Future<void> _write(
    String table,
    Set<String> columns,
    Map<String, Object?> row, {
    required bool merge,
  }) async {
    final values = {
      for (final MapEntry(:key, :value) in row.entries)
        if (columns.contains(key)) key: value,
    };
    if (values.isEmpty) return;
    final key = table == 'settings' ? 'key' : 'id';
    if (merge) {
      final existing = await _db
          .customSelect(
            'SELECT updated_at FROM $table WHERE $key = ?',
            variables: [Variable(values[key])],
          )
          .getSingleOrNull();
      if (existing != null) {
        // Keep whichever copy changed last; ISO text compares in order.
        final mine = existing.read<String>('updated_at');
        final theirs = '${values['updated_at']}';
        if (theirs.compareTo(mine) <= 0) return;
      }
    }
    // An upsert, not INSERT OR REPLACE: replacing would delete the row
    // first, cascading to its subtasks and skipping the search triggers.
    final names = values.keys.toList();
    final updates = [
      for (final name in names)
        if (name != key) '$name = excluded.$name',
    ];
    await _db.customStatement(
      'INSERT INTO $table (${names.join(', ')}) '
      'VALUES (${List.filled(names.length, '?').join(', ')}) '
      'ON CONFLICT($key) DO '
      '${updates.isEmpty ? 'NOTHING' : 'UPDATE SET ${updates.join(', ')}'}',
      [for (final name in names) values[name]],
    );
  }

  /// When merging, the backup's Life Admin and Errands lists and its built-in
  /// starter suggestions are the same things as this device's, just with
  /// other ids. Points the backup's rows at the local ones instead of adding
  /// duplicates.
  Future<Map<String, List<Map<String, Object?>>>> _matchSystemRows(
    Backup backup,
  ) async {
    final localLists = {
      for (final row
          in await _db
              .customSelect("SELECT id, kind FROM lists WHERE kind != 'user'")
              .get())
        row.read<String>('kind'): row.read<String>('id'),
    };
    final listIds = <String, String>{};
    final lists = <Map<String, Object?>>[];
    for (final row in backup.tables['lists']!) {
      final local = localLists[row['kind']];
      if (local != null && local != row['id']) {
        listIds['${row['id']}'] = local;
        lists.add({...row, 'id': local});
      } else {
        lists.add(row);
      }
    }
    String? remap(Object? id) => id == null ? null : listIds['$id'] ?? '$id';

    final localSuggestions = {
      for (final row
          in await _db
              .customSelect('SELECT title FROM starter_suggestions')
              .get())
        row.read<String>('title'),
    };

    return {
      ...backup.tables,
      'lists': lists,
      'items': [
        for (final row in backup.tables['items']!)
          {...row, 'list_id': remap(row['list_id'])},
      ],
      'series': [
        for (final row in backup.tables['series']!)
          {...row, 'template': _remapTemplate(row['template'], remap)},
      ],
      'starter_suggestions': [
        for (final row in backup.tables['starter_suggestions']!)
          if (row['user_created'] == 1 ||
              !localSuggestions.contains(row['title']))
            row,
      ],
    };
  }

  static Object? _remapTemplate(
    Object? template,
    String? Function(Object?) remap,
  ) {
    if (template is! String) return template;
    try {
      final json = jsonDecode(template);
      if (json is Map && json['listId'] != null) {
        return jsonEncode({...json, 'listId': remap(json['listId'])});
      }
    } on FormatException {
      // Leave it as it was.
    }
    return template;
  }
}
