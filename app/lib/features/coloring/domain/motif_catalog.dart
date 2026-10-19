import 'coloring_motif.dart';
import 'coloring_page.dart';
import 'coloring_region.dart';
import 'point_2d.dart';

final motifCatalog = <ColoringMotif>[
  _motif('cat', 'Katze', MotifCategory.animals, [
    _polygon('head', [
      (82, 48),
      (105, 18),
      (132, 48),
      (168, 48),
      (195, 18),
      (218, 48),
      (224, 122),
      (76, 122),
    ]),
    _polygon('body', [(104, 128), (196, 128), (218, 188), (82, 188)]),
    _polygon('tail', [(204, 138), (274, 112), (282, 140), (218, 170)]),
  ]),
  _motif('fish', 'Fisch', MotifCategory.animals, [
    _polygon('body', [
      (48, 100),
      (92, 48),
      (210, 48),
      (252, 100),
      (210, 152),
      (92, 152),
    ]),
    _polygon('tail', [(48, 100), (14, 48), (14, 152)]),
    _polygon('fin', [(120, 52), (154, 16), (180, 52)]),
  ]),
  _motif('flower', 'Blume', MotifCategory.nature, [
    _polygon('center', [
      (120, 62),
      (150, 42),
      (180, 62),
      (180, 102),
      (150, 122),
      (120, 102),
    ]),
    _polygon('left-petal', [
      (116, 68),
      (62, 40),
      (42, 82),
      (82, 112),
      (120, 96),
    ]),
    _polygon('right-petal', [
      (184, 68),
      (238, 40),
      (258, 82),
      (218, 112),
      (180, 96),
    ]),
    _polygon('stem', [(136, 122), (164, 122), (174, 190), (126, 190)]),
  ]),
  _motif('tree', 'Baum', MotifCategory.nature, [
    _polygon('crown-left', [
      (30, 98),
      (82, 22),
      (142, 96),
      (120, 132),
      (52, 132),
    ]),
    _polygon('crown-right', [
      (158, 96),
      (218, 22),
      (270, 98),
      (248, 132),
      (180, 132),
    ]),
    _polygon('trunk', [(126, 126), (174, 126), (184, 190), (116, 190)]),
  ]),
  _motif('car', 'Auto', MotifCategory.vehicles, [
    _polygon('body', [
      (28, 92),
      (70, 58),
      (220, 58),
      (270, 94),
      (270, 148),
      (28, 148),
    ]),
    _polygon('window-left', [(82, 66), (138, 66), (138, 94), (62, 94)]),
    _polygon('window-right', [(146, 66), (208, 66), (238, 94), (146, 94)]),
    _polygon('wheel-left', [(60, 148), (100, 148), (100, 184), (60, 184)]),
    _polygon('wheel-right', [(202, 148), (242, 148), (242, 184), (202, 184)]),
  ]),
  _motif('rocket', 'Rakete', MotifCategory.vehicles, [
    _polygon('body', [(120, 38), (150, 10), (180, 38), (190, 142), (110, 142)]),
    _polygon('window', [(128, 56), (172, 56), (172, 94), (128, 94)]),
    _polygon('left-fin', [(110, 112), (72, 162), (112, 152)]),
    _polygon('right-fin', [(190, 112), (228, 162), (188, 152)]),
    _polygon('flame', [(126, 144), (150, 192), (174, 144)]),
  ]),
];

ColoringMotif _motif(
  String id,
  String title,
  MotifCategory category,
  List<ColoringRegion> regions,
) => ColoringMotif(
  title: title,
  category: category,
  page: ColoringPage(id: id, size: const Size2D(300, 200), regions: regions),
);

ColoringRegion _polygon(String id, List<(double, double)> points) =>
    ColoringRegion(
      id: id,
      vertices: points.map((point) => Point2D(point.$1, point.$2)),
    );
