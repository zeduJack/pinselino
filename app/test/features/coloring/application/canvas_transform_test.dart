import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/canvas_transform.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';

void main() {
  test('wide viewport letterboxes motif and round-trips coordinates', () {
    final transform = CanvasTransform.fitContain(
      motifSize: const Size2D(300, 200),
      viewportSize: const Size2D(800, 400),
    );

    expect(transform.scale, 2);
    expect(transform.offset, const Point2D(100, 0));
    expect(
      transform.motifToViewport(const Point2D(150, 100)),
      const Point2D(400, 200),
    );
    expect(
      transform.viewportToMotif(const Point2D(400, 200)),
      const Point2D(150, 100),
    );
  });

  test('points in letterbox margin are rejected', () {
    final transform = CanvasTransform.fitContain(
      motifSize: const Size2D(300, 200),
      viewportSize: const Size2D(800, 400),
    );

    expect(transform.viewportToMotif(const Point2D(99, 200)), isNull);
    expect(transform.viewportToMotif(const Point2D(701, 200)), isNull);
  });

  test('tall viewport centers motif vertically', () {
    final transform = CanvasTransform.fitContain(
      motifSize: const Size2D(300, 200),
      viewportSize: const Size2D(300, 500),
    );

    expect(transform.scale, 1);
    expect(transform.offset, const Point2D(0, 150));
  });
}
