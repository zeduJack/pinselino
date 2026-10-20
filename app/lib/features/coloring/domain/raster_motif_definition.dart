import 'coloring_motif.dart';

final class RasterMotifDefinition {
  const RasterMotifDefinition({
    required this.id,
    required this.title,
    required this.category,
    required this.assetDirectory,
  });

  final String id;
  final String title;
  final MotifCategory category;
  final String assetDirectory;
}

const elephantRasterMotif = RasterMotifDefinition(
  id: 'elephant-raster',
  title: 'Elefant',
  category: MotifCategory.animals,
  assetDirectory: 'assets/coloring/elephant',
);

const _includeLocalReferences = bool.fromEnvironment(
  'PINSELINO_LOCAL_REFERENCES',
);

const rasterMotifDefinitions = <RasterMotifDefinition>[
  elephantRasterMotif,
  if (_includeLocalReferences)
    RasterMotifDefinition(
      id: 'unity-simple',
      title: 'Unity Motiv 1',
      category: MotifCategory.animals,
      assetDirectory: 'assets/local_reference/unity-simple',
    ),
  if (_includeLocalReferences)
    RasterMotifDefinition(
      id: 'unity-medium',
      title: 'Unity Motiv 2',
      category: MotifCategory.animals,
      assetDirectory: 'assets/local_reference/unity-medium',
    ),
  if (_includeLocalReferences)
    RasterMotifDefinition(
      id: 'unity-complex',
      title: 'Unity Motiv 3',
      category: MotifCategory.vehicles,
      assetDirectory: 'assets/local_reference/unity-complex',
    ),
];
