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
        icon: Icons.edit_rounded,
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.crayon,
        label: 'Kreide',
        icon: Icons.draw_rounded,
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.softBrush,
        label: 'Pinsel',
        icon: Icons.brush_rounded,
        compact: axis == Axis.vertical,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.eraser,
        label: 'Radierer',
        icon: Icons.auto_fix_normal_rounded,
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
    required this.icon,
    required this.compact,
    required this.selected,
    required this.onSelected,
  });

  final BrushKind kind;
  final String label;
  final IconData icon;
  final bool compact;
  final BrushKind selected;
  final ValueChanged<BrushKind> onSelected;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Semantics(
        label: label,
        button: true,
        selected: selected == kind,
        child: IconButton.filledTonal(
          key: ValueKey('tool_${kind.name}'),
          tooltip: label,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          padding: const EdgeInsets.all(8),
          isSelected: selected == kind,
          onPressed: () => onSelected(kind),
          icon: Icon(icon),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: ChoiceChip(
        key: ValueKey('tool_${kind.name}'),
        selected: selected == kind,
        onSelected: (_) => onSelected(kind),
        avatar: Icon(icon),
        label: Text(label),
      ),
    );
  }
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
        child: IconButton.filledTonal(
          key: ValueKey('brush_size_${size.name}'),
          tooltip: size.label,
          onPressed: () => onSelected(size),
          constraints: axis == Axis.vertical
              ? const BoxConstraints.tightFor(width: 40, height: 40)
              : null,
          padding: const EdgeInsets.all(8),
          isSelected: isSelected,
          icon: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Container(
              width: 7 + (BrushSize.values.indexOf(size) * 5),
              height: 7 + (BrushSize.values.indexOf(size) * 5),
              decoration: const BoxDecoration(
                color: Color(0xFF252333),
                shape: BoxShape.circle,
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
    width: axis == Axis.vertical ? 62 : null,
    height: axis == Axis.horizontal ? 78 : null,
    child: ListView.separated(
      padding: axis == Axis.horizontal
          ? const EdgeInsets.fromLTRB(6, 10, 6, 0)
          : const EdgeInsets.fromLTRB(10, 6, 4, 6),
      scrollDirection: axis,
      itemCount: coloringPalette.length,
      separatorBuilder: (_, _) => const SizedBox(width: 7),
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
              child: _ColorPencil(color: Color(color), selected: isSelected),
            ),
          ),
        );
      },
    ),
  );
}

class _ColorPencil extends StatelessWidget {
  const _ColorPencil({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: 38,
    height: 64,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(18),
        bottom: Radius.circular(7),
      ),
      color: color,
      border: Border.all(
        color: selected ? const Color(0xFF252333) : Colors.white,
        width: selected ? 4 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: selected ? 0.3 : 0.12),
          blurRadius: selected ? 8 : 3,
          offset: Offset(0, selected ? 5 : 2),
        ),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        ),
        const Spacer(),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(5),
            ),
          ),
        ),
      ],
    ),
  );
}
