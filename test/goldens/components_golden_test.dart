@Tags(['golden'])
library;

import 'package:clearing/core/glade.dart';
import 'package:clearing/core/theme.dart';
import 'package:clearing/presentation/widgets/clearing_art.dart';
import 'package:clearing/presentation/widgets/glade_header.dart';
import 'package:clearing/presentation/widgets/pebble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_helpers.dart';

void main() {
  setUpAll(loadGladeFonts);

  for (final (name, theme) in [
    ('morning', AppTheme.light()),
    ('dusk', AppTheme.dark()),
  ]) {
    testWidgets('Glade components, $name', (tester) async {
      phoneSurface(tester, size: const Size(1080, 3000));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Builder(
            builder: (context) {
              final glade = GladeTokens.of(context);
              return Scaffold(
                body: SafeArea(
                  child: ListView(
                    children: [
                      GladeHeader(
                        title: 'Wednesday 21',
                        subtitle: '2 left today',
                        sky: glade.sky(remaining: 2, total: 5),
                      ),
                      Pebble(
                        highlight: true,
                        children: [
                          ListTile(
                            leading: Checkbox(value: false, onChanged: (_) {}),
                            title: const Text('Pay rent'),
                            subtitle: const Text('Life Admin'),
                            trailing: Icon(
                              Icons.star_rounded,
                              color: glade.dawn,
                            ),
                          ),
                          ListTile(
                            leading: Checkbox(value: true, onChanged: (_) {}),
                            title: const Text('Call the dentist'),
                            subtitle: const Text('14:00 · 2 of 3'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final scene in ClearingScene.values)
                            ClearingArt(scene, width: 120),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Done'),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Not now'),
                          ),
                          ActionChip(
                            label: const Text('Pay a bill'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('images/components_$name.png'),
      );
    });
  }
}
