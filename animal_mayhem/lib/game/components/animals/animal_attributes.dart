import 'package:flame/components.dart';

/// Shared tunable traits for an animal species.
///
/// Future animals can supply different speeds, sizes, and turn rates without
/// rewriting the movement loop.
final class AnimalAttributes {
  const AnimalAttributes({
    required this.speed,
    required this.size,
    this.steerRate = 8,
    this.turnRate = 10,
    this.arrivalThreshold = 10,
    this.followDistance = 72,
  });

  /// World units per second.
  final double speed;

  /// Axis-aligned body size used for drawing and boundary padding.
  final Vector2 size;

  /// How quickly velocity blends toward the desired heading.
  final double steerRate;

  /// How quickly facing rotates toward the current velocity, in blend units.
  final double turnRate;

  /// Distance at which the animal considers the target reached.
  final double arrivalThreshold;

  /// Distance maintained when following another target.
  final double followDistance;
}
