import 'coloring_page.dart';

enum MotifCategory { animals, nature, vehicles }

final class ColoringMotif {
  const ColoringMotif({
    required this.title,
    required this.category,
    required this.page,
  });

  final String title;
  final MotifCategory category;
  final ColoringPage page;
}
