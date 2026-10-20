import 'package:flutter/material.dart';

import '../application/canvas_transform.dart';
import '../domain/coloring_page.dart';
import '../domain/coloring_region.dart';
import '../domain/paint_stroke.dart';
import '../domain/point_2d.dart';

final class ColoringPainter extends CustomPainter {
  const ColoringPainter({required this.page, required this.strokes});

  final ColoringPage page;
  final List<PaintStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final transform = CanvasTransform.fitContain(
      motifSize: page.size,
      viewportSize: Size2D(size.width, size.height),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7F4FF),
    );
    canvas.save();
    canvas.translate(transform.offset.x, transform.offset.y);
    canvas.scale(transform.scale);

    final motifBounds = Rect.fromLTWH(0, 0, page.size.width, page.size.height);
    canvas.drawRect(motifBounds, Paint()..color = Colors.white);
    canvas.saveLayer(motifBounds, Paint());

    for (final stroke in strokes) {
      final region = page.regionById(stroke.regionId);
      canvas.save();
      canvas.clipPath(_paintablePathFor(region), doAntiAlias: true);
      _drawStroke(canvas, stroke);
      canvas.restore();
    }
    canvas.restore();

    final contourPaint = Paint()
      ..color = const Color(0xFF252333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    for (final region in page.regions) {
      canvas.drawPath(_pathFor(region), contourPaint);
    }
    canvas.restore();
  }

  Path _pathFor(ColoringRegion region) {
    final path = Path();
    final first = region.vertices.first;
    path.moveTo(first.x, first.y);
    for (final point in region.vertices.skip(1)) {
      path.lineTo(point.x, point.y);
    }
    return path..close();
  }

  Path _paintablePathFor(ColoringRegion region) {
    final path = _pathFor(region)..fillType = PathFillType.evenOdd;
    for (final candidate in page.regions) {
      if (candidate.id == region.id || candidate.area >= region.area) continue;
      if (candidate.vertices.every(region.contains)) {
        path.addPath(_pathFor(candidate), Offset.zero);
      }
    }
    return path;
  }

  void _drawStroke(Canvas canvas, PaintStroke stroke) {
    final opacity = switch (stroke.brushKind) {
      BrushKind.crayon => 0.72,
      BrushKind.softBrush => 0.48,
      _ => 1.0,
    };
    final paint = Paint()
      ..color = Color(stroke.colorArgb).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;
    final first = stroke.points.first;
    if (stroke.points.length == 1) {
      canvas.drawCircle(
        Offset(first.x, first.y),
        stroke.width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path()..moveTo(first.x, first.y);
    for (final point in stroke.points.skip(1)) {
      path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) =>
      oldDelegate.page != page || oldDelegate.strokes != strokes;
}
