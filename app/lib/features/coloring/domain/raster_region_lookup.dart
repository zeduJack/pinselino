import 'dart:typed_data';

import 'coloring_page.dart';
import 'point_2d.dart';

final class RasterRegionLookup implements RegionLookup {
  RasterRegionLookup({
    required this.width,
    required this.height,
    required Uint32List technicalRegionIds,
    required Map<int, String> technicalToPaintGroup,
  }) : technicalRegionIds = Uint32List.fromList(technicalRegionIds),
       technicalToPaintGroup = Map.unmodifiable(technicalToPaintGroup) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('dimensions must be positive');
    }
    if (this.technicalRegionIds.length != width * height) {
      throw ArgumentError('region ID count must match image dimensions');
    }
  }

  final int width;
  final int height;
  final Uint32List technicalRegionIds;
  final Map<int, String> technicalToPaintGroup;

  @override
  String? regionIdAt(Point2D point) {
    final x = point.x.floor();
    final y = point.y.floor();
    if (x < 0 || y < 0 || x >= width || y >= height) return null;
    return technicalToPaintGroup[technicalRegionIds[y * width + x]];
  }
}
