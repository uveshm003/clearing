import 'package:clearing/domain/links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finds phones, emails and links in order', () {
    final links = findLinks(
      'Call +91 98765 43210 or email sam@example.com. Form: https://example.org/form.',
    );
    expect(links.map((l) => l.kind), [
      LinkKind.phone,
      LinkKind.email,
      LinkKind.web,
    ]);
    expect(links[0].uri.toString(), 'tel:+919876543210');
    expect(links[1].uri.toString(), 'mailto:sam@example.com');
    expect(links[2].uri.toString(), 'https://example.org/form');
  });

  test('www links get https', () {
    expect(
      findLinks('see www.example.com').single.uri.toString(),
      'https://www.example.com',
    );
  });

  test('dates, prices and short numbers are not phones', () {
    expect(findLinks('Due 2026-10-21, costs 1200, room 42'), isEmpty);
  });
}
