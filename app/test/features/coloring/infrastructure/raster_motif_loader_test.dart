import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/coloring_controller.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/domain/raster_motif_definition.dart';
import 'package:pinselino/features/coloring/infrastructure/raster_motif_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads elephant mask, five groups, paths, and protected details',
    () async {
      final loaded = await RasterMotifLoader().load(elephantRasterMotif);
      final page = loaded.motif.page;

      expect(page.id, 'elephant-raster');
      expect(page.size.width, 512);
      expect(page.size.height, 760);
      expect(page.regions, hasLength(5));
      expect(page.regionById('body').paths.length, greaterThan(5));
      expect(page.regionAt(const Point2D(251, 242))?.id, 'head');
      expect(page.regionAt(const Point2D(171, 232)), isNull);
      expect(loaded.outlineImage.width, 512);
      expect(loaded.outlineImage.height, 760);

      final controller = ColoringController(page: page);
      expect(
        controller.beginStroke(
          point: const Point2D(251, 242),
          colorArgb: 0xFFFF0000,
          width: 40,
        ),
        isTrue,
      );
      controller
        ..extendStroke(const Point2D(75, 185))
        ..endStroke();
      expect(controller.strokes.single.regionId, 'head');
      loaded.outlineImage.dispose();
    },
  );
}
