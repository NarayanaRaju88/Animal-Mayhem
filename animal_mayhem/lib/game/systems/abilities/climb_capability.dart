/// Whether an animal can use configured climbable surfaces.
final class ClimbCapability {
  const ClimbCapability({this.range = 80, this.duration = 0.7});

  /// How close the animal must be to the surface to start a climb.
  final double range;

  /// Seconds to travel from the start anchor to the destination anchor.
  final double duration;
}

/// Environmental requirement satisfied by [ClimbCapability], not by species.
final class ClimbRequirement {
  const ClimbRequirement();

  bool isSatisfiedBy({required bool hasClimbAbility}) => hasClimbAbility;
}

/// Logical climb axis in the 2D world.
enum ClimbDirection { up, down }
