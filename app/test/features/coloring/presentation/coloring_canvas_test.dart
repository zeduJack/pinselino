import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/coloring_controller.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/domain/test_coloring_page.dart';
import 'package:pinselino/features/coloring/presentation/coloring_canvas.dart';

void main() {
  testWidgets('drag is transformed and remains bound to its start region', (
    tester,
  ) async {
    final controller = ColoringController(page: createTestColoringPage());
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: ColoringCanvas(controller: controller),
          ),
        ),
      ),
    );

    final canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
    await tester.dragFrom(
      tester.getTopLeft(canvas) + const Offset(50, 100),
      const Offset(200, 0),
    );
    await tester.pump();

    expect(controller.strokes, hasLength(1));
    expect(controller.strokes.single.regionId, 'left');
    expect(controller.strokes.single.points.first, const Point2D(50, 100));
    expect(controller.strokes.single.points.last.x, greaterThan(200));
  });

  testWidgets('rendering clips paint and keeps contours above it', (
    tester,
  ) async {
    final controller = ColoringController(page: createTestColoringPage());
    controller
      ..beginStroke(
        point: const Point2D(50, 100),
        colorArgb: 0xFFE84393,
        width: 52,
      )
      ..extendStroke(const Point2D(150, 100))
      ..extendStroke(const Point2D(250, 100))
      ..endStroke();

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          child: SizedBox(
            width: 300,
            height: 200,
            child: ColoringCanvas(controller: controller),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/clipped_stroke.png'),
    );
  });
}
