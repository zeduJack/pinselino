import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/application/progress_store.dart';
import 'package:pinselino/features/coloring/domain/motif_catalog.dart';
import 'package:pinselino/features/coloring/presentation/coloring_spike_screen.dart';

void main() {
  testWidgets(
    'controls move around the canvas and brush sizes change stroke width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final store = MemoryProgressStore();

      await tester.pumpWidget(
        MaterialApp(
          home: ColoringSpikeScreen(
            motif: motifCatalog.first,
            progressStore: store,
            initialStrokes: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('landscape_controls')), findsOneWidget);
      var canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
      expect(
        tester.getCenter(find.byKey(const ValueKey('tool_marker'))).dx,
        lessThan(tester.getCenter(canvas).dx),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('color_0'))).dx,
        greaterThan(tester.getCenter(canvas).dx),
      );

      await tester.tap(find.byKey(const ValueKey('brush_size_small')));
      await tester.pump();
      await tester.dragFrom(tester.getCenter(canvas), const Offset(12, 4));
      await tester.pump();
      expect(
        (await store.load(motifCatalog.first.page.id)).single.width,
        closeTo(15.6, 0.001),
      );

      await tester.tap(find.byKey(const ValueKey('brush_size_large')));
      await tester.pump();
      await tester.dragFrom(tester.getCenter(canvas), const Offset(-12, 4));
      await tester.pump();
      final strokes = await store.load(motifCatalog.first.page.id);
      expect(strokes.last.width, closeTo(37.2, 0.001));

      tester.view.physicalSize = const Size(700, 1200);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('portrait_controls')), findsOneWidget);
      canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
      expect(
        tester.getCenter(find.byKey(const ValueKey('tool_marker'))).dy,
        lessThan(tester.getCenter(canvas).dy),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('color_0'))).dy,
        greaterThan(tester.getCenter(canvas).dy),
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('brush_size_large')))
            .isSelected,
        isTrue,
      );
    },
  );
}
