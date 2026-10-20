import 'package:flutter/material.dart';

import '../application/coloring_controller.dart';
import '../application/progress_store.dart';
import '../domain/coloring_motif.dart';
import '../domain/motif_catalog.dart';
import '../domain/paint_stroke.dart';
import '../domain/raster_motif_definition.dart';
import '../infrastructure/raster_motif_loader.dart';
import 'coloring_canvas.dart';
import 'coloring_spike_screen.dart';

class MotifGalleryScreen extends StatefulWidget {
  const MotifGalleryScreen({
    required this.progressStore,
    this.rasterLoader,
    super.key,
  });

  final ProgressStore progressStore;
  final RasterMotifLoader? rasterLoader;

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
    final motifIds = [
      ...motifCatalog.map((motif) => motif.page.id),
      ...rasterMotifDefinitions.map((motif) => motif.id),
    ];
    final entries = await Future.wait(
      motifIds.map(
        (motifId) async =>
            MapEntry(motifId, await widget.progressStore.load(motifId)),
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

  Future<void> _openRaster(
    RasterMotifDefinition definition, {
    required bool startNew,
  }) async {
    if (startNew) await widget.progressStore.delete(definition.id);
    final loaded = await (widget.rasterLoader ?? RasterMotifLoader()).load(
      definition,
    );
    final strokes = startNew
        ? <PaintStroke>[]
        : (_progress[definition.id] ?? const <PaintStroke>[]);
    if (!mounted) return;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ColoringSpikeScreen(
            motif: loaded.motif,
            progressStore: widget.progressStore,
            initialStrokes: strokes,
            outlineImage: loaded.outlineImage,
          ),
        ),
      );
    } finally {
      loaded.outlineImage.dispose();
    }
    await _reload();
  }

  Future<void> _selectRaster(RasterMotifDefinition definition) async {
    final hasProgress = (_progress[definition.id] ?? const []).isNotEmpty;
    if (!hasProgress) return _openRaster(definition, startNew: false);
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
                    _openRaster(definition, startNew: false);
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
                    _openRaster(definition, startNew: true);
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
    final visibleRaster = rasterMotifDefinitions
        .where((motif) => _category == null || motif.category == _category)
        .toList();
    final itemCount = visibleRaster.length + visible.length;
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
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index < visibleRaster.length) {
                    final definition = visibleRaster[index];
                    return _RasterMotifCard(
                      definition: definition,
                      hasProgress:
                          (_progress[definition.id] ?? const []).isNotEmpty,
                      onTap: () => _selectRaster(definition),
                    );
                  }
                  final motif = visible[index - visibleRaster.length];
                  return _MotifCard(
                    motif: motif,
                    strokes: _progress[motif.page.id] ?? const [],
                    onTap: () => _select(motif),
                  );
                },
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

class _RasterMotifCard extends StatelessWidget {
  const _RasterMotifCard({
    required this.definition,
    required this.hasProgress,
    required this.onTap,
  });

  final RasterMotifDefinition definition;
  final bool hasProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey('motif_${definition.id}'),
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  '${definition.assetDirectory}/outline.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    definition.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (hasProgress)
                  const Icon(Icons.palette_rounded, color: Color(0xFF6C5CE7)),
              ],
            ),
          ),
        ],
      ),
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
