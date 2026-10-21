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
                      strokes: _progress[definition.id] ?? const [],
                      loader: widget.rasterLoader,
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

class _RasterMotifCard extends StatefulWidget {
  const _RasterMotifCard({
    required this.definition,
    required this.strokes,
    required this.onTap,
    this.loader,
  });

  final RasterMotifDefinition definition;
  final List<PaintStroke> strokes;
  final VoidCallback onTap;
  final RasterMotifLoader? loader;

  @override
  State<_RasterMotifCard> createState() => _RasterMotifCardState();
}

class _RasterMotifCardState extends State<_RasterMotifCard> {
  Future<LoadedRasterMotif>? _future;
  LoadedRasterMotif? _loaded;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.strokes.isNotEmpty) _load();
  }

  @override
  void didUpdateWidget(covariant _RasterMotifCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.id != widget.definition.id) {
      _generation++;
      _loaded?.outlineImage.dispose();
      _loaded = null;
      _future = null;
    }
    if (widget.strokes.isNotEmpty && _future == null) _load();
  }

  void _load() {
    final generation = _generation;
    _future = (widget.loader ?? RasterMotifLoader())
        .load(widget.definition)
        .then((loaded) {
          if (!mounted || generation != _generation) {
            loaded.outlineImage.dispose();
          } else {
            _loaded = loaded;
          }
          return loaded;
        });
  }

  @override
  void dispose() {
    _loaded?.outlineImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey('motif_${widget.definition.id}'),
      onTap: widget.onTap,
      child: Column(
        children: [
          Expanded(child: _preview()),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.definition.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (widget.strokes.isNotEmpty)
                  const Icon(Icons.palette_rounded, color: Color(0xFF6C5CE7)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _preview() {
    if (widget.strokes.isEmpty) {
      return ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            '${widget.definition.assetDirectory}/outline.png',
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return FutureBuilder<LoadedRasterMotif>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final loaded = snapshot.requireData;
        final controller = ColoringController(page: loaded.motif.page)
          ..restore(widget.strokes);
        return IgnorePointer(
          child: ColoringCanvas(
            key: ValueKey('raster_preview_colored_${widget.definition.id}'),
            controller: controller,
            outlineImage: loaded.outlineImage,
          ),
        );
      },
    );
  }
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
