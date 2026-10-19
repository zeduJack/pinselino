import 'point_2d.dart';

final class PaintStroke {
  PaintStroke({
    required this.regionId,
    required this.colorArgb,
    required this.width,
    required Iterable<Point2D> points,
  }) : points = List.unmodifiable(points) {
    if (regionId.isEmpty) {
      throw ArgumentError.value(regionId, 'regionId', 'must not be empty');
    }
    if (width <= 0) {
      throw ArgumentError.value(width, 'width', 'must be positive');
    }
    if (this.points.isEmpty) {
      throw ArgumentError.value(points, 'points', 'must not be empty');
    }
  }

  final String regionId;
  final int colorArgb;
  final double width;
  final List<Point2D> points;

  PaintStroke append(Point2D point) => PaintStroke(
    regionId: regionId,
    colorArgb: colorArgb,
    width: width,
    points: [...points, point],
  );
}
