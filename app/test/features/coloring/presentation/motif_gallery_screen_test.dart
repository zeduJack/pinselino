import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/progress_store.dart';
import 'package:pinselino/features/coloring/domain/paint_stroke.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/presentation/motif_gallery_screen.dart';

void main() {
  testWidgets('gallery presents vector and raster motif previews', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
          scaffoldBackgroundColor: const Color(0xFFF7F4FF),
        ),
        home: MotifGalleryScreen(progressStore: MemoryProgressStore()),
      ),
    );
    await tester.pumpAndSettle();

    for (final id in [
      'elephant-raster',
      'cat',
      'fish',
      'flower',
      'tree',
      'car',
    ]) {
      expect(find.byKey(ValueKey('motif_$id')), findsOneWidget);
    }
    await tester.drag(find.byType(GridView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('motif_rocket')), findsOneWidget);
  });

  testWidgets('raster preview renders saved paint strokes', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryProgressStore();
    await store.save('elephant-raster', [
      PaintStroke(
        regionId: 'head',
        colorArgb: 0xFFE84393,
        width: 80,
        points: [Point2D(251, 242), Point2D(300, 260)],
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MotifGalleryScreen(progressStore: store)),
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
    }
    await tester.pump();

    expect(
      find.byKey(const ValueKey('raster_preview_colored_elephant-raster')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
