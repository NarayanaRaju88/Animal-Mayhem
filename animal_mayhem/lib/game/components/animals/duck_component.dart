import 'package:flame/components.dart';

import '../../systems/environment/movement_capabilities.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'duck_development_visual.dart';

/// Stage 3 animal that can traverse land and water.
class DuckComponent extends AnimalComponent {
  DuckComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Duck',
        capabilities: MovementCapabilities.landAndWater,
        attributes: AnimalAttributes(speed: 160, size: Vector2(56, 36)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(DuckDevelopmentVisual(size: size));
  }
}
