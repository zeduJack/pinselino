import '../domain/coloring_page.dart';
import '../domain/paint_stroke.dart';
import '../domain/point_2d.dart';

/// Owns the drawing state without depending on Flutter widgets or rendering.
final class ColoringController {
  ColoringController({required this.page});

  final ColoringPage page;
  final List<PaintStroke> _completedStrokes = [];
  PaintStroke? _activeStroke;

  List<PaintStroke> get strokes =>
      List.unmodifiable([..._completedStrokes, ?_activeStroke]);

  bool beginStroke({
    required Point2D point,
    required int colorArgb,
    required double width,
  }) {
    final region = page.regionAt(point);
    if (region == null) {
      _activeStroke = null;
      return false;
    }
    _activeStroke = PaintStroke(
      regionId: region.id,
      colorArgb: colorArgb,
      width: width,
      points: [point],
    );
    return true;
  }

  void extendStroke(Point2D point) {
    final activeStroke = _activeStroke;
    if (activeStroke == null) {
      return;
    }
    _activeStroke = activeStroke.append(point);
  }

  void endStroke() {
    final activeStroke = _activeStroke;
    if (activeStroke == null) {
      return;
    }
    _completedStrokes.add(activeStroke);
    _activeStroke = null;
  }
}
