import 'package:flame/components.dart';

import 'animal_art.dart';

/// In-world cat art. Collision and movement stay on [CatComponent].
class CatDevelopmentVisual extends RealisticAnimalVisual {
  CatDevelopmentVisual({required Vector2 size})
    : super(kind: AnimalArtKind.cat, bodySize: size);
}
