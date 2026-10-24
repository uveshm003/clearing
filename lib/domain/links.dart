import 'package:meta/meta.dart';

enum LinkKind { phone, email, web }

/// Something in a note the phone can act on: call it, email it, open it.
@immutable
class FoundLink {
  const FoundLink(this.kind, this.text, this.uri);

  final LinkKind kind;

  /// As written in the note.
  final String text;
  final Uri uri;

  @override
  bool operator ==(Object other) =>
      other is FoundLink && other.kind == kind && other.uri == uri;

  @override
  int get hashCode => Object.hash(kind, uri);

  @override
  String toString() => 'FoundLink($kind, $uri)';
}

final _email = RegExp(r'[\w.+\-]+@[\w\-]+(\.[\w\-]+)+');
final _web = RegExp(r'''(https?://|www\.)[^\s<>"']+''', caseSensitive: false);
final _phone = RegExp(r'(?<![\w/])\+?\d[\d\s\-().]{6,}\d(?![\w/])');

/// Phone numbers, email addresses and web links in [text], in order. Opened
/// by the phone's own apps; nothing is fetched to preview them.
List<FoundLink> findLinks(String text) {
  final found = <(int, FoundLink)>[];
  final taken = <(int, int)>[];
  bool free(int start, int end) =>
      taken.every((t) => end <= t.$1 || start >= t.$2);

  for (final m in _web.allMatches(text)) {
    var raw = m[0]!.replaceAll(RegExp(r'[.,;:!?)]+$'), '');
    final uri = Uri.tryParse(raw.startsWith('www.') ? 'https://$raw' : raw);
    if (uri == null) continue;
    taken.add((m.start, m.start + raw.length));
    found.add((m.start, FoundLink(LinkKind.web, raw, uri)));
  }
  for (final m in _email.allMatches(text)) {
    if (!free(m.start, m.end)) continue;
    taken.add((m.start, m.end));
    found.add((
      m.start,
      FoundLink(LinkKind.email, m[0]!, Uri(scheme: 'mailto', path: m[0])),
    ));
  }
  for (final m in _phone.allMatches(text)) {
    if (!free(m.start, m.end)) continue;
    final digits = m[0]!.replaceAll(RegExp(r'[^\d+]'), '');
    // Dates like 2026-10-21 and short numbers aren't phone numbers.
    if (digits.replaceAll('+', '').length < 8) continue;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(m[0]!.trim())) continue;
    taken.add((m.start, m.end));
    found.add((
      m.start,
      FoundLink(LinkKind.phone, m[0]!.trim(), Uri(scheme: 'tel', path: digits)),
    ));
  }
  found.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final f in found) f.$2];
}
