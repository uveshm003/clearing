import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts and Material icons, so golden screenshots show
/// Glade as people see it rather than the test font's boxes.
Future<void> loadGladeFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }

  await family('Fraunces', ['Fraunces-SemiBold.ttf']);
  await family('AtkinsonHyperlegibleNext', [
    'AtkinsonHyperlegibleNext-Regular.ttf',
    'AtkinsonHyperlegibleNext-Bold.ttf',
  ]);
  // Unnamed text falls back to Roboto in tests, as on Android.
  await family('Roboto', ['Roboto-Regular.ttf', 'Roboto-Bold.ttf']);

  final sdk = Platform.environment['FLUTTER_ROOT'];
  final icons = File(
    '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (sdk != null && icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

/// A phone-sized surface: 1080 × 2340 px at 2.625, a typical mid-range phone.
void phoneSurface(WidgetTester tester, {Size size = const Size(1080, 2340)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}
