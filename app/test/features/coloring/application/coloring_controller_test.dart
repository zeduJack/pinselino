import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/coloring_controller.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/domain/test_coloring_page.dart';

void main() {
  test('stroke keeps the region in which it started', () {
    final controller = ColoringController(page: createTestColoringPage());

    final didBegin = controller.beginStroke(
      point: const Point2D(50, 100),
      colorArgb: 0xFFFF0000,
      width: 20,
    );
    controller.extendStroke(const Point2D(150, 100));
    controller.extendStroke(const Point2D(250, 100));
    controller.endStroke();

    expect(didBegin, isTrue);
    expect(controller.strokes, hasLength(1));
    expect(controller.strokes.single.regionId, 'left');
    expect(controller.strokes.single.points, hasLength(3));
  });

  test('stroke cannot begin outside a paintable region', () {
    final controller = ColoringController(page: createTestColoringPage());

    final didBegin = controller.beginStroke(
      point: const Point2D(100, 100),
      colorArgb: 0xFFFF0000,
      width: 20,
    );
    controller.extendStroke(const Point2D(50, 100));
    controller.endStroke();

    expect(didBegin, isFalse);
    expect(controller.strokes, isEmpty);
  });
}
