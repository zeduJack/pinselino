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

class ColoringSpikeScreen extends StatefulWidget {
  const ColoringSpikeScreen({
    required this.motif,
    required this.progressStore,
    required this.initialStrokes,
    super.key,
  });

  final ColoringMotif motif;
  final ProgressStore progressStore;
  final List<PaintStroke> initialStrokes;

  @override
  State<ColoringSpikeScreen> createState() => _ColoringSpikeScreenState();
}

class _ColoringSpikeScreenState extends State<ColoringSpikeScreen> {
  late final ColoringController _controller;
  var _selectedColor = coloringPalette.first;
  var _selectedBrush = BrushKind.marker;

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

  double get _brushWidth => switch (_selectedBrush) {
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
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            _ToolBar(
              selected: _selectedBrush,
              onSelected: (brush) => setState(() => _selectedBrush = brush),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoringCanvas(
                  controller: _controller,
                  colorArgb: _selectedColor,
                  brushKind: _selectedBrush,
                  brushWidth: _brushWidth,
                  onStrokeCompleted: () {
                    setState(() {});
                    _save();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ColorPalette(
              selectedColor: _selectedColor,
              onSelected: (color) => setState(() {
                _selectedColor = color;
                if (_selectedBrush == BrushKind.eraser) {
                  _selectedBrush = BrushKind.marker;
                }
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ToolBar extends StatelessWidget {
  const _ToolBar({required this.selected, required this.onSelected});

  final BrushKind selected;
  final ValueChanged<BrushKind> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _ToolButton(
        kind: BrushKind.marker,
        label: 'Stift',
        icon: Icons.edit_rounded,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.crayon,
        label: 'Kreide',
        icon: Icons.draw_rounded,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.softBrush,
        label: 'Pinsel',
        icon: Icons.brush_rounded,
        selected: selected,
        onSelected: onSelected,
      ),
      _ToolButton(
        kind: BrushKind.eraser,
        label: 'Radierer',
        icon: Icons.auto_fix_normal_rounded,
        selected: selected,
        onSelected: onSelected,
      ),
    ],
  );
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.kind,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final BrushKind kind;
  final String label;
  final IconData icon;
  final BrushKind selected;
  final ValueChanged<BrushKind> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      key: ValueKey('tool_${kind.name}'),
      selected: selected == kind,
      onSelected: (_) => onSelected(kind),
      avatar: Icon(icon),
      label: Text(label),
    ),
  );
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.selectedColor, required this.onSelected});

  final int selectedColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 86,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
      scrollDirection: Axis.horizontal,
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
              offset: isSelected ? const Offset(0, -0.14) : Offset.zero,
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
