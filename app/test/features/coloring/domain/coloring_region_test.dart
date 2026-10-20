import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/domain/coloring_page.dart';
import 'package:pinselino/features/coloring/domain/coloring_region.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/domain/test_coloring_page.dart';

void main() {
  group('ColoringRegion', () {
    final region = ColoringRegion(
      id: 'square',
      vertices: const [
        Point2D(0, 0),
        Point2D(10, 0),
        Point2D(10, 10),
        Point2D(0, 10),
      ],
    );

    test('contains interior and boundary points', () {
      expect(region.contains(const Point2D(5, 5)), isTrue);
      expect(region.contains(const Point2D(0, 5)), isTrue);
      expect(region.contains(const Point2D(10, 10)), isTrue);
    });

    test('rejects exterior points', () {
      expect(region.contains(const Point2D(-0.01, 5)), isFalse);
      expect(region.contains(const Point2D(11, 5)), isFalse);
    });
  });

  group('ColoringPage', () {
    test('test motif has exactly three uniquely identified closed regions', () {
      final page = createTestColoringPage();

      expect(page.regions, hasLength(3));
      expect(page.regions.map((region) => region.id).toSet(), {
        'left',
        'middle',
        'right',
      });
      expect(page.regionAt(const Point2D(50, 100))?.id, 'left');
      expect(page.regionAt(const Point2D(150, 100))?.id, 'middle');
      expect(page.regionAt(const Point2D(250, 100))?.id, 'right');
      expect(page.regionAt(const Point2D(100, 100)), isNull);
    });

    test('asset order deterministically wins on a shared boundary', () {
      final page = ColoringPage(
        id: 'shared-boundary',
        size: const Size2D(20, 10),
        regions: [
          ColoringRegion(
            id: 'first',
            vertices: const [
              Point2D(0, 0),
              Point2D(10, 0),
              Point2D(10, 10),
              Point2D(0, 10),
            ],
          ),
          ColoringRegion(
            id: 'second',
            vertices: const [
              Point2D(10, 0),
              Point2D(20, 0),
              Point2D(20, 10),
              Point2D(10, 10),
            ],
          ),
        ],
      );

      expect(page.regionAt(const Point2D(10, 5))?.id, 'first');
    });

    test('small nested detail wins over its containing region', () {
      final page = _nestedPage();

      expect(page.regionAt(const Point2D(10, 10))?.id, 'outer');
      expect(page.regionAt(const Point2D(50, 50))?.id, 'inner');
    });
  });
}

ColoringPage _nestedPage() => ColoringPage(
  id: 'nested',
  size: const Size2D(100, 100),
  regions: [
    ColoringRegion(
      id: 'outer',
      vertices: const [
        Point2D(0, 0),
        Point2D(100, 0),
        Point2D(100, 100),
        Point2D(0, 100),
      ],
    ),
    ColoringRegion(
      id: 'inner',
      vertices: const [
        Point2D(35, 35),
        Point2D(65, 35),
        Point2D(65, 65),
        Point2D(35, 65),
      ],
    ),
  ],
);
