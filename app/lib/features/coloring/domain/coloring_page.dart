import 'coloring_region.dart';
import 'point_2d.dart';

final class ColoringPage {
  ColoringPage({
    required this.id,
    required this.size,
    required Iterable<ColoringRegion> regions,
  }) : regions = List.unmodifiable(regions) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (this.regions.isEmpty) {
      throw ArgumentError.value(regions, 'regions', 'must not be empty');
    }
    final ids = this.regions.map((region) => region.id).toSet();
    if (ids.length != this.regions.length) {
      throw ArgumentError.value(regions, 'regions', 'ids must be unique');
    }
  }

  final String id;
  final Size2D size;
  final List<ColoringRegion> regions;

  /// Returns the first matching region in asset order.
  ///
  /// Asset order is the deterministic tie-breaker for shared boundaries.
  ColoringRegion? regionAt(Point2D point) {
    for (final region in regions) {
      if (region.contains(point)) {
        return region;
      }
    }
    return null;
  }

  ColoringRegion regionById(String id) =>
      regions.firstWhere((region) => region.id == id);
}
