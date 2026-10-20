import 'point_2d.dart';

final class ColoringPath {
  ColoringPath({required Iterable<Point2D> points, this.isHole = false})
    : points = List.unmodifiable(points) {
    if (this.points.length < 3) {
      throw ArgumentError.value(this.points, 'points', 'needs three points');
    }
  }

  final List<Point2D> points;
  final bool isHole;

  double get area {
    var twiceArea = 0.0;
    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final next = points[(index + 1) % points.length];
      twiceArea += current.x * next.y - next.x * current.y;
    }
    return twiceArea.abs() / 2;
  }

  bool contains(Point2D point) {
    var inside = false;
    for (
      var index = 0, previous = points.length - 1;
      index < points.length;
      previous = index++
    ) {
      final current = points[index];
      final before = points[previous];
      if (_isOnSegment(point, before, current)) return true;
      final crosses = (current.y > point.y) != (before.y > point.y);
      if (!crosses) continue;
      final intersectionX =
          (before.x - current.x) *
              (point.y - current.y) /
              (before.y - current.y) +
          current.x;
      if (point.x < intersectionX) inside = !inside;
    }
    return inside;
  }

  bool _isOnSegment(Point2D point, Point2D start, Point2D end) {
    const epsilon = 1e-9;
    final cross =
        (point.y - start.y) * (end.x - start.x) -
        (point.x - start.x) * (end.y - start.y);
    if (cross.abs() > epsilon) return false;
    final dot =
        (point.x - start.x) * (end.x - start.x) +
        (point.y - start.y) * (end.y - start.y);
    if (dot < -epsilon) return false;
    final length =
        (end.x - start.x) * (end.x - start.x) +
        (end.y - start.y) * (end.y - start.y);
    return dot <= length + epsilon;
  }
}

/// One logical paint group, potentially made of disconnected paths and holes.
final class ColoringRegion {
  ColoringRegion({required this.id, required Iterable<Point2D> vertices})
    : paths = List.unmodifiable([ColoringPath(points: vertices)]),
      hasPrecomputedHoles = false {
    _validateId();
  }

  ColoringRegion.fromPaths({
    required this.id,
    required Iterable<ColoringPath> paths,
  }) : paths = List.unmodifiable(paths),
       hasPrecomputedHoles = true {
    _validateId();
    if (this.paths.isEmpty) {
      throw ArgumentError.value(paths, 'paths', 'must not be empty');
    }
  }

  final String id;
  final List<ColoringPath> paths;
  final bool hasPrecomputedHoles;

  List<Point2D> get vertices => paths.first.points;

  double get area => paths.fold(
    0,
    (sum, path) => sum + (path.isHole ? -path.area : path.area),
  );

  bool contains(Point2D point) {
    var inside = false;
    for (final path in paths) {
      if (path.contains(point)) inside = !inside;
    }
    return inside;
  }

  void _validateId() {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must not be empty');
  }
}
