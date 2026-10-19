import 'dart:math' as math;

/// Flutter-independent point in motif coordinates.
final class Point2D {
  const Point2D(this.x, this.y);

  final double x;
  final double y;

  double distanceTo(Point2D other) =>
      math.sqrt(math.pow(x - other.x, 2) + math.pow(y - other.y, 2));

  @override
  bool operator ==(Object other) =>
      other is Point2D && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point2D($x, $y)';
}

final class Size2D {
  const Size2D(this.width, this.height) : assert(width > 0), assert(height > 0);

  final double width;
  final double height;
}
