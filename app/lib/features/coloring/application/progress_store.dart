import '../domain/paint_stroke.dart';

abstract interface class ProgressStore {
  Future<List<PaintStroke>> load(String motifId);
  Future<void> save(String motifId, List<PaintStroke> strokes);
  Future<void> delete(String motifId);
}

final class MemoryProgressStore implements ProgressStore {
  final Map<String, List<PaintStroke>> _values = {};

  @override
  Future<List<PaintStroke>> load(String motifId) async =>
      List.unmodifiable(_values[motifId] ?? const []);

  @override
  Future<void> save(String motifId, List<PaintStroke> strokes) async {
    _values[motifId] = List.of(strokes);
  }

  @override
  Future<void> delete(String motifId) async => _values.remove(motifId);
}
