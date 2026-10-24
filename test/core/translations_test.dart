import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every language has every string (§7): a missing key would show English
/// in the middle of a translated screen. Also the Android widget strings.
void main() {
  final dir = Directory('lib/l10n/arb');
  final template =
      jsonDecode(File('${dir.path}/app_en.arb').readAsStringSync())
          as Map<String, Object?>;
  final keys = {
    for (final key in template.keys)
      if (!key.startsWith('@')) key,
  };
  final translations = [
    for (final file in dir.listSync().whereType<File>())
      if (file.path.endsWith('.arb') && !file.path.endsWith('app_en.arb')) file,
  ];

  test('there is at least one translation', () {
    expect(translations, isNotEmpty);
  });

  for (final file in translations) {
    test('${file.uri.pathSegments.last} has every string', () {
      final arb = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final missing = keys.difference(arb.keys.toSet())..remove('@@locale');
      expect(missing, isEmpty, reason: 'Missing: ${missing.join(', ')}');
      final empty = [
        for (final key in keys)
          if (arb[key] is String && (arb[key] as String).trim().isEmpty) key,
      ];
      expect(empty, isEmpty, reason: 'Empty: ${empty.join(', ')}');
    });

    test('${file.uri.pathSegments.last} keeps every placeholder', () {
      final arb = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      for (final key in keys) {
        final translated = '${arb[key]}';
        final meta = template['@$key'];
        final placeholders = meta is Map ? meta['placeholders'] : null;
        final wanted = placeholders is Map
            ? placeholders.keys.cast<String>()
            : const <String>[];
        for (final name in wanted) {
          expect(
            translated.contains('{$name'),
            isTrue,
            reason: '$key lost {$name}',
          );
        }
      }
    });
  }

  test('the Android widget strings are translated too', () {
    final names = RegExp(r'name="(\w+)"');
    Set<String> read(String path) => {
      for (final m in names.allMatches(File(path).readAsStringSync())) m[1]!,
    };
    final english = read('android/app/src/main/res/values/strings.xml');
    for (final dir in Directory('android/app/src/main/res').listSync()) {
      final file = File('${dir.path}/strings.xml');
      if (!dir.path.contains('values-') || !file.existsSync()) continue;
      expect(
        english.difference(read(file.path)),
        isEmpty,
        reason: '${dir.path} is missing widget strings',
      );
    }
  });
}
