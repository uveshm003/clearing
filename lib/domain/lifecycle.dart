/// Data lifecycle (FR-18): done items are archived after a while, and Trash
/// keeps deleted items for a fixed period before purging them.
library;

/// How long Trash keeps an item before it is permanently deleted.
const trashRetention = Duration(days: 30);

/// [AppSettings.autoArchiveDays] value meaning "never archive".
const archiveNever = 0;

/// Done items completed before this are archived; null when archiving is off.
DateTime? archiveCutoff(DateTime now, int autoArchiveDays) =>
    autoArchiveDays <= archiveNever
    ? null
    : now.subtract(Duration(days: autoArchiveDays));

/// Trashed items deleted before this are purged.
DateTime purgeCutoff(DateTime now) => now.subtract(trashRetention);

/// Whole days left before an item trashed at [trashedAt] is purged.
int daysUntilPurge(DateTime trashedAt, DateTime now) {
  final left = trashedAt.add(trashRetention).difference(now);
  return left.isNegative ? 0 : (left.inHours / 24).ceil();
}
