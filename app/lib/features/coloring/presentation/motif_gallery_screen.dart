import 'package:flutter/material.dart';

import '../application/coloring_controller.dart';
import '../application/progress_store.dart';
import '../domain/coloring_motif.dart';
import '../domain/motif_catalog.dart';
import '../domain/paint_stroke.dart';
import 'coloring_canvas.dart';
import 'coloring_spike_screen.dart';

class MotifGalleryScreen extends StatefulWidget {
  const MotifGalleryScreen({required this.progressStore, super.key});

  final ProgressStore progressStore;

  @override
  State<MotifGalleryScreen> createState() => _MotifGalleryScreenState();
}

class _MotifGalleryScreenState extends State<MotifGalleryScreen> {
  MotifCategory? _category;
  Map<String, List<PaintStroke>> _progress = const {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await Future.wait(
      motifCatalog.map(
        (motif) async => MapEntry(
          motif.page.id,
          await widget.progressStore.load(motif.page.id),
        ),
      ),
    );
    if (mounted) setState(() => _progress = Map.fromEntries(entries));
  }

  Future<void> _open(ColoringMotif motif, {required bool startNew}) async {
    if (startNew) await widget.progressStore.delete(motif.page.id);
    final strokes = startNew
        ? <PaintStroke>[]
        : (_progress[motif.page.id] ?? const <PaintStroke>[]);
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ColoringSpikeScreen(
          motif: motif,
          progressStore: widget.progressStore,
          initialStrokes: strokes,
        ),
      ),
    );
    await _reload();
  }

  Future<void> _select(ColoringMotif motif) async {
    final hasProgress = (_progress[motif.page.id] ?? const []).isNotEmpty;
    if (!hasProgress) return _open(motif, startNew: false);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('continue_motif'),
                  onPressed: () {
                    Navigator.pop(context);
                    _open(motif, startNew: false);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Weitermalen'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('restart_motif'),
                  onPressed: () {
                    Navigator.pop(context);
                    _open(motif, startNew: true);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Neu anfangen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = motifCatalog
        .where((motif) => _category == null || motif.category == _category)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Pinselino')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip(null, 'Alle'),
                  _categoryChip(MotifCategory.animals, 'Tiere'),
                  _categoryChip(MotifCategory.nature, 'Natur'),
                  _categoryChip(MotifCategory.vehicles, 'Fahrzeuge'),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .9,
                ),
                itemCount: visible.length,
                itemBuilder: (context, index) => _MotifCard(
                  motif: visible[index],
                  strokes: _progress[visible[index].page.id] ?? const [],
                  onTap: () => _select(visible[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(MotifCategory? category, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      key: ValueKey('category_${category?.name ?? 'all'}'),
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => setState(() => _category = category),
    ),
  );
}

class _MotifCard extends StatelessWidget {
  const _MotifCard({
    required this.motif,
    required this.strokes,
    required this.onTap,
  });

  final ColoringMotif motif;
  final List<PaintStroke> strokes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = ColoringController(page: motif.page)..restore(strokes);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('motif_${motif.page.id}'),
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: IgnorePointer(
                child: ColoringCanvas(controller: controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      motif.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (strokes.isNotEmpty)
                    const Icon(Icons.palette_rounded, color: Color(0xFF6C5CE7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
