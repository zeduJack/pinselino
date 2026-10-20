import 'point_2d.dart';

/// A closed polygonal area that may receive paint.
final class ColoringRegion {
  ColoringRegion({required this.id, required Iterable<Point2D> vertices})
    : vertices = List.unmodifiable(vertices) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (this.vertices.length < 3) {
      throw ArgumentError.value(
        this.vertices,
        'vertices',
        'a closed polygon needs at least three vertices',
      );
    }
  }

  final String id;
  final List<Point2D> vertices;

  double get area {
    var twiceArea = 0.0;
    for (var index = 0; index < vertices.length; index++) {
      final current = vertices[index];
      final next = vertices[(index + 1) % vertices.length];
      twiceArea += current.x * next.y - next.x * current.y;
    }
    return twiceArea.abs() / 2;
  }

  /// Returns true for points inside the polygon or directly on its boundary.
  bool contains(Point2D point) {
    var inside = false;
    for (
      var index = 0, previous = vertices.length - 1;
      index < vertices.length;
      previous = index++
    ) {
      final currentPoint = vertices[index];
      final previousPoint = vertices[previous];

      if (_isOnSegment(point, previousPoint, currentPoint)) {
        return true;
      }

      final crossesVerticalRange =
          (currentPoint.y > point.y) != (previousPoint.y > point.y);
      if (!crossesVerticalRange) {
        continue;
      }

      final intersectionX =
          (previousPoint.x - currentPoint.x) *
              (point.y - currentPoint.y) /
              (previousPoint.y - currentPoint.y) +
          currentPoint.x;
      if (point.x < intersectionX) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool _isOnSegment(Point2D point, Point2D start, Point2D end) {
    const epsilon = 1e-9;
    final crossProduct =
        (point.y - start.y) * (end.x - start.x) -
        (point.x - start.x) * (end.y - start.y);
    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final dotProduct =
        (point.x - start.x) * (end.x - start.x) +
        (point.y - start.y) * (end.y - start.y);
    if (dotProduct < -epsilon) {
      return false;
    }

    final squaredLength =
        (end.x - start.x) * (end.x - start.x) +
        (end.y - start.y) * (end.y - start.y);
    return dotProduct <= squaredLength + epsilon;
  }
}
