import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/domain/raster_region_lookup.dart';

void main() {
  test('maps technical pixels to paint groups and protects unmapped IDs', () {
    final lookup = RasterRegionLookup(
      width: 3,
      height: 2,
      technicalRegionIds: Uint32List.fromList([0, 1, 2, 3, 1, 0]),
      technicalToPaintGroup: const {1: 'head', 2: 'head', 3: 'ear'},
    );

    expect(lookup.regionIdAt(const Point2D(1.2, 0.1)), 'head');
    expect(lookup.regionIdAt(const Point2D(2.1, 0.1)), 'head');
    expect(lookup.regionIdAt(const Point2D(0.1, 1.1)), 'ear');
    expect(lookup.regionIdAt(const Point2D(0.1, 0.1)), isNull);
    expect(lookup.regionIdAt(const Point2D(-1, 0)), isNull);
    expect(lookup.regionIdAt(const Point2D(3, 0)), isNull);
  });

  test('rejects pixel buffers with wrong dimensions', () {
    expect(
      () => RasterRegionLookup(
        width: 2,
        height: 2,
        technicalRegionIds: Uint32List(3),
        technicalToPaintGroup: const {},
      ),
      throwsArgumentError,
    );
  });
}
