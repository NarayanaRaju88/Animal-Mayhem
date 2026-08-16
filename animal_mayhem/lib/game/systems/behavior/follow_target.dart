import 'package:flame/components.dart';

/// Something an animal can move toward.
///
/// Stage 2 uses world positions. Later implementations can wrap another
/// animal, a moving object, or a gameplay marker without changing movement.
abstract interface class FollowTarget {
  Vector2 get worldPosition;
}

/// A target defined by a world-space point.
final class WorldPositionTarget implements FollowTarget {
  WorldPositionTarget(Vector2 position) : worldPosition = position.clone();

  @override
  final Vector2 worldPosition;
}
