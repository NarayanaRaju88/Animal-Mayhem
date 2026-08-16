import 'package:flame/components.dart';

import 'animal_art.dart';

class DogDevelopmentVisual extends RealisticAnimalVisual {
  DogDevelopmentVisual({required Vector2 size})
    : super(kind: AnimalArtKind.dog, bodySize: size);
}
