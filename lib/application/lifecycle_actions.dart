import '../data/block_repository.dart';
import '../data/item_repository.dart';
import '../data/settings_repository.dart';
import '../domain/item.dart';
import '../domain/item_transitions.dart';
import '../domain/lifecycle.dart';
import '../domain/local_date.dart';

/// Archive and Trash (FR-18). Nothing is permanently deleted except by an
/// explicit action here or by the 30-day Trash window.
class LifecycleActions {
  LifecycleActions(
    this._items,
    this._settings, {
    required this._now,
    this._blocks,
  });

  final ItemRepository _items;
  final BlockRepository? _blocks;
  final SettingsRepository _settings;
  final DateTime Function() _now;

  /// Archives old done items and purges expired Trash. Runs at app start, at
  /// local midnight and on boot, alongside series advancement.
  Future<void> tidy() async {
    final now = _now();
    final settings = await _settings.get();
    if (archiveCutoff(now, settings.autoArchiveDays) case final cutoff?) {
      await _items.archiveDoneBefore(cutoff);
    }
    await _items.purgeTrash(before: purgeCutoff(now));
    // A one-off batch block is just a slot; once its day has gone, so has it.
    await _blocks?.deleteBefore(LocalDate.fromDateTime(now));
  }

  Future<Item> restore(Item item) => _items.save(item.restoreFromTrash());

  Future<void> deleteForever(Item item) => _items.deleteForever(item.id);

  Future<int> emptyTrash() => _items.purgeTrash();
}
