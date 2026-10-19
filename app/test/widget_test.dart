import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/app/pinselino_app.dart';

void main() {
  testWidgets('coloring tools support palette, history, and confirmed reset', (
    tester,
  ) async {
    await tester.pumpWidget(const PinselinoApp());

    expect(find.text('Pinselino Mal-Test'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('coloring_canvas_gesture')),
      findsOneWidget,
    );
    for (var index = 0; index < 8; index++) {
      expect(find.byKey(ValueKey('color_$index')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('tool_marker')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool_eraser')), findsOneWidget);

    final canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
    await tester.dragFrom(tester.getCenter(canvas), const Offset(25, 10));
    await tester.pump();

    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('undo_button')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('undo_button')));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('redo_button')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('redo_button')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('reset_button')));
    await tester.pumpAndSettle();
    expect(find.text('Bild neu anfangen?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cancel_reset')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('undo_button')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey('reset_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm_reset')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('undo_button')))
          .onPressed,
      isNull,
    );
  });
}
