import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/coloring_controller.dart';
import 'package:pinselino/features/coloring/domain/paint_stroke.dart';
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

  test('undo and redo move the latest completed stroke through history', () {
    final controller = ColoringController(page: createTestColoringPage());
    _drawStroke(controller, const Point2D(50, 50), 0xFFFF0000);
    _drawStroke(controller, const Point2D(150, 50), 0xFF00FF00);

    controller.undo();

    expect(controller.strokes, hasLength(1));
    expect(controller.strokes.single.colorArgb, 0xFFFF0000);
    expect(controller.canRedo, isTrue);

    controller.redo();

    expect(controller.strokes, hasLength(2));
    expect(controller.strokes.last.colorArgb, 0xFF00FF00);
    expect(controller.canRedo, isFalse);
  });

  test('a new stroke after undo discards redo history', () {
    final controller = ColoringController(page: createTestColoringPage());
    _drawStroke(controller, const Point2D(50, 50), 0xFFFF0000);
    controller.undo();

    _drawStroke(controller, const Point2D(150, 50), 0xFF00FF00);

    expect(controller.canRedo, isFalse);
    expect(controller.strokes.single.colorArgb, 0xFF00FF00);
  });

  test('eraser is bound to its start region like every other stroke', () {
    final controller = ColoringController(page: createTestColoringPage());

    controller
      ..beginStroke(
        point: const Point2D(50, 100),
        colorArgb: 0,
        width: 36,
        brushKind: BrushKind.eraser,
      )
      ..extendStroke(const Point2D(250, 100))
      ..endStroke();

    expect(controller.strokes.single.regionId, 'left');
    expect(controller.strokes.single.isEraser, isTrue);
  });

  test('reset removes strokes and both history directions', () {
    final controller = ColoringController(page: createTestColoringPage());
    _drawStroke(controller, const Point2D(50, 50), 0xFFFF0000);
    _drawStroke(controller, const Point2D(150, 50), 0xFF00FF00);
    controller.undo();

    controller.reset();

    expect(controller.strokes, isEmpty);
    expect(controller.canUndo, isFalse);
    expect(controller.canRedo, isFalse);
  });

  test('restore ignores strokes for regions absent from the motif', () {
    final controller = ColoringController(page: createTestColoringPage());

    controller.restore([
      PaintStroke(
        regionId: 'removed-by-newer-motif',
        colorArgb: 0xFFFF0000,
        width: 20,
        points: const [Point2D(50, 50)],
      ),
    ]);

    expect(controller.strokes, isEmpty);
  });
}

void _drawStroke(ColoringController controller, Point2D point, int colorArgb) {
  controller
    ..beginStroke(point: point, colorArgb: colorArgb, width: 20)
    ..endStroke();
}
