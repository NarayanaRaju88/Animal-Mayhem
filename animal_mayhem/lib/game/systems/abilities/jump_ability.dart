/// Configurable jump tuning for an animal that can jump.
final class JumpAbility {
  const JumpAbility({
    required this.maxDistance,
    required this.height,
    required this.duration,
  });

  /// Maximum ground distance of one jump.
  final double maxDistance;

  /// Peak visual arc height in world units.
  final double height;

  /// Seconds from takeoff to landing.
  final double duration;
}
