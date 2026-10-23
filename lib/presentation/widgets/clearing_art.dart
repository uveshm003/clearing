import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/glade.dart';

/// The empty-state drawings: single-tone line art of a forest clearing,
/// painted in code so they cost no download and stay sharp at any size.
enum ClearingScene {
  /// An open clearing at sunrise: nothing on Today.
  clearing,

  /// An empty nest: the Inbox has nothing waiting.
  nest,

  /// A path into the trees: ideas parked for Someday.
  path,

  /// A cairn of stones: things done.
  cairn,

  /// A leaf drifting down: Trash.
  leaf,
}

/// Draws [scene] in the theme's art colours. Decorative: hidden from screen
/// readers, since the words under it carry the meaning.
class ClearingArt extends StatelessWidget {
  const ClearingArt(this.scene, {super.key, this.width = 176});

  final ClearingScene scene;
  final double width;

  @override
  Widget build(BuildContext context) {
    final glade = GladeTokens.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: width * 0.66,
        child: CustomPaint(
          painter: _ScenePainter(
            scene,
            line: glade.art,
            soft: glade.artSoft,
            sun: glade.dawn,
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(
    this.scene, {
    required this.line,
    required this.soft,
    required this.sun,
  });

  final ClearingScene scene;
  final Color line;
  final Color soft;
  final Color sun;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 176 × 116 grid, scaled to fit.
    final scale = size.width / 176;
    canvas.scale(scale);
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / scale.clamp(0.75, 1.5)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = soft;
    final warm = Paint()..color = sun.withValues(alpha: 0.85);

    switch (scene) {
      case ClearingScene.clearing:
        _ground(canvas, fill);
        _sun(canvas, warm, stroke, const Offset(88, 78), 18);
        _tree(canvas, stroke, const Offset(26, 96), 46);
        _tree(canvas, stroke, const Offset(46, 98), 34);
        _tree(canvas, stroke, const Offset(150, 96), 48);
        _tree(canvas, stroke, const Offset(130, 99), 30);
        canvas.drawLine(const Offset(70, 106), const Offset(84, 92), stroke);
        canvas.drawLine(const Offset(106, 106), const Offset(92, 92), stroke);
      case ClearingScene.nest:
        _ground(canvas, fill);
        final nest = Path()
          ..moveTo(52, 70)
          ..quadraticBezierTo(88, 112, 124, 70);
        canvas.drawPath(nest, stroke);
        for (var i = 0; i < 3; i++) {
          final y = 76.0 + i * 7;
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(88, y),
              width: 74 - i * 16.0,
              height: 18,
            ),
            0.2,
            pi - 0.4,
            false,
            stroke,
          );
        }
        _leafShape(canvas, stroke, const Offset(122, 46), 0.6);
        _leafShape(canvas, stroke, const Offset(54, 40), -0.5);
      case ClearingScene.path:
        _ground(canvas, fill);
        _tree(canvas, stroke, const Offset(34, 98), 52);
        _tree(canvas, stroke, const Offset(142, 98), 52);
        _tree(canvas, stroke, const Offset(118, 86), 30);
        final left = Path()
          ..moveTo(62, 108)
          ..cubicTo(80, 92, 70, 78, 86, 62);
        final right = Path()
          ..moveTo(110, 108)
          ..cubicTo(96, 92, 104, 78, 92, 62);
        canvas
          ..drawPath(left, stroke)
          ..drawPath(right, stroke);
        _sun(canvas, warm, stroke, const Offset(89, 44), 9);
      case ClearingScene.cairn:
        _ground(canvas, fill);
        final stones = [
          Rect.fromCenter(center: const Offset(88, 96), width: 64, height: 20),
          Rect.fromCenter(center: const Offset(88, 77), width: 46, height: 18),
          Rect.fromCenter(center: const Offset(88, 60), width: 32, height: 16),
          Rect.fromCenter(center: const Offset(88, 46), width: 18, height: 12),
        ];
        for (final stone in stones) {
          canvas.drawOval(stone, stroke);
        }
        canvas.drawCircle(const Offset(88, 46), 3, warm);
      case ClearingScene.leaf:
        _ground(canvas, fill);
        _leafShape(canvas, stroke, const Offset(88, 50), 0.4, size: 1.6);
        final drift = Path()
          ..moveTo(60, 30)
          ..cubicTo(70, 40, 56, 52, 66, 64);
        canvas.drawPath(
          drift,
          Paint()
            ..color = line.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.25
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _ground(Canvas canvas, Paint fill) => canvas.drawOval(
    Rect.fromCenter(center: const Offset(88, 104), width: 168, height: 22),
    fill,
  );

  void _sun(Canvas canvas, Paint warm, Paint stroke, Offset c, double r) {
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), pi, pi, true, warm);
    for (var i = 0; i < 5; i++) {
      final a = pi + pi * (i + 0.5) / 5;
      canvas.drawLine(
        c + Offset(cos(a), sin(a)) * (r + 5),
        c + Offset(cos(a), sin(a)) * (r + 10),
        stroke,
      );
    }
  }

  void _tree(Canvas canvas, Paint stroke, Offset base, double height) {
    final w = height * 0.42;
    canvas.drawLine(base, base.translate(0, -height * 0.18), stroke);
    for (var tier = 0; tier < 3; tier++) {
      final y = base.dy - height * (0.18 + tier * 0.24);
      final tw = w * (1 - tier * 0.25);
      final tri = Path()
        ..moveTo(base.dx - tw / 2, y)
        ..lineTo(base.dx, y - height * 0.36)
        ..lineTo(base.dx + tw / 2, y)
        ..close();
      canvas.drawPath(tri, stroke);
    }
  }

  void _leafShape(
    Canvas canvas,
    Paint stroke,
    Offset c,
    double angle, {
    double size = 1,
  }) {
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle)
      ..scale(size);
    final leaf = Path()
      ..moveTo(0, -14)
      ..quadraticBezierTo(10, 0, 0, 14)
      ..quadraticBezierTo(-10, 0, 0, -14);
    canvas
      ..drawPath(leaf, stroke)
      ..drawLine(const Offset(0, -10), const Offset(0, 18), stroke)
      ..restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene ||
      old.line != line ||
      old.soft != soft ||
      old.sun != sun;
}
