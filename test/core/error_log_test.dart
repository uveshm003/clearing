import 'dart:io';

import 'package:clearing/core/error_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records, formats and clears errors in memory', () async {
    final log = ErrorLog();
    expect(await log.count(), 0);
    await log.record(
      StateError('Bad state'),
      StackTrace.fromString('#0 main (file.dart:1)\n#1 run (file.dart:2)'),
      at: DateTime(2026, 10, 21, 9),
    );
    expect(await log.count(), 1);
    final text = await log.asText();
    expect(text, contains('StateError: Bad state: Bad state'));
    expect(text, contains('#0 main'));
    await log.clear();
    expect(await log.count(), 0);
  });

  test('keeps only the last entries and trims long messages', () async {
    final log = ErrorLog();
    for (var i = 0; i < ErrorLog.maxEntries + 5; i++) {
      await log.record('error $i ${'x' * 500}', null);
    }
    expect(await log.count(), ErrorLog.maxEntries);
    final text = await log.asText();
    expect(text, isNot(contains('error 0 ')));
    expect(text, contains('…'));
  });

  test('survives on disk across opens', () async {
    final dir = await Directory.systemTemp.createTemp('clearing-log');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/nested/errors.log');
    await ErrorLog(file).record(ArgumentError('x'), null);
    expect(await ErrorLog(file).count(), 1);
  });
}
