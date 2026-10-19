import 'coloring_page.dart';
import 'coloring_region.dart';
import 'point_2d.dart';

/// Small deterministic motif used by the Phase 1 technical spike.
ColoringPage createTestColoringPage() => ColoringPage(
  id: 'phase-1-test-card',
  size: const Size2D(300, 200),
  regions: [
    ColoringRegion(
      id: 'left',
      vertices: const [
        Point2D(12, 12),
        Point2D(96, 12),
        Point2D(96, 188),
        Point2D(12, 188),
      ],
    ),
    ColoringRegion(
      id: 'middle',
      vertices: const [
        Point2D(104, 12),
        Point2D(196, 12),
        Point2D(196, 188),
        Point2D(104, 188),
      ],
    ),
    ColoringRegion(
      id: 'right',
      vertices: const [
        Point2D(204, 12),
        Point2D(288, 12),
        Point2D(288, 188),
        Point2D(204, 188),
      ],
    ),
  ],
);
