import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/glade.dart';
import '../../domain/grove.dart';

/// The Grove's drawing grid; the painting scales to fit.
const groveSize = Size(400, 260);

/// An element and where it stands, on the [groveSize] grid.
typedef Placed = ({GroveElement element, Offset at, double size});

/// Where everything in [grove] goes. Each element's place comes from its
/// own id, so the Grove looks the same every visit and only ever gains.
List<Placed> layoutGrove(GroveState grove) {
  final placed = <Placed>[];
  final taken = <Offset>[];

  Offset spot(int seed, Rect band, double gap) {
    final random = Random(seed);
    var best = Offset(
      band.left + random.nextDouble() * band.width,
      band.top + random.nextDouble() * band.height,
    );
    // A few tries for a spot not too close to anything else.
    for (var attempt = 0; attempt < 8; attempt++) {
      if (taken.every((t) => (t - best).distance >= gap)) break;
      best = Offset(
        band.left + random.nextDouble() * band.width,
        band.top + random.nextDouble() * band.height,
      );
    }
    taken.add(best);
    return best;
  }

  List<GroveElement> drawn(GroveKind kind) {
    final all = grove.elements.where((e) => e.kind == kind).toList();
    final max = maxDrawn[kind];
    return max == null || all.length <= max
        ? all
        : all.sublist(all.length - max);
  }

  // Back to front, so nearer things paint over farther ones.
  for (final e in drawn(GroveKind.oldTree)) {
    placed.add((
      element: e,
      at: spot(e.seed, const Rect.fromLTWH(10, 128, 380, 22), 14),
      size: 26,
    ));
  }
  for (final e in drawn(GroveKind.tree)) {
    placed.add((
      element: e,
      at: spot(e.seed, const Rect.fromLTWH(20, 160, 360, 30), 26),
      size: 30.0 + e.growth * 14,
    ));
  }
  for (final e in drawn(GroveKind.bird)) {
    placed.add((
      element: e,
      at: spot(e.seed, const Rect.fromLTWH(30, 18, 260, 70), 18),
      size: 8,
    ));
  }
  final cairns = drawn(GroveKind.cairn)
    ..sort((a, b) => (a.date ?? b.date!).compareTo(b.date ?? a.date!));
  for (final (i, e) in cairns.indexed) {
    // Along the path, alternating sides, nearer as the season goes on.
    final t = cairns.length == 1 ? 0.5 : i / (cairns.length - 1);
    final y = 175 + t * 65;
    final x = _pathX(y) + (i.isEven ? -26 : 26);
    taken.add(Offset(x, y));
    placed.add((
      element: e,
      at: Offset(x, y),
      size: 10.0 + min(e.count, 8) * 2,
    ));
  }
  for (final (i, e) in drawn(GroveKind.steppingStone).indexed) {
    final y = 250 - i * 9.0;
    placed.add((element: e, at: Offset(_pathX(y), y), size: 8));
  }
  for (final (i, e) in drawn(GroveKind.lantern).indexed) {
    final y = 190.0 + (i * 13) % 60;
    final x = _pathX(y) + (i.isEven ? 44 : -44);
    taken.add(Offset(x, y));
    placed.add((element: e, at: Offset(x, y), size: 14));
  }
  for (final e in drawn(GroveKind.bench)) {
    placed.add((element: e, at: const Offset(262, 214), size: 22));
  }
  for (final e in drawn(GroveKind.stream)) {
    placed.add((element: e, at: const Offset(70, 222), size: 30));
  }
  for (final e in drawn(GroveKind.wildflower)) {
    placed.add((
      element: e,
      at: spot(e.seed, const Rect.fromLTWH(14, 228, 372, 26), 12),
      size: 9,
    ));
  }
  return placed;
}

/// The path's centre at height [y]: from the front, curving to the horizon.
double _pathX(double y) => 200 + sin((y - 150) / 40) * 18;

/// The element nearest [point] (on the grid), if one is close enough.
Placed? hitGrove(List<Placed> placed, Offset point) {
  Placed? best;
  var bestDistance = 22.0;
  for (final p in placed) {
    final distance = (p.at.translate(0, -p.size / 2) - point).distance;
    if (distance < bestDistance) {
      best = p;
      bestDistance = distance;
    }
  }
  return best;
}

/// Paints the Grove: Glade's single-tone line art, dressed for the season.
class GrovePainter extends CustomPainter {
  GrovePainter({
    required this.placed,
    required this.season,
    required this.glade,
    required this.scheme,
    this.monsoon = false,
    this.highlight,
  });

  final List<Placed> placed;
  final Season season;
  final GladeTokens glade;
  final ColorScheme scheme;

  /// The wet season as a monsoon rather than a spring.
  final bool monsoon;

  /// The element last tapped, drawn with a dawn ring.
  final String? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(
      size.width / groveSize.width,
      size.height / groveSize.height,
    );
    canvas
      ..save()
      ..translate(
        (size.width - groveSize.width * scale) / 2,
        (size.height - groveSize.height * scale) / 2,
      )
      ..scale(scale);

    final line = Paint()
      ..color = glade.art
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final soft = Paint()..color = glade.artSoft;
    final warm = Paint()..color = glade.dawn.withValues(alpha: 0.85);
    final leaf = Paint()
      ..color = switch (season) {
        Season.autumn => glade.dawn.withValues(alpha: 0.55),
        Season.winter => scheme.surface,
        _ => glade.skyFull,
      };

    // Sky and sun.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & groveSize,
        const Radius.circular(18),
      ),
      Paint()..color = Color.lerp(glade.skyClear, glade.skyFull, 0.35)!,
    );
    _sun(canvas, warm, line, const Offset(330, 70), 20);
    if (monsoon && season == Season.spring) _rain(canvas, line);
    if (season == Season.winter) _snowfall(canvas);

    // Hills and ground.
    final hills = Path()
      ..moveTo(0, 150)
      ..cubicTo(80, 120, 140, 160, 210, 140)
      ..cubicTo(280, 122, 340, 150, 400, 136)
      ..lineTo(400, 260)
      ..lineTo(0, 260)
      ..close();
    canvas
      ..drawPath(hills, soft)
      ..drawPath(
        Path()
          ..moveTo(0, 150)
          ..cubicTo(80, 120, 140, 160, 210, 140)
          ..cubicTo(280, 122, 340, 150, 400, 136),
        line,
      );

    // The path from the front to the horizon.
    final left = Path()..moveTo(_pathX(258) - 22, 258);
    final right = Path()..moveTo(_pathX(258) + 22, 258);
    for (var y = 250.0; y >= 150; y -= 10) {
      final half = 4 + (y - 150) / 108 * 18;
      left.lineTo(_pathX(y) - half, y);
      right.lineTo(_pathX(y) + half, y);
    }
    canvas
      ..drawPath(left, line)
      ..drawPath(right, line);

    for (final p in placed) {
      final e = p.element;
      switch (e.kind) {
        case GroveKind.oldTree:
          _tree(
            canvas,
            line..strokeWidth = 1.2,
            leaf,
            p.at,
            p.size,
            faded: true,
          );
          line.strokeWidth = 1.6;
        case GroveKind.tree:
          _tree(canvas, line, leaf, p.at, p.size);
          if (season == Season.spring && !monsoon) {
            _blossom(canvas, warm, p.at, p.size, e.seed);
          }
        case GroveKind.bird:
          _bird(canvas, line, p.at, p.size);
        case GroveKind.cairn:
          _cairn(canvas, line, soft, p.at, e.count);
        case GroveKind.steppingStone:
          canvas.drawOval(
            Rect.fromCenter(center: p.at, width: 12, height: 5),
            line,
          );
        case GroveKind.lantern:
          _lantern(canvas, line, warm, p.at);
        case GroveKind.bench:
          _bench(canvas, line, p.at);
        case GroveKind.stream:
          _stream(canvas, line);
        case GroveKind.wildflower:
          _flower(canvas, line, warm, p.at, e.seed);
      }
      if (e.id == highlight) {
        canvas.drawCircle(
          p.at.translate(0, -p.size / 2),
          p.size / 2 + 8,
          Paint()
            ..color = glade.dawn
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
    canvas.restore();
  }

  void _sun(Canvas canvas, Paint warm, Paint line, Offset c, double r) {
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), pi, pi, true, warm);
    for (var i = 0; i < 5; i++) {
      final a = pi + pi * (i + 0.5) / 5;
      canvas.drawLine(
        c + Offset(cos(a), sin(a)) * (r + 5),
        c + Offset(cos(a), sin(a)) * (r + 11),
        line,
      );
    }
  }

  void _rain(Canvas canvas, Paint line) {
    final rain = Paint()
      ..color = glade.art.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final random = Random(7);
    for (var i = 0; i < 40; i++) {
      final x = random.nextDouble() * 400;
      final y = random.nextDouble() * 120;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 9), rain);
    }
  }

  void _snowfall(Canvas canvas) {
    final snow = Paint()..color = glade.art.withValues(alpha: 0.3);
    final random = Random(11);
    for (var i = 0; i < 36; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * 400, random.nextDouble() * 140),
        1.4,
        snow,
      );
    }
  }

  void _tree(
    Canvas canvas,
    Paint line,
    Paint leaf,
    Offset base,
    double height, {
    bool faded = false,
  }) {
    final w = height * 0.42;
    final stroke = faded
        ? (Paint()
            ..color = glade.art.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = line.strokeWidth
            ..strokeJoin = StrokeJoin.round)
        : line;
    canvas.drawLine(base, base.translate(0, -height * 0.18), stroke);
    for (var tier = 0; tier < 3; tier++) {
      final y = base.dy - height * (0.18 + tier * 0.24);
      final tw = w * (1 - tier * 0.25);
      final tri = Path()
        ..moveTo(base.dx - tw / 2, y)
        ..lineTo(base.dx, y - height * 0.36)
        ..lineTo(base.dx + tw / 2, y)
        ..close();
      if (!faded) canvas.drawPath(tri, leaf);
      canvas.drawPath(tri, stroke);
    }
    if (season == Season.winter) {
      // Snow on the top tier.
      canvas.drawLine(
        base.translate(-w * 0.12, -height * 0.78),
        base.translate(w * 0.12, -height * 0.78),
        Paint()
          ..color = scheme.surface
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _blossom(
    Canvas canvas,
    Paint warm,
    Offset base,
    double height,
    int seed,
  ) {
    final random = Random(seed);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        base.translate(
          (random.nextDouble() - 0.5) * height * 0.35,
          -height * (0.3 + random.nextDouble() * 0.5),
        ),
        1.8,
        warm,
      );
    }
  }

  void _bird(Canvas canvas, Paint line, Offset c, double s) {
    final bird = Path()
      ..moveTo(c.dx - s, c.dy)
      ..quadraticBezierTo(c.dx - s / 2, c.dy - s / 2, c.dx, c.dy)
      ..quadraticBezierTo(c.dx + s / 2, c.dy - s / 2, c.dx + s, c.dy);
    canvas.drawPath(bird, line);
  }

  void _cairn(Canvas canvas, Paint line, Paint soft, Offset base, int count) {
    var y = base.dy;
    final stones = min(count, 8);
    for (var i = 0; i < stones; i++) {
      final w = 14.0 - i * 1.3;
      final h = 5.0;
      final rect = Rect.fromCenter(
        center: Offset(base.dx, y - h / 2),
        width: w,
        height: h,
      );
      canvas
        ..drawOval(rect, soft)
        ..drawOval(rect, line);
      y -= h - 0.5;
    }
  }

  void _lantern(Canvas canvas, Paint line, Paint warm, Offset base) {
    canvas
      ..drawLine(base, base.translate(0, -16), line)
      ..drawCircle(base.translate(0, -19), 3.5, warm)
      ..drawCircle(base.translate(0, -19), 3.5, line);
  }

  void _bench(Canvas canvas, Paint line, Offset c) {
    canvas
      ..drawLine(c.translate(-14, -8), c.translate(14, -8), line)
      ..drawLine(c.translate(-14, -14), c.translate(14, -14), line)
      ..drawLine(c.translate(-11, -8), c.translate(-11, 0), line)
      ..drawLine(c.translate(11, -8), c.translate(11, 0), line);
  }

  void _stream(Canvas canvas, Paint line) {
    final water = Paint()
      ..color = glade.skyFull.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final stream = Path()
      ..moveTo(0, 214)
      ..cubicTo(40, 204, 70, 232, 120, 220)
      ..cubicTo(150, 212, 160, 236, 178, 244);
    canvas
      ..drawPath(stream, water)
      ..drawPath(stream, line..strokeWidth = 1);
    line.strokeWidth = 1.6;
  }

  void _flower(Canvas canvas, Paint line, Paint warm, Offset base, int seed) {
    final lean = (Random(seed).nextDouble() - 0.5) * 4;
    final head = base.translate(lean, -9);
    canvas.drawLine(base, head, line);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5;
      canvas.drawCircle(head + Offset(cos(a), sin(a)) * 2.6, 1.6, warm);
    }
    canvas.drawCircle(head, 1.2, line);
  }

  @override
  bool shouldRepaint(GrovePainter old) =>
      old.placed != placed ||
      old.season != season ||
      old.glade != glade ||
      old.monsoon != monsoon ||
      old.highlight != highlight;
}
