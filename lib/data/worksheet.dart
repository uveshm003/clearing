import 'dart:math';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/batch_block.dart';
import '../domain/calendar_rules.dart';
import '../domain/item.dart';
import '../domain/local_date.dart';
import '../domain/today_rules.dart';
import '../l10n/l10n.dart';

/// The two printable worksheets (FR-19).
enum WorksheetKind { day, week }

/// Fonts embedded in the PDF, matching the app: Glade's Atkinson
/// Hyperlegible for text and Fraunces for titles. [fallback] covers other
/// scripts (Roboto for Greek and Cyrillic, then whatever the phone has).
class WorksheetFonts {
  const WorksheetFonts({
    required this.regular,
    required this.bold,
    this.display,
    this.fallback = const [],
  });

  final pw.Font regular;
  final pw.Font bold;

  /// Titles; [bold] when absent.
  final pw.Font? display;
  final List<pw.Font> fallback;
}

/// What a worksheet shows: the open items, blocks and list names.
class WorksheetData {
  const WorksheetData({
    required this.items,
    required this.today,
    this.blocks = const [],
    this.listNames = const {},
    this.weekStart = DateTime.monday,
  });

  final List<Item> items;
  final LocalDate today;
  final List<BatchBlock> blocks;
  final Map<String, String> listNames;
  final int weekStart;
}

const _rowHeight = 20.0;
const _margin = 36.0;

/// Builds a one-page worksheet in [format] (A4 or Letter): lists are cut to
/// fit and the rest of the page becomes blank capture lines (FR-19).
Future<Uint8List> buildWorksheet(
  WorksheetKind kind,
  WorksheetData data, {
  required PdfPageFormat format,
  required WorksheetFonts fonts,
}) {
  final doc = pw.Document(
    title: kind == WorksheetKind.day
        ? l10n.worksheetDocToday
        : l10n.worksheetDocWeek,
    theme: pw.ThemeData.withFont(
      base: fonts.regular,
      bold: fonts.bold,
      fontFallback: fonts.fallback,
    ),
  );
  final page = format.copyWith(
    marginLeft: _margin,
    marginRight: _margin,
    marginTop: _margin,
    marginBottom: _margin,
  );
  doc.addPage(
    pw.Page(
      pageFormat: page,
      build: (context) => kind == WorksheetKind.day
          ? _day(data, page.availableHeight, fonts.display)
          : _week(data, page.availableHeight, fonts.display),
    ),
  );
  return doc.save();
}

pw.Widget _day(WorksheetData data, double height, pw.Font? display) {
  final today = data.today;
  final view = buildTodayView(data.items, today);
  final week = data.items.where(isThisWeek).toList();
  final blocks = data.blocks.where((b) => b.occursOn(today)).toList();

  const headerRows = 3;
  const minCaptureLines = 8;
  var budget = (height / _rowHeight).floor() - headerRows - minCaptureLines;

  final sections = <pw.Widget>[];
  void section(String title, List<String> lines) {
    if (lines.isEmpty || budget < 2) return;
    budget -= 1;
    final shown = lines.length <= budget ? lines : lines.take(budget - 1);
    final more = lines.length - shown.length;
    sections
      ..add(_heading(title))
      ..addAll(shown.map(_checkRow));
    budget -= shown.length;
    if (more > 0) {
      sections.add(_note(l10n.worksheetMoreInApp(more)));
      budget -= 1;
    }
  }

  section(l10n.mustDo, [for (final i in view.mustDo) _label(i)]);
  section(l10n.worksheetBlocks, [
    for (final b in blocks)
      '${data.listNames[b.listId] ?? l10n.worksheetList} · ${_time(b.time)}',
  ]);
  section(l10n.worksheetAlsoToday, [
    for (final i in view.alsoToday) _label(i),
    for (final i in view.carriedOver) l10n.worksheetCarriedOver(_label(i)),
  ]);
  section(l10n.whenThisWeek, [for (final i in week) _label(i)]);

  final capture = minCaptureLines + max(0, budget - 1);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _title(
        l10n.whenToday,
        DateFormat('EEEE d MMMM y').format(_dt(today)),
        display,
      ),
      ...sections,
      _heading(l10n.worksheetOnYourMind),
      for (var i = 0; i < capture - 1; i++) _blankLine(),
    ],
  );
}

pw.Widget _week(WorksheetData data, double height, pw.Font? display) {
  final start = data.today.startOfWeek(data.weekStart);
  final week = weekTimeline(data.items, weekStart: start, today: data.today);
  // Two columns of four boxes: seven days and "Any day / on your mind".
  final boxHeight = (height - 3 * _rowHeight) / 4;
  final rows = (boxHeight / _rowHeight).floor() - 1;

  pw.Widget box(String title, List<String> lines) {
    final shown = lines.length <= rows ? lines : lines.take(rows - 1).toList();
    final more = lines.length - shown.length;
    return pw.Container(
      height: boxHeight,
      padding: const pw.EdgeInsets.fromLTRB(6, 4, 6, 0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            height: _rowHeight,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          ...shown.map(_checkRow),
          if (more > 0) _note(l10n.worksheetMore(more)),
          for (var i = shown.length + (more > 0 ? 1 : 0); i < rows; i++)
            _blankLine(),
        ],
      ),
    );
  }

  final boxes = [
    for (final (:day, :items) in week.days)
      box(DateFormat('EEEE d').format(_dt(day)), [
        for (final b in data.blocks)
          if (b.occursOn(day))
            '${data.listNames[b.listId] ?? l10n.worksheetList} · ${_time(b.time)}',
        for (final i in items) _label(i),
      ]),
    box(l10n.worksheetAnyDay, [for (final i in week.anyDay) _label(i)]),
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _title(
        l10n.whenThisWeek,
        l10n.worksheetWeekOf(DateFormat('d MMMM y').format(_dt(start))),
        display,
      ),
      for (var r = 0; r < 4; r++)
        pw.Row(
          children: [
            pw.Expanded(child: boxes[r * 2]),
            pw.SizedBox(width: 8),
            pw.Expanded(child: boxes[r * 2 + 1]),
          ],
        ),
    ],
  );
}

String _label(Item item) =>
    [if (item.doTime case final t?) _time(t), item.title].join('  ');

String _time(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';

DateTime _dt(LocalDate d) => DateTime(d.year, d.month, d.day);

pw.Widget _title(String title, String subtitle, pw.Font? display) =>
    pw.SizedBox(
      height: 3 * _rowHeight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: display,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
        ],
      ),
    );

pw.Widget _heading(String text) => pw.Container(
  height: _rowHeight,
  alignment: pw.Alignment.bottomLeft,
  child: pw.Text(
    text,
    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
  ),
);

pw.Widget _checkRow(String text) => pw.SizedBox(
  height: _rowHeight,
  child: pw.Row(
    children: [
      pw.Container(
        width: 9,
        height: 9,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey700, width: 0.75),
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Expanded(
        child: pw.Text(
          text,
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
          style: const pw.TextStyle(fontSize: 10.5),
        ),
      ),
    ],
  ),
);

pw.Widget _note(String text) => pw.SizedBox(
  height: _rowHeight,
  child: pw.Text(
    text,
    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
  ),
);

pw.Widget _blankLine() => pw.Container(
  height: _rowHeight,
  decoration: const pw.BoxDecoration(
    border: pw.Border(
      bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
    ),
  ),
);
