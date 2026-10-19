import '../domain/point_2d.dart';

/// Aspect-fit transform between widget pixels and motif coordinates.
final class CanvasTransform {
  CanvasTransform.fitContain({
    required this.motifSize,
    required this.viewportSize,
  }) : scale = _scaleFor(motifSize, viewportSize),
       offset = _offsetFor(motifSize, viewportSize);

  final Size2D motifSize;
  final Size2D viewportSize;
  final double scale;
  final Point2D offset;

  static double _scaleFor(Size2D motif, Size2D viewport) {
    final widthScale = viewport.width / motif.width;
    final heightScale = viewport.height / motif.height;
    return widthScale < heightScale ? widthScale : heightScale;
  }

  static Point2D _offsetFor(Size2D motif, Size2D viewport) {
    final scale = _scaleFor(motif, viewport);
    return Point2D(
      (viewport.width - motif.width * scale) / 2,
      (viewport.height - motif.height * scale) / 2,
    );
  }

  Point2D motifToViewport(Point2D point) =>
      Point2D(offset.x + point.x * scale, offset.y + point.y * scale);

  Point2D? viewportToMotif(Point2D point) {
    final motifPoint = Point2D(
      (point.x - offset.x) / scale,
      (point.y - offset.y) / scale,
    );
    final isInside =
        motifPoint.x >= 0 &&
        motifPoint.y >= 0 &&
        motifPoint.x <= motifSize.width &&
        motifPoint.y <= motifSize.height;
    return isInside ? motifPoint : null;
  }
}
