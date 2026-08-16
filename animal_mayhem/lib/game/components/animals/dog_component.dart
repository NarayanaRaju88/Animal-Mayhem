import 'package:flame/components.dart';

import 'animal_attributes.dart';
import 'animal_component.dart';
import 'dog_development_visual.dart';

/// Stage 2 prototype animal. Uses shared movement; only the visual is unique.
class DogComponent extends AnimalComponent {
  DogComponent({required super.worldBounds, super.position})
    : super(attributes: AnimalAttributes(speed: 220, size: Vector2(64, 40)));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(DogDevelopmentVisual(size: size));
  }
}
