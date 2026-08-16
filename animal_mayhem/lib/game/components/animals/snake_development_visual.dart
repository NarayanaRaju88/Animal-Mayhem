import 'package:flame/components.dart';

import 'animal_art.dart';

class SnakeDevelopmentVisual extends RealisticAnimalVisual {
  SnakeDevelopmentVisual({required Vector2 size})
    : super(kind: AnimalArtKind.snake, bodySize: size);
}
