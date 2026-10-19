import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/domain/motif_catalog.dart';

void main() {
  test('catalog contains six unique and valid motifs', () {
    expect(motifCatalog, hasLength(6));
    expect(motifCatalog.map((motif) => motif.page.id).toSet(), hasLength(6));
    expect(motifCatalog.map((motif) => motif.category).toSet(), hasLength(3));

    for (final motif in motifCatalog) {
      for (final region in motif.page.regions) {
        expect(region.vertices.length, greaterThanOrEqualTo(3));
        for (final point in region.vertices) {
          expect(point.x, inInclusiveRange(0, motif.page.size.width));
          expect(point.y, inInclusiveRange(0, motif.page.size.height));
        }
        final twiceArea = List.generate(region.vertices.length, (index) {
          final current = region.vertices[index];
          final next = region.vertices[(index + 1) % region.vertices.length];
          return current.x * next.y - next.x * current.y;
        }).fold<double>(0, (sum, value) => sum + value).abs();
        expect(
          twiceArea,
          greaterThan(100),
          reason: '${motif.page.id}/${region.id}',
        );
      }
    }
  });
}
