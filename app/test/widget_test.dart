import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/app/pinselino_app.dart';

void main() {
  testWidgets('technical coloring spike is the app home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const PinselinoApp());

    expect(find.text('Pinselino Mal-Test'), findsOneWidget);
    expect(find.text('Male quer über die schwarzen Linien.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('coloring_canvas_gesture')),
      findsOneWidget,
    );
  });
}
