import 'package:flutter/material.dart';

import 'glade.dart';

/// The Glade theme (see `lib/core/glade.dart`): warm birch paper by day,
/// forest night after dark, moss for action and one dawn accent.
///
/// The colour scheme is built by hand from Glade's tokens rather than from a
/// seed, so the contrast ratios checked for each pair hold exactly. There is
/// no red: status is never conveyed by alarm colours, and colour is always
/// paired with text or an icon (FR-20).
abstract final class AppTheme {
  static ThemeData light() => _build(_morning, GladeTokens.morning);
  static ThemeData dark() => _build(_dusk, GladeTokens.dusk);

  static const _morning = ColorScheme(
    brightness: Brightness.light,
    primary: GladePalette.moss,
    onPrimary: GladePalette.onMoss,
    primaryContainer: GladePalette.fern,
    onPrimaryContainer: GladePalette.onFern,
    secondary: GladePalette.moss,
    onSecondary: GladePalette.onMoss,
    secondaryContainer: GladePalette.fern,
    onSecondaryContainer: GladePalette.onFern,
    tertiary: GladePalette.lichen,
    onTertiary: GladePalette.birch,
    tertiaryContainer: GladePalette.barkPaperHigh,
    onTertiaryContainer: GladePalette.bark,
    // Errors are calm: bark words on paper, with an icon and plain words.
    error: GladePalette.bark,
    onError: GladePalette.birch,
    errorContainer: GladePalette.barkPaperHigh,
    onErrorContainer: GladePalette.bark,
    surface: GladePalette.birch,
    onSurface: GladePalette.bark,
    onSurfaceVariant: GladePalette.lichen,
    surfaceContainerLowest: GladePalette.birch,
    surfaceContainerLow: Color(0xFFF1EDE5),
    surfaceContainer: GladePalette.barkPaper,
    surfaceContainerHigh: GladePalette.barkPaperHigh,
    surfaceContainerHighest: Color(0xFFDCD7CA),
    outline: GladePalette.fog,
    outlineVariant: GladePalette.fogSoft,
    inverseSurface: GladePalette.bark,
    onInverseSurface: GladePalette.birch,
    inversePrimary: GladePalette.nightMoss,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0x00000000),
  );

  static const _dusk = ColorScheme(
    brightness: Brightness.dark,
    primary: GladePalette.nightMoss,
    onPrimary: GladePalette.onNightMoss,
    primaryContainer: GladePalette.nightFern,
    onPrimaryContainer: GladePalette.onNightFern,
    secondary: GladePalette.nightMoss,
    onSecondary: GladePalette.onNightMoss,
    secondaryContainer: GladePalette.nightFern,
    onSecondaryContainer: GladePalette.onNightFern,
    tertiary: GladePalette.nightLichen,
    onTertiary: GladePalette.forestNight,
    tertiaryContainer: GladePalette.nightPaperHigh,
    onTertiaryContainer: GladePalette.mist,
    error: GladePalette.mist,
    onError: GladePalette.forestNight,
    errorContainer: GladePalette.nightPaperHigh,
    onErrorContainer: GladePalette.mist,
    surface: GladePalette.forestNight,
    onSurface: GladePalette.mist,
    onSurfaceVariant: GladePalette.nightLichen,
    surfaceContainerLowest: Color(0xFF0E1411),
    surfaceContainerLow: Color(0xFF17201B),
    surfaceContainer: GladePalette.nightPaper,
    surfaceContainerHigh: GladePalette.nightPaperHigh,
    surfaceContainerHighest: Color(0xFF303B35),
    outline: GladePalette.nightFog,
    outlineVariant: GladePalette.nightFogSoft,
    inverseSurface: GladePalette.mist,
    onInverseSurface: GladePalette.forestNight,
    inversePrimary: GladePalette.moss,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0x00000000),
  );

  /// Display and headline in Fraunces; everything else in Atkinson
  /// Hyperlegible Next. Sizes are in sp, so they follow the text-size
  /// setting.
  static TextTheme _text(Color ink) {
    const display = GladeFonts.display;
    TextStyle serif(double size, double height) => TextStyle(
      fontFamily: display,
      fontSize: size,
      height: height / size,
      fontWeight: FontWeight.w600,
      color: ink,
    );
    TextStyle sans(double size, double height, FontWeight weight) => TextStyle(
      fontFamily: GladeFonts.body,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: ink,
    );
    return TextTheme(
      displayLarge: serif(40, 48),
      displayMedium: serif(34, 40),
      displaySmall: serif(30, 36),
      headlineLarge: serif(28, 34),
      headlineMedium: serif(26, 32),
      headlineSmall: serif(24, 30),
      titleLarge: sans(20, 26, FontWeight.w700),
      titleMedium: sans(18, 24, FontWeight.w700),
      titleSmall: sans(15, 20, FontWeight.w700),
      bodyLarge: sans(17, 26, FontWeight.w400),
      bodyMedium: sans(16, 24, FontWeight.w400),
      bodySmall: sans(13, 18, FontWeight.w400),
      labelLarge: sans(14, 20, FontWeight.w700),
      labelMedium: sans(13, 18, FontWeight.w700),
      labelSmall: sans(12, 16, FontWeight.w700),
    );
  }

  static ThemeData _build(ColorScheme scheme, GladeTokens glade) {
    final text = _text(scheme.onSurface);
    const pebble = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(GladeSpace.pebble)),
    );
    const stadium = StadiumBorder();
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: GladeFonts.body,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [glade],
      // Elevation by tone, not shadow.
      shadowColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleTextStyle: text.headlineSmall,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        // The one soft shadow in Glade: the capture button.
        elevation: 2,
        highlightElevation: 3,
        shape: const CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: pebble,
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.bodyMedium,
        subtitleTextStyle: text.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(GladeSpace.md)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: stadium,
          minimumSize: const Size(64, 48),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: stadium,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: stadium,
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: stadium,
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GladeSpace.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(GladeSpace.sheet)),
        ),
        titleTextStyle: text.headlineSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(GladeSpace.md)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHigh,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
