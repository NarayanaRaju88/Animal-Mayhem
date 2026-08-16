/// Whether an animal can hold a compatible environmental mechanism.
final class CoilCapability {
  const CoilCapability({this.range = 80});

  /// How close the animal must be to the anchor to start a coil.
  final double range;
}

/// Environmental requirement satisfied by [CoilCapability], not by species.
final class CoilRequirement {
  const CoilRequirement();

  bool isSatisfiedBy({required bool hasCoilAbility}) => hasCoilAbility;
}
