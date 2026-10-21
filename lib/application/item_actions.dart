import '../data/item_repository.dart';
import 'series_actions.dart';
import '../domain/item.dart';
import '../domain/item_transitions.dart';
import '../domain/local_date.dart';
import '../domain/today_rules.dart';

/// Use cases for capturing, placing and closing items (PRD §8.2). Screens
/// call these instead of editing items directly, so rules such as the
/// must-do cap live in one place.
class ItemActions {
  ItemActions(this._items, {required this._now, this._series});

  final ItemRepository _items;

  /// Keeps repeating items moving: closing an occurrence creates the next.
  final SeriesActions? _series;
  final DateTime Function() _now;

  LocalDate get _today => LocalDate.fromDateTime(_now());

  /// Saves each non-empty line of [text] as its own inbox item, so pasting a
  /// brain-dump captures every thought at once.
  Future<List<Item>> capture(String text, {String? listId}) async {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);
    return [
      for (final line in lines) await _items.capture(line, listId: listId),
    ];
  }

  Future<Item> planToday(Item item) => _items.save(item.planToday(_today));

  Future<Item> planThisWeek(Item item) =>
      _items.save(item.planThisWeek(_today));

  Future<Item> planAnytime(Item item) => _items.save(item.planAnytime());

  Future<Item> planOnDate(Item item, LocalDate date, {int? time}) =>
      _items.save(item.planOnDate(date, time: time));

  Future<Item> snoozeToTomorrow(Item item) =>
      _items.save(item.snoozeToTomorrow(_today));

  Future<Item> moveToSomeday(Item item) => _items.save(item.moveToSomeday());

  Future<Item> waitFor(Item item, String person, {LocalDate? followUp}) =>
      _items.save(item.waitFor(person, followUp: followUp));

  /// Completes [item]; for a repeating item the next occurrence is created
  /// straight away (PRD §8.4).
  Future<Item> complete(Item item) async {
    final saved = await _items.save(item.complete(_now()));
    await _advance(saved);
    return saved;
  }

  Future<Item> reopen(Item item) async {
    final saved = await _items.save(item.reopen());
    await _series?.removeOccurrencesAfter(saved);
    return saved;
  }

  /// Deleting one occurrence of a repeating item skips just that one.
  Future<Item> trash(Item item) async {
    final saved = await _items.save(item.trash(_now()));
    await _advance(saved);
    return saved;
  }

  /// Puts back an exact earlier version, for undo. Undoing the completion of
  /// a repeating item also removes the occurrence that completion created.
  Future<void> undo(Item previous) async {
    await _items.restore(previous);
    await _series?.removeOccurrencesAfter(previous);
  }

  Future<void> _advance(Item item) async {
    final seriesId = item.seriesId;
    if (seriesId != null) await _series?.advance(seriesId);
  }

  Future<Item> save(Item item) => _items.save(item);

  /// Flags [item] as must-do unless today's cap is reached, in which case the
  /// caller should offer a swap via [swapMustDo] (FR-04). The cap counts only
  /// items on Today.
  Future<MustDoCheck> setMustDo(
    Item item, {
    required List<Item> openItems,
    required int cap,
  }) async {
    final others = openItems.where((i) => i.id != item.id);
    final check = isOnToday(item, _today)
        ? checkMustDoCap(others, _today, cap)
        : const MustDoAllowed();
    if (check is MustDoAllowed) await _items.save(item.copyWith(mustDo: true));
    return check;
  }

  Future<void> clearMustDo(Item item) =>
      _items.save(item.copyWith(mustDo: false));

  Future<void> swapMustDo({required Item out, required Item into}) async {
    await _items.save(out.copyWith(mustDo: false));
    await _items.save(into.copyWith(mustDo: true));
  }
}
