import 'dart:math';

import 'package:clearing/core/glade.dart';
import 'package:clearing/core/theme.dart';
import 'package:clearing/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  final morning = AppTheme.light().colorScheme;
  final dusk = AppTheme.dark().colorScheme;

  test('list colours reach 3:1 on pebbles and pages, in both themes', () {
    for (final colour in ListColour.values) {
      for (final surface in [morning.surfaceContainer, morning.surface]) {
        expect(
          contrast(colour.morning, surface),
          greaterThanOrEqualTo(3),
          reason: '${colour.name} in Morning',
        );
      }
      for (final surface in [dusk.surfaceContainer, dusk.surface]) {
        expect(
          contrast(colour.dusk, surface),
          greaterThanOrEqualTo(3),
          reason: '${colour.name} in Dusk',
        );
      }
    }
  });

  test('every Glade variant keeps AA text and 3:1 accents', () {
    for (final variant in GladeVariant.values) {
      for (final contrastMode in [false, true]) {
        for (final theme in [
          AppTheme.light(variant: variant, highContrast: contrastMode),
          AppTheme.dark(variant: variant, highContrast: contrastMode),
        ]) {
          final s = theme.colorScheme;
          final name =
              '${variant.name} ${s.brightness.name}'
              '${contrastMode ? ' high contrast' : ''}';
          expect(
            contrast(s.onPrimary, s.primary),
            greaterThanOrEqualTo(4.5),
            reason: '$name onPrimary',
          );
          expect(
            contrast(s.onPrimaryContainer, s.primaryContainer),
            greaterThanOrEqualTo(4.5),
            reason: '$name onPrimaryContainer',
          );
          expect(
            contrast(s.onSurface, s.surface),
            greaterThanOrEqualTo(4.5),
            reason: '$name onSurface',
          );
          expect(
            contrast(s.onSurfaceVariant, s.surfaceContainer),
            greaterThanOrEqualTo(4.5),
            reason: '$name onSurfaceVariant',
          );
          expect(
            contrast(s.primary, s.surface),
            greaterThanOrEqualTo(3),
            reason: '$name primary on surface',
          );
          if (contrastMode) {
            expect(
              contrast(s.onSurfaceVariant, s.surface),
              greaterThanOrEqualTo(7),
              reason: '$name: high contrast reaches AAA text',
            );
          }
        }
      }
    }
  });
}
