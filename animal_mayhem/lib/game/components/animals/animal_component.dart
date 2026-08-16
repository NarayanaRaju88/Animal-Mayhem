import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/utils/angles.dart';
import '../../systems/behavior/follow_target.dart';
import 'animal_attributes.dart';
import 'animal_state.dart';

/// Reusable animal body: position, movement, facing, target, and bounds.
///
/// Species such as [DogComponent] supply attributes and a visual child. Keep
/// Flutter widgets out of this type.
class AnimalComponent extends PositionComponent {
  AnimalComponent({
    required this.attributes,
    required this.worldBounds,
    Vector2? position,
  }) : super(
         position: position?.clone() ?? Vector2.zero(),
         size: attributes.size.clone(),
         anchor: Anchor.center,
       );

  final AnimalAttributes attributes;
  Rect worldBounds;

  AnimalState state = AnimalState.idle;
  FollowTarget? target;

  final Vector2 velocity = Vector2.zero();

  /// Moves toward a fixed world point. Clamped to the playable inner bounds.
  void moveTo(Vector2 worldPosition) {
    final Vector2 clamped = clampToInnerBounds(worldPosition);
    target = WorldPositionTarget(clamped);
    state = AnimalState.moving;
  }

  /// Follows any [FollowTarget], including a later moving animal or object.
  void follow(FollowTarget newTarget) {
    target = newTarget;
    state = AnimalState.following;
  }

  void clearTarget() {
    target = null;
    state = AnimalState.idle;
    velocity.setZero();
  }

  void resetTo(Vector2 spawn) {
    position.setFrom(clampToInnerBounds(spawn));
    angle = 0;
    clearTarget();
  }

  Vector2 clampToInnerBounds(Vector2 point) {
    final double halfWidth = size.x / 2;
    final double halfHeight = size.y / 2;
    final double minX = worldBounds.left + halfWidth;
    final double maxX = worldBounds.right - halfWidth;
    final double minY = worldBounds.top + halfHeight;
    final double maxY = worldBounds.bottom - halfHeight;
    return Vector2(
      point.x.clamp(math.min(minX, maxX), math.max(minX, maxX)),
      point.y.clamp(math.min(minY, maxY), math.max(minY, maxY)),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) {
      return;
    }

    final FollowTarget? currentTarget = target;
    if (currentTarget == null) {
      state = AnimalState.idle;
      velocity.setZero();
      return;
    }

    final Vector2 destination = currentTarget.worldPosition;
    final Vector2 toTarget = destination - position;
    final double distance = toTarget.length;

    if (distance <= attributes.arrivalThreshold) {
      position.setFrom(clampToInnerBounds(destination));
      clearTarget();
      return;
    }

    final Vector2 desiredVelocity = toTarget.normalized() * attributes.speed;
    final double steerT = (attributes.steerRate * dt).clamp(0.0, 1.0);
    velocity.setFrom(velocity + (desiredVelocity - velocity) * steerT);

    if (velocity.length2 > 0) {
      final double desiredAngle = math.atan2(velocity.y, velocity.x);
      angle = lerpAngle(angle, desiredAngle, attributes.turnRate * dt);
    }

    position += velocity * dt;
    _constrainToWorldBounds();

    if (_isBlockedFromTarget(destination)) {
      clearTarget();
    }
  }

  void _constrainToWorldBounds() {
    final Vector2 clamped = clampToInnerBounds(position);
    if (clamped.x != position.x && velocity.x != 0) {
      velocity.x = 0;
    }
    if (clamped.y != position.y && velocity.y != 0) {
      velocity.y = 0;
    }
    position.setFrom(clamped);
  }

  bool _isBlockedFromTarget(Vector2 destination) {
    final Vector2 clampedDestination = clampToInnerBounds(destination);
    if ((clampedDestination - destination).length2 < 0.01) {
      return false;
    }
    return (position - clampedDestination).length <= 0.5;
  }
}
