import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../application/coloring_controller.dart';
import '../application/progress_store.dart';
import '../domain/coloring_motif.dart';
import '../domain/paint_stroke.dart';
import 'coloring_canvas.dart';

const coloringPalette = <int>[
  0xFFE84393,
  0xFFFF6B35,
  0xFFFFC312,
  0xFF2ECC71,
  0xFF00A8FF,
  0xFF6C5CE7,
  0xFF8E5A3C,
  0xFF252333,
];

enum BrushSize {
  small(0.65, 'Dünn'),
  medium(1, 'Mittel'),
  large(1.55, 'Dick');

  const BrushSize(this.factor, this.label);

  final double factor;
  final String label;
}

class ColoringSpikeScreen extends StatefulWidget {
  const ColoringSpikeScreen({
    required this.motif,
    required this.progressStore,
    required this.initialStrokes,
    this.outlineImage,
    super.key,
  });

  final ColoringMotif motif;
  final ProgressStore progressStore;
  final List<PaintStroke> initialStrokes;
  final ui.Image? outlineImage;

  @override
  State<ColoringSpikeScreen> createState() => _ColoringSpikeScreenState();
}

class _ColoringSpikeScreenState extends State<ColoringSpikeScreen> {
  late final ColoringController _controller;
  var _selectedColor = coloringPalette.first;
  var _selectedBrush = BrushKind.marker;
  var _selectedSize = BrushSize.medium;

  @override
  void initState() {
    super.initState();
    _controller = ColoringController(page: widget.motif.page)
      ..restore(widget.initialStrokes);
  }

  Future<void> _save() =>
      widget.progressStore.save(widget.motif.page.id, _controller.strokes);

  void _undo() {
    setState(_controller.undo);
    _save();
  }

  void _redo() {
    setState(_controller.redo);
    _save();
  }

  double get _brushWidth =>
      _selectedSize.factor *
      switch (_selectedBrush) {
        BrushKind.marker => 24,
        BrushKind.crayon => 30,
        BrushKind.softBrush => 38,
        BrushKind.eraser => 36,
      };

  Future<void> _confirmReset() async {
    if (_controller.isEmpty) {
      return;
    }
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bild neu anfangen?'),
        content: const Text('Deine Farben auf diesem Bild werden entfernt.'),
        actions: [
          TextButton(
            key: const ValueKey('cancel_reset'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Behalten'),
          ),
          FilledButton(
            key: const ValueKey('confirm_reset'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Neu anfangen'),
          ),
        ],
      ),
    );
    if (shouldReset == true && mounted) {
      setState(_controller.reset);
      await widget.progressStore.delete(widget.motif.page.id);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.motif.title),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          key: const ValueKey('undo_button'),
          tooltip: 'Rückgängig',
          onPressed: _controller.canUndo ? _undo : null,
          icon: const Icon(Icons.undo_rounded),
        ),
        IconButton(
          key: const ValueKey('redo_button'),
          tooltip: 'Wiederholen',
          onPressed: _controller.canRedo ? _redo : null,
          icon: const Icon(Icons.redo_rounded),
        ),
        IconButton(
          key: const ValueKey('reset_button'),
          tooltip: 'Neu anfangen',
          onPressed: _controller.isEmpty ? null : _confirmReset,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: SafeArea(child: LayoutBuilder(builder: _buildResponsiveBody)),
  );

  Widget _buildResponsiveBody(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final isLandscape = constraints.maxWidth > constraints.maxHeight;
    final tools = _ToolBar(
      axis: isLandscape ? Axis.vertical : Axis.horizontal,
      selected: _selectedBrush,
      onSelected: (brush) => setState(() => _selectedBrush = brush),
    );
    final sizes = _BrushSizePicker(
      axis: isLandscape ? Axis.vertical : Axis.horizontal,
      selected: _selectedSize,
      onSelected: (size) => setState(() => _selectedSize = size),
    );
    final palette = _ColorPalette(
      axis: isLandscape ? Axis.vertical : Axis.horizontal,
      selectedColor: _selectedColor,
      onSelected: (color) => setState(() {
        _selectedColor = color;
        if (_selectedBrush == BrushKind.eraser) {
          _selectedBrush = BrushKind.marker;
        }
      }),
    );
    final canvas = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoringCanvas(
        controller: _controller,
        colorArgb: _selectedColor,
        brushKind: _selectedBrush,
        brushWidth: _brushWidth,
        outlineImage: widget.outlineImage,
        onStrokeCompleted: () {
          setState(() {});
          _save();
        },
      ),
    );

    if (isLandscape) {
      return Padding(
        key: const ValueKey('landscape_controls'),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              child: Row(
                children: [
                  Expanded(child: tools),
                  const VerticalDivider(width: 8),
                  Expanded(child: sizes),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: canvas),
            const SizedBox(width: 8),
            palette,
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey('portrait_controls'),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        children: [
          tools,
          sizes,
          const SizedBox(height: 4),
          Expanded(child: canvas),
          const SizedBox(height: 4),
          palette,
        ],
      ),
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar({
    required this.axis,
    required this.selected,
    required this.onSelected,
  });

  final Axis axis;
  final BrushKind selected;
  final ValueChanged<BrushKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _ToolButton(
        kind: BrushKind.marker,
        label: 'Stift',
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.crayon,
        label: 'Kreide',
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.softBrush,
        label: 'Pinsel',
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.eraser,
        label: 'Radierer',
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
    ];
    return axis == Axis.vertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons,
          )
        : Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: buttons,
          );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.kind,
    required this.label,
    required this.compact,
    required this.selected,
    required this.onSelected,
  });

  final BrushKind kind;
  final String label;
  final bool compact;
  final BrushKind selected;
  final ValueChanged<BrushKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == kind;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Semantics(
        label: label,
        button: true,
        selected: isSelected,
        child: Tooltip(
          message: label,
          child: InkWell(
            key: ValueKey('tool_${kind.name}'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(kind),
            child: AnimatedContainer(
              key: ValueKey('tool_surface_${kind.name}'),
              duration: const Duration(milliseconds: 160),
              width: compact ? 44 : 58,
              height: compact ? 44 : 58,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE4DEFF)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5146A8)
                      : const Color(0xFFD8D3E1),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x335146A8),
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: CustomPaint(
                key: ValueKey('tool_image_${kind.name}'),
                painter: _ToolIllustrationPainter(kind),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolIllustrationPainter extends CustomPainter {
  const _ToolIllustrationPainter(this.kind);

  final BrushKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(-0.72)
      ..translate(-size.width / 2, -size.height / 2);
    final outline = Paint()
      ..color = const Color(0xFF252333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    switch (kind) {
      case BrushKind.marker:
        final pencilBody = RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width / 2 - 7, 9, 14, size.height - 14),
          const Radius.circular(3),
        );
        final pencilTip = Path()
          ..moveTo(size.width / 2 - 7, 9)
          ..lineTo(size.width / 2, 1)
          ..lineTo(size.width / 2 + 7, 9)
          ..close();
        canvas
          ..drawRRect(pencilBody, Paint()..color = const Color(0xFF00A8FF))
          ..drawRRect(pencilBody, outline)
          ..drawPath(pencilTip, Paint()..color = const Color(0xFFFFE5B4))
          ..drawPath(pencilTip, outline)
          ..drawCircle(
            Offset(size.width / 2, 3.5),
            2.2,
            Paint()..color = const Color(0xFF252333),
          )
          ..drawRect(
            Rect.fromLTWH(size.width / 2 - 7, size.height - 11, 14, 6),
            Paint()..color = const Color(0xFFE84393),
          );
        break;
      case BrushKind.crayon:
        final crayonBody = RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 12, size.width - 20, size.height - 18),
          const Radius.circular(4),
        );
        canvas
          ..drawRRect(crayonBody, Paint()..color = const Color(0xFFFFC312))
          ..drawRRect(crayonBody, outline);
        canvas.drawPath(
          Path()
            ..moveTo(10, 12)
            ..lineTo(size.width / 2, 3)
            ..lineTo(size.width - 10, 12)
            ..close(),
          Paint()..color = const Color(0xFFFFC312),
        );
        for (final y in [20.0, size.height - 11]) {
          canvas.drawLine(
            Offset(11, y),
            Offset(size.width - 11, y),
            Paint()
              ..color = const Color(0xFFD89000)
              ..strokeWidth = 2,
          );
        }
        break;
      case BrushKind.softBrush:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width / 2 - 4, 20, 8, size.height - 23),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFF9A603C),
        );
        canvas.drawRect(
          Rect.fromLTWH(size.width / 2 - 7, 14, 14, 9),
          Paint()..color = const Color(0xFFB9C1C7),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width / 2 - 7, 14)
            ..quadraticBezierTo(size.width / 2, 1, size.width / 2 + 7, 14)
            ..close(),
          Paint()..color = const Color(0xFFE84393),
        );
        break;
      case BrushKind.eraser:
        final eraser = RRect.fromRectAndRadius(
          Rect.fromLTWH(7, 12, size.width - 14, size.height - 22),
          const Radius.circular(5),
        );
        canvas
          ..drawRRect(eraser, Paint()..color = const Color(0xFFFF7EB6))
          ..drawRRect(eraser, outline);
        canvas.drawRect(
          Rect.fromLTWH(7, size.height - 18, size.width - 14, 8),
          Paint()..color = const Color(0xFF61C5D8),
        );
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ToolIllustrationPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class _BrushSizePicker extends StatelessWidget {
  const _BrushSizePicker({
    required this.axis,
    required this.selected,
    required this.onSelected,
  });

  final Axis axis;
  final BrushSize selected;
  final ValueChanged<BrushSize> onSelected;

  @override
  Widget build(BuildContext context) {
    final buttons = BrushSize.values.map((size) {
      final isSelected = size == selected;
      return Semantics(
        label: size.label,
        button: true,
        selected: isSelected,
        child: Tooltip(
          message: size.label,
          child: InkWell(
            key: ValueKey('brush_size_${size.name}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(size),
            child: AnimatedContainer(
              key: ValueKey('brush_size_surface_${size.name}'),
              duration: const Duration(milliseconds: 160),
              width: axis == Axis.vertical ? 44 : 54,
              height: axis == Axis.vertical ? 44 : 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFE19A)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8A5B00)
                      : const Color(0xFFD8D3E1),
                  width: isSelected ? 3 : 1.5,
                ),
              ),
              child: Container(
                width: 27,
                height: 3 + (BrushSize.values.indexOf(size) * 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF252333),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.axis,
    required this.selectedColor,
    required this.onSelected,
  });

  final Axis axis;
  final int selectedColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: axis == Axis.vertical ? 104 : null,
    height: axis == Axis.horizontal ? 82 : null,
    child: ListView.separated(
      padding: axis == Axis.horizontal
          ? const EdgeInsets.fromLTRB(6, 10, 6, 0)
          : const EdgeInsets.fromLTRB(10, 6, 4, 6),
      scrollDirection: axis,
      itemCount: coloringPalette.length,
      separatorBuilder: (_, _) => axis == Axis.horizontal
          ? const SizedBox(width: 7)
          : const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final color = coloringPalette[index];
        final isSelected = color == selectedColor;
        return Semantics(
          label: 'Farbe ${index + 1}',
          button: true,
          selected: isSelected,
          child: InkWell(
            key: ValueKey('color_$index'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => onSelected(color),
            child: AnimatedSlide(
              key: ValueKey('color_position_$index'),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              offset: isSelected
                  ? (axis == Axis.horizontal
                        ? const Offset(0, -0.12)
                        : const Offset(-0.12, 0))
                  : Offset.zero,
              child: _ColorPencil(
                key: ValueKey(
                  'color_pencil_${axis == Axis.vertical ? 'horizontal' : 'vertical'}_$index',
                ),
                direction: axis == Axis.vertical
                    ? Axis.horizontal
                    : Axis.vertical,
                color: Color(color),
                selected: isSelected,
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _ColorPencil extends StatelessWidget {
  const _ColorPencil({
    required this.direction,
    required this.color,
    required this.selected,
    super.key,
  });

  final Axis direction;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: direction == Axis.horizontal ? 88 : 38,
    height: direction == Axis.horizontal ? 36 : 70,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: selected ? const Color(0xFF252333) : Colors.transparent,
        width: selected ? 3 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: selected ? 0.28 : 0.1),
          blurRadius: selected ? 7 : 3,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: CustomPaint(painter: _ColorPencilPainter(color, direction)),
  );
}

class _ColorPencilPainter extends CustomPainter {
  const _ColorPencilPainter(this.color, this.direction);

  final Color color;
  final Axis direction;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xFF252333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    if (direction == Axis.horizontal) {
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 5, size.width - 21, size.height - 10),
        const Radius.circular(5),
      );
      canvas.drawRRect(body, Paint()..color = color);
      canvas.drawRRect(body, border);
      canvas.drawPath(
        Path()
          ..moveTo(size.width - 18, 5)
          ..lineTo(size.width - 3, size.height / 2)
          ..lineTo(size.width - 18, size.height - 5)
          ..close(),
        Paint()..color = const Color(0xFFFFE5B4),
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width - 7, size.height / 2 - 3)
          ..lineTo(size.width - 3, size.height / 2)
          ..lineTo(size.width - 7, size.height / 2 + 3)
          ..close(),
        Paint()..color = color,
      );
      canvas.drawLine(
        const Offset(12, 7),
        Offset(size.width - 20, 7),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = 3,
      );
    } else {
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 18, size.width - 10, size.height - 21),
        const Radius.circular(5),
      );
      canvas.drawRRect(body, Paint()..color = color);
      canvas.drawRRect(body, border);
      canvas.drawPath(
        Path()
          ..moveTo(5, 18)
          ..lineTo(size.width / 2, 3)
          ..lineTo(size.width - 5, 18)
          ..close(),
        Paint()..color = const Color(0xFFFFE5B4),
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width / 2 - 3, 7)
          ..lineTo(size.width / 2, 3)
          ..lineTo(size.width / 2 + 3, 7)
          ..close(),
        Paint()..color = color,
      );
      canvas.drawLine(
        const Offset(8, 25),
        Offset(size.width - 8, 25),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ColorPencilPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.direction != direction;
}
