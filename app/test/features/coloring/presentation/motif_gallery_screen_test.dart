import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/progress_store.dart';
import 'package:pinselino/features/coloring/presentation/motif_gallery_screen.dart';

void main() {
  testWidgets('gallery presents all six recognizable motif previews', (
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

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/motif_gallery.png'),
    );
  });
}
