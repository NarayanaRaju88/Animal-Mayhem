import '../../components/animals/animal_component.dart';
import '../abilities/ability_kind.dart';
import 'force_capability.dart';

/// Configuration for who may activate an occupancy-based object.
abstract interface class OccupancyRequirement {
  bool isSatisfiedBy(AnimalComponent animal);
}

/// Matches an animal by its configured [speciesName].
final class SpeciesRequirement implements OccupancyRequirement {
  const SpeciesRequirement(this.speciesName);

  final String speciesName;

  @override
  bool isSatisfiedBy(AnimalComponent animal) =>
      animal.speciesName == speciesName;
}

/// Matches any animal that has [kind].
final class AbilityRequirement implements OccupancyRequirement {
  const AbilityRequirement(this.kind);

  final AbilityKind kind;

  @override
  bool isSatisfiedBy(AnimalComponent animal) => animal.abilities.has(kind);
}

/// Matches animals whose force weight meets [minimum].
final class WeightRequirement implements OccupancyRequirement {
  const WeightRequirement(this.minimum);

  final WeightClass minimum;

  @override
  bool isSatisfiedBy(AnimalComponent animal) =>
      animal.force.weightClass.index >= minimum.index;
}
