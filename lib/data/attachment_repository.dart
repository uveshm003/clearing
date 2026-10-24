import 'dart:io';

import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/attachment.dart';
import 'db/database.dart';

/// Photos kept with items. Rows are in the database; the files are in an
/// `attachments` folder in the app's own storage, which no other app can
/// read.
class AttachmentRepository {
  AttachmentRepository(
    this._db, {
    required this._folder,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Future<Directory> Function() _folder;
  final DateTime Function() _now;

  static Attachment _toDomain(AttachmentRow row) => Attachment(
    id: row.id,
    itemId: row.itemId,
    fileName: row.fileName,
    mime: row.mime,
    createdAt: row.createdAt,
  );

  Future<Directory> _dir() async {
    final dir = await _folder();
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// The file behind [attachment].
  Future<File> fileOf(Attachment attachment) async =>
      File('${(await _dir()).path}/${attachment.fileName}');

  Stream<List<Attachment>> watchForItem(String itemId) {
    final query = _db.select(_db.attachments)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch().map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  Future<List<Attachment>> all() async => [
    for (final row in await _db.select(_db.attachments).get()) _toDomain(row),
  ];

  Future<Attachment> add(
    String itemId,
    Uint8List bytes, {
    required String mime,
  }) async {
    final now = _now();
    final id = newId();
    final extension = switch (mime) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final attachment = Attachment(
      id: id,
      itemId: itemId,
      fileName: '$id.$extension',
      mime: mime,
      createdAt: now,
    );
    await (await fileOf(attachment)).writeAsBytes(bytes, flush: true);
    await _db
        .into(_db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: id,
            itemId: itemId,
            fileName: attachment.fileName,
            mime: mime,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return attachment;
  }

  /// Writes a file restored from a backup; existing files are kept.
  Future<void> restoreFile(String fileName, Uint8List bytes) async {
    // Only plain names: a backup must never write outside the folder.
    if (fileName.contains('/') || fileName.contains(r'\') || fileName == '..') {
      return;
    }
    final file = File('${(await _dir()).path}/$fileName');
    if (!file.existsSync()) await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> delete(Attachment attachment) async {
    await (_db.delete(
      _db.attachments,
    )..where((t) => t.id.equals(attachment.id))).go();
    final file = await fileOf(attachment);
    if (file.existsSync()) await file.delete();
  }

  /// Removes files whose rows are gone, e.g. after their item was purged.
  Future<int> pruneOrphans() async {
    final known = {for (final a in await all()) a.fileName};
    var removed = 0;
    await for (final entry in (await _dir()).list()) {
      if (entry is File && !known.contains(entry.uri.pathSegments.last)) {
        await entry.delete();
        removed++;
      }
    }
    return removed;
  }
}
