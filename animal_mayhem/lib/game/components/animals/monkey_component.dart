import 'package:flame/components.dart';

import '../../systems/abilities/animal_abilities.dart';
import '../../systems/abilities/climb_capability.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'monkey_development_visual.dart';

/// Stage 9 animal that can climb configured surfaces.
class MonkeyComponent extends AnimalComponent {
  MonkeyComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Monkey',
        capabilities: MovementCapabilities.landOnly,
        abilities: AnimalAbilities.walkAndClimb,
        climbAbility: const ClimbCapability(),
        profile: const PhysicalProfile(bodyWidth: 44, bodyHeight: 36),
        attributes: AnimalAttributes(speed: 200, size: Vector2(44, 36)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MonkeyDevelopmentVisual(size: size));
  }
}
