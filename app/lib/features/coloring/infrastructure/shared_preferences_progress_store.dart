import 'package:shared_preferences/shared_preferences.dart';

import '../application/progress_store.dart';
import '../domain/paint_stroke.dart';
import 'progress_codec.dart';

final class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore(this._preferences, {ProgressCodec? codec})
    : _codec = codec ?? ProgressCodec();

  static const _prefix = 'coloring-progress-';
  final SharedPreferences _preferences;
  final ProgressCodec _codec;

  @override
  Future<List<PaintStroke>> load(String motifId) async =>
      _codec.decode(_preferences.getString('$_prefix$motifId'));

  @override
  Future<void> save(String motifId, List<PaintStroke> strokes) async {
    await _preferences.setString('$_prefix$motifId', _codec.encode(strokes));
  }

  @override
  Future<void> delete(String motifId) async {
    await _preferences.remove('$_prefix$motifId');
  }
}
