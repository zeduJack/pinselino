import '../domain/coloring_page.dart';
import '../domain/paint_stroke.dart';
import '../domain/point_2d.dart';

/// Owns the drawing state without depending on Flutter widgets or rendering.
final class ColoringController {
  ColoringController({required this.page});

  final ColoringPage page;
  final List<PaintStroke> _completedStrokes = [];
  final List<PaintStroke> _redoStrokes = [];
  PaintStroke? _activeStroke;

  List<PaintStroke> get strokes =>
      List.unmodifiable([..._completedStrokes, ?_activeStroke]);

  bool get canUndo => _completedStrokes.isNotEmpty;
  bool get canRedo => _redoStrokes.isNotEmpty;
  bool get isEmpty => _completedStrokes.isEmpty && _activeStroke == null;

  bool beginStroke({
    required Point2D point,
    required int colorArgb,
    required double width,
    BrushKind brushKind = BrushKind.marker,
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
      brushKind: brushKind,
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
    _redoStrokes.clear();
    _activeStroke = null;
  }

  void undo() {
    if (_completedStrokes.isEmpty) {
      return;
    }
    _activeStroke = null;
    _redoStrokes.add(_completedStrokes.removeLast());
  }

  void redo() {
    if (_redoStrokes.isEmpty) {
      return;
    }
    _completedStrokes.add(_redoStrokes.removeLast());
  }

  void reset() {
    _activeStroke = null;
    _completedStrokes.clear();
    _redoStrokes.clear();
  }

  void restore(Iterable<PaintStroke> strokes) {
    _activeStroke = null;
    _completedStrokes
      ..clear()
      ..addAll(strokes);
    _redoStrokes.clear();
  }
}
