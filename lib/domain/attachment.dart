import 'package:meta/meta.dart';

/// A photo kept with an item: a receipt, a form, a label. The file lives in
/// the app's own storage and travels inside backups.
@immutable
class Attachment {
  const Attachment({
    required this.id,
    required this.itemId,
    required this.fileName,
    required this.mime,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final String fileName;
  final String mime;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Attachment &&
      other.id == id &&
      other.itemId == itemId &&
      other.fileName == fileName &&
      other.mime == mime &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, itemId, fileName, mime, createdAt);
}
