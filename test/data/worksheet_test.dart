import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clearing/data/worksheet.dart';
import 'package:clearing/domain/batch_block.dart';
import 'package:clearing/domain/enums.dart';
import 'package:clearing/domain/item.dart';
import 'package:clearing/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  final now = DateTime(2026, 10, 21, 9);
  final today = LocalDate.fromDateTime(now);
  late WorksheetFonts fonts;

  setUpAll(() {
    pw.Font load(String name) => pw.Font.ttf(
      ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync()),
    );
    fonts = WorksheetFonts(
      regular: load('Roboto-Regular.ttf'),
      bold: load('Roboto-Bold.ttf'),
    );
  });

  var seq = 0;
  Item item(
    String title, {
    LocalDate? doDate,
    WhenHorizon? horizon,
    bool mustDo = false,
  }) {
    final n = seq++;
    return Item(
      id: 'i$n',
      title: title,
      status: ItemStatus.active,
      doDate: doDate,
      horizon: horizon,
      horizonSetOn: horizon == null ? null : today,
      doTime: n.isEven && doDate != null ? 9 * 60 + n : null,
      mustDo: mustDo,
      createdAt: now,
      updatedAt: now,
    );
  }

  int pages(Uint8List pdf) =>
      RegExp(r'/Type\s*/Page\b(?!s)').allMatches(latin1.decode(pdf)).length;

  final busy = WorksheetData(
    today: today,
    items: [
      for (var i = 0; i < 3; i++) item('Must $i', doDate: today, mustDo: true),
      for (var i = 0; i < 60; i++) item('Also “quoted” – $i', doDate: today),
      for (var i = 0; i < 30; i++)
        item('Week $i', horizon: WhenHorizon.thisWeek),
      for (var d = 0; d < 7; d++)
        for (var i = 0; i < 15; i++)
          item('Day $d · $i', doDate: today.addDays(d - 2)),
    ],
    blocks: const [
      BatchBlock(id: 'b', listId: 'l', weekday: DateTime.wednesday, time: 600),
    ],
    listNames: const {'l': 'Errands'},
  );

  for (final (name, format) in [
    ('A4', PdfPageFormat.a4),
    ('Letter', PdfPageFormat.letter),
  ]) {
    for (final kind in WorksheetKind.values) {
      test('a busy ${kind.name} worksheet fits on one $name page', () async {
        final pdf = await buildWorksheet(
          kind,
          busy,
          format: format,
          fonts: fonts,
        );
        expect(pdf.sublist(0, 5), utf8.encode('%PDF-'));
        expect(pages(pdf), 1);
      });
    }
  }

  test('an empty day still prints, all capture lines', () async {
    final pdf = await buildWorksheet(
      WorksheetKind.day,
      WorksheetData(items: const [], today: today),
      format: PdfPageFormat.a4,
      fonts: fonts,
    );
    expect(pages(pdf), 1);
  });
}
