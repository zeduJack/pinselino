import 'coloring_region.dart';
import 'point_2d.dart';

abstract interface class RegionLookup {
  String? regionIdAt(Point2D point);
}

final class ColoringPage {
  ColoringPage({
    required this.id,
    required this.size,
    required Iterable<ColoringRegion> regions,
    this.regionLookup,
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
  final RegionLookup? regionLookup;

  /// Returns the smallest matching region so nested details remain paintable.
  /// Asset order is the deterministic tie-breaker for equal-sized regions.
  ColoringRegion? regionAt(Point2D point) {
    final lookupId = regionLookup?.regionIdAt(point);
    if (regionLookup != null) {
      return lookupId == null ? null : regionById(lookupId);
    }
    final matches = regions.where((region) => region.contains(point)).toList()
      ..sort((left, right) => left.area.compareTo(right.area));
    return matches.firstOrNull;
  }

  ColoringRegion regionById(String id) =>
      regions.firstWhere((region) => region.id == id);
}
