import 'item.dart';

/// Common words that say nothing about where a thing belongs.
const _stopWords = {
  'the',
  'and',
  'for',
  'with',
  'from',
  'about',
  'call',
  'get',
  'buy',
  'make',
  'book',
  'send',
  'check',
  'find',
  'new',
  'some',
  'this',
  'that',
  'into',
  'का',
  'की',
  'के',
  'को',
  'और',
  'में',
  'से',
  'पर',
};

Iterable<String> _words(String title) => title
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}\p{M}]+', unicode: true))
    .where((w) => w.length >= 3 && !_stopWords.contains(w));

/// The list that things like [title] have usually been filed in (§4.5),
/// from the user's own items: "milk" → Errands. Null without a clear
/// winner; purely local.
String? suggestList(String title, Iterable<Item> history) {
  final words = _words(title).toSet();
  if (words.isEmpty) return null;
  final hits = <String, int>{};
  for (final item in history) {
    final listId = item.listId;
    if (listId == null) continue;
    if (_words(item.title).any(words.contains)) {
      hits[listId] = (hits[listId] ?? 0) + 1;
    }
  }
  if (hits.isEmpty) return null;
  final ranked = hits.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final best = ranked.first;
  if (best.value < 2) return null;
  if (ranked.length > 1 && ranked[1].value * 2 > best.value) return null;
  return best.key;
}
