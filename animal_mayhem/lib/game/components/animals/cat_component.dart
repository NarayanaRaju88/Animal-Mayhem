import 'package:flame/components.dart';

import '../../systems/abilities/animal_abilities.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'cat_development_visual.dart';

/// Stage 5 animal that fits narrow passages and can interact with objects.
class CatComponent extends AnimalComponent {
  CatComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Cat',
        capabilities: MovementCapabilities.landOnly,
        abilities: AnimalAbilities.walkAndInteract,
        profile: const PhysicalProfile(bodyWidth: 34, bodyHeight: 26),
        attributes: AnimalAttributes(speed: 210, size: Vector2(34, 26)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CatDevelopmentVisual(size: size));
  }
}
