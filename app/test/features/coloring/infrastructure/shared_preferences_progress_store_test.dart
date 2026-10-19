import 'package:flutter_test/flutter_test.dart';
import 'package:pinselino/features/coloring/domain/paint_stroke.dart';
import 'package:pinselino/features/coloring/domain/point_2d.dart';
import 'package:pinselino/features/coloring/infrastructure/shared_preferences_progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists, reloads, and deletes progress by motif', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesProgressStore(preferences);
    final stroke = PaintStroke(
      regionId: 'body',
      colorArgb: 0xFF00A8FF,
      width: 24,
      points: const [Point2D(10, 20)],
    );

    await store.save('cat', [stroke]);

    expect((await store.load('cat')).single.colorArgb, 0xFF00A8FF);
    expect(await store.load('fish'), isEmpty);

    await store.delete('cat');
    expect(await store.load('cat'), isEmpty);
  });
}
