import 'package:flame/components.dart';

import '../../systems/abilities/animal_abilities.dart';
import '../../systems/abilities/coil_capability.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'snake_development_visual.dart';

/// Stage 10 animal that can hold compatible environmental mechanisms.
class SnakeComponent extends AnimalComponent {
  SnakeComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Snake',
        capabilities: MovementCapabilities.landOnly,
        abilities: AnimalAbilities.walkAndCoil,
        coilAbility: const CoilCapability(),
        profile: const PhysicalProfile(bodyWidth: 52, bodyHeight: 24),
        attributes: AnimalAttributes(speed: 180, size: Vector2(52, 24)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(SnakeDevelopmentVisual(size: size));
  }
}
