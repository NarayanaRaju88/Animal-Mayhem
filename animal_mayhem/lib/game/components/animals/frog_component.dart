import 'package:flame/components.dart';

import '../../systems/abilities/animal_abilities.dart';
import '../../systems/abilities/jump_ability.dart';
import '../../systems/environment/movement_capabilities.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'frog_development_visual.dart';

/// Stage 4 animal that can walk, enter water, and jump obstacles.
class FrogComponent extends AnimalComponent {
  FrogComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Frog',
        capabilities: MovementCapabilities.landAndWater,
        abilities: AnimalAbilities.walkerSwimmerJumper,
        jumpAbility: const JumpAbility(
          maxDistance: 380,
          height: 90,
          duration: 0.55,
        ),
        attributes: AnimalAttributes(speed: 170, size: Vector2(52, 40)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(FrogDevelopmentVisual(size: size));
  }
}
