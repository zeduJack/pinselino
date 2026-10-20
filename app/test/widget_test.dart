import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/app/pinselino_app.dart';
import 'package:pinselino/features/coloring/application/progress_store.dart';

void main() {
  testWidgets('complete flow selects, colors, saves, and continues a motif', (
    tester,
  ) async {
    final store = MemoryProgressStore();
    await tester.pumpWidget(PinselinoApp(progressStore: store));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('motif_cat')), findsOneWidget);
    expect(find.byKey(const ValueKey('motif_fish')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('category_nature')));
    await tester.pump();
    expect(find.byKey(const ValueKey('motif_flower')), findsOneWidget);
    expect(find.byKey(const ValueKey('motif_cat')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('category_all')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('motif_cat')));
    await tester.pumpAndSettle();

    for (var index = 0; index < 8; index++) {
      expect(find.byKey(ValueKey('color_$index')), findsOneWidget);
    }
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const ValueKey('color_position_0')))
          .offset,
      const Offset(0, -0.14),
    );
    await tester.tap(find.byKey(const ValueKey('color_1')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const ValueKey('color_position_1')))
          .offset,
      const Offset(0, -0.14),
    );
    expect(find.byKey(const ValueKey('tool_marker')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool_crayon')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool_softBrush')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool_eraser')), findsOneWidget);

    final canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
    await tester.dragFrom(tester.getCenter(canvas), const Offset(20, 10));
    await tester.pump();
    expect(await store.load('cat'), isNotEmpty);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('motif_cat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('continue_motif')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('continue_motif')));
    await tester.pumpAndSettle();
    expect(find.text('Katze'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('motif_cat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('restart_motif')));
    await tester.pumpAndSettle();
    expect(await store.load('cat'), isEmpty);
  });

  testWidgets('reset requires confirmation and removes saved progress', (
    tester,
  ) async {
    final store = MemoryProgressStore();
    await tester.pumpWidget(PinselinoApp(progressStore: store));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('motif_cat')));
    await tester.pumpAndSettle();
    final canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
    await tester.dragFrom(tester.getCenter(canvas), const Offset(20, 10));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('reset_button')));
    await tester.pumpAndSettle();
    expect(find.text('Bild neu anfangen?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cancel_reset')));
    await tester.pumpAndSettle();
    expect(await store.load('cat'), isNotEmpty);

    await tester.tap(find.byKey(const ValueKey('reset_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm_reset')));
    await tester.pumpAndSettle();
    expect(await store.load('cat'), isEmpty);
  });
}
