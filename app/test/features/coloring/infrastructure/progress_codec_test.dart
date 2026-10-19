import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/domain/paint_stroke.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/infrastructure/progress_codec.dart';

void main() {
  final codec = ProgressCodec();

  test('roundtrips every stroke property', () {
    final source = [
      PaintStroke(
        regionId: 'body',
        colorArgb: 0xFFE84393,
        width: 31.5,
        brushKind: BrushKind.crayon,
        points: const [Point2D(1, 2), Point2D(3.5, 4.5)],
      ),
    ];

    final decoded = codec.decode(codec.encode(source));

    expect(decoded.single.regionId, 'body');
    expect(decoded.single.colorArgb, 0xFFE84393);
    expect(decoded.single.width, 31.5);
    expect(decoded.single.brushKind, BrushKind.crayon);
    expect(decoded.single.points, const [Point2D(1, 2), Point2D(3.5, 4.5)]);
  });

  test('empty, corrupt, and old values safely become empty progress', () {
    expect(codec.decode(null), isEmpty);
    expect(codec.decode('not-json'), isEmpty);
    expect(codec.decode('{"version":0,"strokes":[]}'), isEmpty);
    expect(codec.decode('{"version":1,"strokes":"wrong"}'), isEmpty);
  });
}
