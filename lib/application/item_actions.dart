import '../core/ids.dart';
import '../data/event_repository.dart';
import '../data/item_repository.dart';
import 'series_actions.dart';
import '../domain/capture_parser.dart';
import '../domain/enums.dart';
import '../domain/item.dart';
import '../domain/item_transitions.dart';
import '../domain/local_date.dart';
import '../domain/repeat_series.dart';
import '../domain/today_rules.dart';

/// What saving a parsed capture did, so the sheet can say so.
typedef CaptureResult = ({Item item, bool mustDoRefused});

/// Use cases for capturing, placing and closing items (PRD §8.2). Screens
/// call these instead of editing items directly, so rules such as the
/// must-do cap live in one place.
class ItemActions {
  ItemActions(this._items, {required this._now, this._series, this._events});

  final ItemRepository _items;

  /// Writes each item's activity line; absent in some tests.
  final EventRepository? _events;

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
      for (final line in lines)
        await _log(
          await _items.capture(line, listId: listId),
          ItemEventKind.captured,
        ),
    ];
  }

  /// Saves one line that smart capture understood (FR-01a). With a date,
  /// Today, a repeat or a must-do, and [skipInbox], it's planned straight
  /// away; otherwise it waits in the Inbox with what was read pre-filled.
  ///
  /// A must-do over today's cap is left as an ordinary Today item, and
  /// reported, rather than silently bumping another.
  Future<CaptureResult> captureParsed(
    ParsedCapture parsed, {
    String? listId,
    bool skipInbox = true,
    WhenHorizon? planAs,
    int mustDoCap = 3,
    List<Item> openItems = const [],
  }) async {
    var item = await _log(
      await _items.capture(parsed.title, listId: parsed.listId ?? listId),
      ItemEventKind.captured,
    );
    item = await _items.save(
      item.copyWith(
        effort: () => parsed.effort,
        deadline: () => parsed.deadline,
        // Nothing typed is lost: the original words stay in the notes.
        notes: () => parsed.isPlain ? null : parsed.original.trim(),
      ),
    );
    if (parsed.waitingOn case final person?) {
      return (item: await waitFor(item, person), mustDoRefused: false);
    }
    final plans = parsed.hasPlan || planAs != null;
    if (!plans) return (item: item, mustDoRefused: false);
    if (!skipInbox && planAs == null) {
      // Remembered for the clarify flow to suggest.
      final kept = await _items.save(
        item.copyWith(doDate: () => parsed.date, doTime: () => parsed.time),
      );
      return (item: kept, mustDoRefused: false);
    }

    if (parsed.date case final date?) {
      item = await planOnDate(item, date, time: parsed.time);
    } else if ((parsed.horizon ?? planAs) == WhenHorizon.thisWeek) {
      item = await planThisWeek(item);
    } else {
      item = await planToday(item);
    }

    if (parsed.repeat case final rule?) {
      final series = _series;
      if (series != null) {
        await series.startRepeating(
          item,
          RepeatSeries(
            id: newId(),
            freq: rule.freq,
            interval: rule.interval,
            weekdays: rule.weekdays,
            monthDay: rule.monthDay,
            startDate: item.doDate ?? _today,
            onMissed: OnMissed.carryOver,
            template: SeriesTemplate(title: item.title),
          ),
        );
        item = (await get(item.id)) ?? item;
      }
    }

    var refused = false;
    if (parsed.mustDo) {
      final check = await setMustDo(item, openItems: openItems, cap: mustDoCap);
      refused = check is MustDoNeedsSwap;
      item = (await get(item.id)) ?? item;
    }
    return (item: item, mustDoRefused: refused);
  }

  Future<Item?> get(String id) => _items.getItem(id);

  Future<Item> planToday(Item item) =>
      _placed(item, item.planToday(_today), ItemEventKind.planned);

  Future<Item> planThisWeek(Item item) =>
      _placed(item, item.planThisWeek(_today), ItemEventKind.planned);

  Future<Item> planAnytime(Item item) =>
      _placed(item, item.planAnytime(), ItemEventKind.planned);

  Future<Item> planOnDate(Item item, LocalDate date, {int? time}) =>
      _placed(item, item.planOnDate(date, time: time), ItemEventKind.planned);

  Future<Item> snoozeToTomorrow(Item item) =>
      _placed(item, item.snoozeToTomorrow(_today), ItemEventKind.planned);

  Future<Item> moveToSomeday(Item item) =>
      _placed(item, item.moveToSomeday(), ItemEventKind.someday);

  Future<Item> waitFor(Item item, String person, {LocalDate? followUp}) =>
      _placed(
        item,
        item.waitFor(person, followUp: followUp),
        ItemEventKind.waiting,
      );

  /// Completes [item]; for a repeating item the next occurrence is created
  /// straight away (PRD §8.4).
  Future<Item> complete(Item item) async {
    final saved = await _placed(
      item,
      item.complete(_now()),
      ItemEventKind.done,
    );
    await _advance(saved);
    return saved;
  }

  Future<Item> reopen(Item item) async {
    final saved = await _placed(item, item.reopen(), ItemEventKind.reopened);
    await _series?.removeOccurrencesAfter(saved);
    return saved;
  }

  /// Deleting one occurrence of a repeating item skips just that one.
  Future<Item> trash(Item item) async {
    final saved = await _placed(
      item,
      item.trash(_now()),
      ItemEventKind.trashed,
    );
    await _advance(saved);
    return saved;
  }

  /// Sets the item's rough effort, in minutes; null clears it.
  Future<Item> setEffort(Item item, int? minutes) =>
      _items.save(item.copyWith(effort: () => minutes));

  /// Moves [items] to [listId] (null unfiles them).
  Future<void> moveToList(Iterable<Item> items, String? listId) async {
    for (final item in items) {
      await _items.save(item.copyWith(listId: () => listId));
    }
  }

  /// Puts [ordered] in that order, keeping them between their neighbours.
  Future<void> reorder(List<Item> ordered) async {
    if (ordered.isEmpty) return;
    final base = ordered
        .map((i) => i.sortOrder)
        .reduce((a, b) => a < b ? a : b);
    for (final (i, item) in ordered.indexed) {
      final sortOrder = base + i;
      if (item.sortOrder != sortOrder) {
        await _items.save(item.copyWith(sortOrder: sortOrder));
      }
    }
  }

  /// Saves [next] (a placement of [previous]) and notes it in the activity
  /// line; a waiting item that comes back is noted as resolved, too.
  Future<Item> _placed(Item previous, Item next, ItemEventKind kind) async {
    final saved = await _items.save(next);
    if (previous.status == ItemStatus.waiting &&
        (next.status == ItemStatus.done || next.status == ItemStatus.active)) {
      await _events?.log(saved.id, ItemEventKind.resolved);
    }
    return _log(saved, kind);
  }

  Future<Item> _log(Item item, ItemEventKind kind) async {
    await _events?.log(item.id, kind);
    return item;
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
