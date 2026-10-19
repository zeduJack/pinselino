import 'package:flutter/material.dart';

import '../application/canvas_transform.dart';
import '../application/coloring_controller.dart';
import '../domain/point_2d.dart';
import '../domain/paint_stroke.dart';
import '../rendering/coloring_painter.dart';

class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({
    required this.controller,
    this.colorArgb = 0xFFE84393,
    this.brushWidth = 24,
    this.brushKind = BrushKind.marker,
    this.onStrokeCompleted,
    super.key,
  });

  final ColoringController controller;
  final int colorArgb;
  final double brushWidth;
  final BrushKind brushKind;
  final VoidCallback? onStrokeCompleted;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  CanvasTransform _transformFor(Size size) => CanvasTransform.fitContain(
    motifSize: widget.controller.page.size,
    viewportSize: Size2D(size.width, size.height),
  );

  Point2D? _toMotif(Offset localPosition, Size size) => _transformFor(
    size,
  ).viewportToMotif(Point2D(localPosition.dx, localPosition.dy));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        key: const ValueKey('coloring_canvas_gesture'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          final point = _toMotif(details.localPosition, size);
          if (point == null) {
            return;
          }
          setState(() {
            widget.controller.beginStroke(
              point: point,
              colorArgb: widget.colorArgb,
              width: widget.brushWidth,
              brushKind: widget.brushKind,
            );
          });
        },
        onPanUpdate: (details) {
          final point = _toMotif(details.localPosition, size);
          if (point == null) {
            return;
          }
          setState(() => widget.controller.extendStroke(point));
        },
        onPanEnd: (_) {
          setState(widget.controller.endStroke);
          widget.onStrokeCompleted?.call();
        },
        child: CustomPaint(
          key: const ValueKey('coloring_canvas_paint'),
          painter: ColoringPainter(
            page: widget.controller.page,
            strokes: widget.controller.strokes,
          ),
          child: const SizedBox.expand(),
        ),
      );
    },
  );
}
