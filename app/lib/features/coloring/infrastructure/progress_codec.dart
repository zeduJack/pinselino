import 'dart:convert';

import '../domain/paint_stroke.dart';
import '../domain/point_2d.dart';

final class ProgressCodec {
  static const version = 1;

  String encode(List<PaintStroke> strokes) => jsonEncode({
    'version': version,
    'strokes': strokes
        .map(
          (stroke) => {
            'regionId': stroke.regionId,
            'colorArgb': stroke.colorArgb,
            'width': stroke.width,
            'brushKind': stroke.brushKind.name,
            'points': stroke.points.map((point) => [point.x, point.y]).toList(),
          },
        )
        .toList(),
  });

  List<PaintStroke> decode(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final root = jsonDecode(value) as Map<String, dynamic>;
      if (root['version'] != version) return const [];
      final rawStrokes = root['strokes'] as List<dynamic>;
      return rawStrokes
          .map((raw) {
            final stroke = raw as Map<String, dynamic>;
            return PaintStroke(
              regionId: stroke['regionId'] as String,
              colorArgb: stroke['colorArgb'] as int,
              width: (stroke['width'] as num).toDouble(),
              brushKind: BrushKind.values.byName(stroke['brushKind'] as String),
              points: (stroke['points'] as List<dynamic>).map((rawPoint) {
                final point = rawPoint as List<dynamic>;
                return Point2D(
                  (point[0] as num).toDouble(),
                  (point[1] as num).toDouble(),
                );
              }),
            );
          })
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }
}
