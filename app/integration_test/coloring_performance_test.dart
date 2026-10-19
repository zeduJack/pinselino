import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinselino/app/pinselino_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('continuous coloring remains within the Phase 1 frame budget', (
    tester,
  ) async {
    await tester.pumpWidget(const PinselinoApp());
    await tester.pumpAndSettle();

    final frameTimings = <FrameTiming>[];
    void collectTimings(List<FrameTiming> timings) =>
        frameTimings.addAll(timings);
    SchedulerBinding.instance.addTimingsCallback(collectTimings);

    final canvas = find.byKey(const ValueKey('coloring_canvas_gesture'));
    final bounds = tester.getRect(canvas);
    final start = Offset(bounds.left + bounds.width * 0.08, bounds.center.dy);
    final gesture = await tester.startGesture(start);
    for (var frame = 0; frame < 180; frame++) {
      final progress = frame / 179;
      final wave = (frame % 30) / 29;
      await gesture.moveTo(
        Offset(
          bounds.left + bounds.width * (0.08 + progress * 0.84),
          bounds.top + bounds.height * (0.25 + wave * 0.5),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    SchedulerBinding.instance.removeTimingsCallback(collectTimings);

    expect(frameTimings.length, greaterThanOrEqualTo(120));
    final totalMicros =
        frameTimings.map((timing) => timing.totalSpan.inMicroseconds).toList()
          ..sort();
    final buildMicros =
        frameTimings
            .map((timing) => timing.buildDuration.inMicroseconds)
            .toList()
          ..sort();
    final rasterMicros =
        frameTimings
            .map((timing) => timing.rasterDuration.inMicroseconds)
            .toList()
          ..sort();

    int percentile(List<int> values, double fraction) =>
        values[((values.length - 1) * fraction).round()];

    final result = <String, Object>{
      'frames': frameTimings.length,
      'total_p50_ms': percentile(totalMicros, 0.50) / 1000,
      'total_p90_ms': percentile(totalMicros, 0.90) / 1000,
      'total_p99_ms': percentile(totalMicros, 0.99) / 1000,
      'build_p90_ms': percentile(buildMicros, 0.90) / 1000,
      'raster_p90_ms': percentile(rasterMicros, 0.90) / 1000,
    };
    binding.reportData = result;
    debugPrint('PINSELINO_PERFORMANCE: $result');

    expect(
      percentile(totalMicros, 0.90),
      lessThanOrEqualTo(32000),
      reason: 'At least 90% of interaction frames must stay within 32 ms.',
    );
  });
}
