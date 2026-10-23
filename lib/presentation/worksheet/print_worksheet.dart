import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/providers.dart';
import '../../data/worksheet.dart';
import '../../domain/local_date.dart';

/// Fonts for other scripts that Android phones usually carry. TrueType only:
/// the PDF library can't embed CFF fonts, so any that fail to load are
/// skipped and those characters print as boxes.
const _systemFallbacks = [
  '/system/fonts/NotoSansDevanagari-Regular.ttf',
  '/system/fonts/NotoSansBengali-Regular.ttf',
  '/system/fonts/NotoSansTamil-Regular.ttf',
  '/system/fonts/NotoNaskhArabic-Regular.ttf',
  '/system/fonts/NotoSansHebrew-Regular.ttf',
  '/system/fonts/NotoSansThai-Regular.ttf',
];

Future<WorksheetFonts> loadWorksheetFonts() async {
  Future<pw.Font> asset(String name) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$name'));
  final fallback = <pw.Font>[await asset('Roboto-Regular.ttf')];
  if (!kIsWeb && Platform.isAndroid) {
    for (final path in _systemFallbacks) {
      try {
        final bytes = await File(path).readAsBytes();
        fallback.add(pw.Font.ttf(ByteData.sublistView(bytes)));
      } on Object {
        // Not on this phone, or not a font the PDF library can embed.
      }
    }
  }
  return WorksheetFonts(
    regular: await asset('AtkinsonHyperlegibleNext-Regular.ttf'),
    bold: await asset('AtkinsonHyperlegibleNext-Bold.ttf'),
    display: await asset('Fraunces-SemiBold.ttf'),
    fallback: fallback,
  );
}

/// The data a worksheet prints, as of now.
WorksheetData worksheetData(WidgetRef ref) => WorksheetData(
  items: ref.read(openItemsProvider).value ?? const [],
  today:
      ref.read(todayProvider).value ?? LocalDate.fromDateTime(DateTime.now()),
  blocks: ref.read(blocksProvider).value ?? const [],
  listNames: {
    for (final list in ref.read(listsProvider).value ?? const [])
      list.id: list.name,
  },
  weekStart: ref.read(settingsProvider).value?.weekStart ?? DateTime.monday,
);

/// Asks which worksheet, then opens the system print dialog, which also
/// offers "Save as PDF" (FR-19).
Future<void> printWorksheet(BuildContext context, WidgetRef ref) async {
  final kind = await showModalBottomSheet<WorksheetKind>(
    context: context,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Print a worksheet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: const Text('Today'),
              subtitle: const Text(
                'Must-dos, today, this week, and room to '
                'jot things down',
              ),
              onTap: () => Navigator.pop(context, WorksheetKind.day),
            ),
            ListTile(
              leading: const Icon(Icons.view_week_outlined),
              title: const Text('This week'),
              subtitle: const Text('A box for each day'),
              onTap: () => Navigator.pop(context, WorksheetKind.week),
            ),
          ],
        ),
      ),
    ),
  );
  if (kind == null) return;
  final data = worksheetData(ref);
  final fonts = await loadWorksheetFonts();
  await Printing.layoutPdf(
    name: kind == WorksheetKind.day ? 'Clearing – today' : 'Clearing – week',
    onLayout: (format) =>
        buildWorksheet(kind, data, format: format, fonts: fonts),
  );
}
