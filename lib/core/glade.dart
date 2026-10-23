import 'package:flutter/material.dart';

/// Glade, Clearing's theme: a forest clearing at first light.
///
/// Every colour, size and duration the UI uses comes from here. Colour
/// pairs were checked against WCAG: text pairs are 4.5:1 or better, outlines
/// 3:1 or better, in both brightnesses.
abstract final class GladePalette {
  // Morning (light).
  static const birch = Color(0xFFF6F3EC);
  static const barkPaper = Color(0xFFEDE9DF);
  static const barkPaperHigh = Color(0xFFE4DFD3);
  static const bark = Color(0xFF23241F);
  static const lichen = Color(0xFF5B5F55);
  static const moss = Color(0xFF2F5D48);
  static const onMoss = Color(0xFFFFFFFF);
  static const fern = Color(0xFFCFE3D3);
  static const onFern = Color(0xFF0F2B1F);
  static const dawn = Color(0xFFE9A23B);
  static const onDawn = Color(0xFF2A1C05);
  static const fog = Color(0xFF8A8E84);
  static const fogSoft = Color(0xFFD5D3CA);

  // Dusk (dark).
  static const forestNight = Color(0xFF131A16);
  static const nightPaper = Color(0xFF1C2520);
  static const nightPaperHigh = Color(0xFF26302A);
  static const mist = Color(0xFFE4E6DE);
  static const nightLichen = Color(0xFFB3B9AE);
  static const nightMoss = Color(0xFF9CCBB0);
  static const onNightMoss = Color(0xFF0B2418);
  static const nightFern = Color(0xFF244A38);
  static const onNightFern = Color(0xFFCFE9D9);
  static const nightDawn = Color(0xFFF2BC6B);
  static const nightFog = Color(0xFF899087);
  static const nightFogSoft = Color(0xFF3A443E);
}

/// Spacing steps (4 dp unit) and corner radii.
abstract final class GladeSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Side margin of screen content.
  static const gutter = 20.0;

  /// Below this width the gutter narrows to [lg].
  static const narrow = 360.0;

  /// Content never stretches wider than this in one column.
  static const maxColumn = 640.0;

  static const pebble = 20.0;
  static const sheet = 28.0;
}

/// Motion tokens. Read them through [GladeMotion.of], which honours the
/// phone's "remove animations" setting.
enum GladeMotion {
  /// Sheets opening, sections expanding.
  settle(Duration(milliseconds: 250), Curves.easeOutCubic),

  /// An item leaving a list after Done.
  mist(Duration(milliseconds: 350), Curves.easeOutCubic),

  /// Moving between steps of clarify, review and reset.
  step(Duration(milliseconds: 200), Curves.easeInOut),

  /// The Dawn underline on something just done.
  glow(Duration(milliseconds: 600), Curves.easeInOut);

  const GladeMotion(this.duration, this.curve);

  final Duration duration;
  final Curve curve;

  /// [duration], or zero when animations are switched off.
  Duration of(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : duration;
}

/// Glade's colours that Material's [ColorScheme] has no slot for.
@immutable
class GladeTokens extends ThemeExtension<GladeTokens> {
  const GladeTokens({
    required this.dawn,
    required this.onDawn,
    required this.dawnIsText,
    required this.skyClear,
    required this.skyFull,
    required this.art,
    required this.artSoft,
  });

  /// The one accent: focus, just done, the must-do star.
  final Color dawn;
  final Color onDawn;

  /// Whether [dawn] may be used as a text colour (only in Dusk: on light
  /// paper it reaches just 1.95:1, so there it is a fill or underline).
  final bool dawnIsText;

  /// Today's header band: [skyFull] with work ahead, [skyClear] once done.
  final Color skyClear;
  final Color skyFull;

  /// Line art for empty states.
  final Color art;
  final Color artSoft;

  static const morning = GladeTokens(
    dawn: GladePalette.dawn,
    onDawn: GladePalette.onDawn,
    dawnIsText: false,
    skyClear: GladePalette.birch,
    skyFull: GladePalette.fern,
    art: GladePalette.moss,
    artSoft: GladePalette.fogSoft,
  );

  static const dusk = GladeTokens(
    dawn: GladePalette.nightDawn,
    onDawn: GladePalette.onDawn,
    dawnIsText: true,
    skyClear: GladePalette.forestNight,
    skyFull: GladePalette.nightFern,
    art: GladePalette.nightMoss,
    artSoft: GladePalette.nightFogSoft,
  );

  static GladeTokens of(BuildContext context) =>
      Theme.of(context).extension<GladeTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dusk : morning);

  /// The sky band for [remaining] of [total] items left today. One step
  /// lighter for each item done; never the only signal (text says how many).
  Color sky({required int remaining, required int total}) {
    if (total <= 0 || remaining <= 0) return skyClear;
    return Color.lerp(skyClear, skyFull, remaining / total)!;
  }

  @override
  GladeTokens copyWith({
    Color? dawn,
    Color? onDawn,
    bool? dawnIsText,
    Color? skyClear,
    Color? skyFull,
    Color? art,
    Color? artSoft,
  }) => GladeTokens(
    dawn: dawn ?? this.dawn,
    onDawn: onDawn ?? this.onDawn,
    dawnIsText: dawnIsText ?? this.dawnIsText,
    skyClear: skyClear ?? this.skyClear,
    skyFull: skyFull ?? this.skyFull,
    art: art ?? this.art,
    artSoft: artSoft ?? this.artSoft,
  );

  @override
  GladeTokens lerp(GladeTokens? other, double t) {
    if (other == null) return this;
    return GladeTokens(
      dawn: Color.lerp(dawn, other.dawn, t)!,
      onDawn: Color.lerp(onDawn, other.onDawn, t)!,
      dawnIsText: t < 0.5 ? dawnIsText : other.dawnIsText,
      skyClear: Color.lerp(skyClear, other.skyClear, t)!,
      skyFull: Color.lerp(skyFull, other.skyFull, t)!,
      art: Color.lerp(art, other.art, t)!,
      artSoft: Color.lerp(artSoft, other.artSoft, t)!,
    );
  }
}

/// Font families bundled in `assets/fonts` (both SIL Open Font License).
abstract final class GladeFonts {
  /// Display and headline: warm, soft serif for a few large moments.
  static const display = 'Fraunces';

  /// Everything people read: designed for low vision.
  static const body = 'AtkinsonHyperlegibleNext';
}

/// The side margin for a screen [width] wide.
double gladeGutter(double width) =>
    width < GladeSpace.narrow ? GladeSpace.lg : GladeSpace.gutter;
