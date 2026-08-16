import 'package:flame/components.dart';

import '../../systems/abilities/animal_abilities.dart';
import '../../systems/environment/force_capability.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import 'animal_attributes.dart';
import 'animal_component.dart';
import 'buffalo_development_visual.dart';

/// Stage 8 heavy animal. Force and profile are data, not species checks.
class BuffaloComponent extends AnimalComponent {
  BuffaloComponent({required super.worldBounds, super.position, super.terrain})
    : super(
        speciesName: 'Buffalo',
        capabilities: MovementCapabilities.landOnly,
        abilities: AnimalAbilities.walk,
        force: ForceCapability.heavy,
        profile: const PhysicalProfile(bodyWidth: 96, bodyHeight: 56),
        attributes: AnimalAttributes(speed: 140, size: Vector2(96, 56)),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(BuffaloDevelopmentVisual(size: size));
  }
}
