import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../domain/coloring_motif.dart';
import '../domain/coloring_page.dart';
import '../domain/coloring_region.dart';
import '../domain/point_2d.dart';
import '../domain/raster_motif_definition.dart';
import '../domain/raster_region_lookup.dart';

final class LoadedRasterMotif {
  const LoadedRasterMotif({required this.motif, required this.outlineImage});

  final ColoringMotif motif;
  final ui.Image outlineImage;
}

final class RasterMotifLoader {
  RasterMotifLoader({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;

  Future<LoadedRasterMotif> load(RasterMotifDefinition definition) async {
    final directory = definition.assetDirectory;
    final metadata = await _json('$directory/metadata.json');
    final groups = await _json('$directory/paint_groups_easy.json');
    final regionImage = await _image('$directory/regions.png');
    final outlineImage = await _image('$directory/outline.png');
    final width = metadata['width'] as int;
    final height = metadata['height'] as int;
    if (regionImage.width != width || regionImage.height != height) {
      throw const FormatException(
        'region mask dimensions differ from metadata',
      );
    }
    if (outlineImage.width != width || outlineImage.height != height) {
      throw const FormatException('outline dimensions differ from metadata');
    }

    final rgba = await regionImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    regionImage.dispose();
    if (rgba == null) throw const FormatException('cannot decode region mask');
    final ids = Uint32List(width * height);
    for (var pixel = 0; pixel < ids.length; pixel++) {
      final offset = pixel * 4;
      ids[pixel] =
          rgba.getUint8(offset) |
          (rgba.getUint8(offset + 1) << 8) |
          (rgba.getUint8(offset + 2) << 16);
    }

    final mapping = <int, String>{};
    for (final entry
        in (groups['technicalToPaintGroup'] as Map<String, dynamic>).entries) {
      mapping[int.parse(entry.key)] = entry.value as String;
    }
    final regions = (groups['paintGroups'] as List<dynamic>).map((rawGroup) {
      final group = rawGroup as Map<String, dynamic>;
      final paths = (group['paths'] as List<dynamic>).map((rawPath) {
        final path = rawPath as Map<String, dynamic>;
        return ColoringPath(
          isHole: path['isHole'] as bool,
          points: (path['points'] as List<dynamic>).map((rawPoint) {
            final point = rawPoint as List<dynamic>;
            return Point2D(
              (point[0] as num).toDouble(),
              (point[1] as num).toDouble(),
            );
          }),
        );
      });
      return ColoringRegion.fromPaths(id: group['id'] as String, paths: paths);
    }).toList();

    final page = ColoringPage(
      id: definition.id,
      size: Size2D(width.toDouble(), height.toDouble()),
      regions: regions,
      regionLookup: RasterRegionLookup(
        width: width,
        height: height,
        technicalRegionIds: ids,
        technicalToPaintGroup: mapping,
      ),
    );
    return LoadedRasterMotif(
      motif: ColoringMotif(
        title: definition.title,
        category: definition.category,
        page: page,
      ),
      outlineImage: outlineImage,
    );
  }

  Future<Map<String, dynamic>> _json(String asset) async =>
      jsonDecode(await bundle.loadString(asset)) as Map<String, dynamic>;

  Future<ui.Image> _image(String asset) async {
    final data = await bundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final image = (await codec.getNextFrame()).image;
    codec.dispose();
    return image;
  }
}
