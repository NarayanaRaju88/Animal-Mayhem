import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/utils/angles.dart';
import '../../systems/behavior/follow_target.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/terrain_kind.dart';
import '../../systems/environment/terrain_map.dart';
import 'animal_attributes.dart';
import 'animal_state.dart';
import 'selection_ring.dart';

/// Reusable animal body: position, movement, facing, target, and bounds.
///
/// Species such as [DogComponent] supply attributes and a visual child. Keep
/// Flutter widgets out of this type.
class AnimalComponent extends PositionComponent with TapCallbacks {
  AnimalComponent({
    required this.attributes,
    required this.worldBounds,
    this.speciesName = 'Animal',
    this.capabilities = MovementCapabilities.landOnly,
    this.terrain,
    this.onTapped,
    Vector2? position,
  }) : super(
         position: position?.clone() ?? Vector2.zero(),
         size: attributes.size.clone(),
         anchor: Anchor.center,
         priority: 5,
       );

  final AnimalAttributes attributes;
  final String speciesName;
  final MovementCapabilities capabilities;
  TerrainMap? terrain;
  void Function(AnimalComponent animal)? onTapped;
  Rect worldBounds;

  AnimalState state = AnimalState.idle;
  FollowTarget? target;

  final Vector2 velocity = Vector2.zero();

  bool _followMode = false;
  double _stopDistance = 0;
  late final SelectionRing _selectionRing = SelectionRing(ownerSize: size);

  bool get isSelected => _selectionRing.isActive;

  set isSelected(bool value) {
    _selectionRing.isActive = value;
  }

  /// Moves toward a fixed world point. Clamped to the playable inner bounds.
  void moveTo(Vector2 worldPosition) {
    _followMode = false;
    _stopDistance = attributes.arrivalThreshold;
    final Vector2 clamped = clampToInnerBounds(worldPosition);
    target = WorldPositionTarget(clamped);
    state = AnimalState.moving;
  }

  /// Follows any [FollowTarget], including a later moving animal or object.
  void follow(FollowTarget newTarget, {double? stopDistance}) {
    _followMode = true;
    _stopDistance = stopDistance ?? attributes.followDistance;
    target = newTarget;
    state = AnimalState.following;
  }

  void clearTarget() {
    target = null;
    _followMode = false;
    state = AnimalState.idle;
    velocity.setZero();
  }

  void resetTo(Vector2 spawn) {
    position.setFrom(clampToInnerBounds(spawn));
    angle = 0;
    isSelected = false;
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

  bool canOccupy(Vector2 point) {
    final TerrainMap? map = terrain;
    if (map == null) {
      return true;
    }
    return capabilities.canTraverse(map.kindAt(point));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(_selectionRing);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
    event.handled = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) {
      return;
    }

    final FollowTarget? currentTarget = target;
    if (currentTarget == null) {
      velocity.setZero();
      _refreshState();
      return;
    }

    final Vector2 destination = currentTarget.worldPosition;
    final Vector2 toTarget = destination - position;
    final double distance = toTarget.length;

    if (_followMode) {
      if (distance <= _stopDistance) {
        velocity.setZero();
        _refreshState();
        return;
      }
    } else if (distance <= attributes.arrivalThreshold) {
      final Vector2 arrived = clampToInnerBounds(destination);
      if (canOccupy(arrived)) {
        position.setFrom(arrived);
      }
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

    final Vector2 previous = position.clone();
    position += velocity * dt;
    _constrainToWorldBounds();
    if (!canOccupy(position)) {
      position.setFrom(previous);
      velocity.setZero();
      if (!_followMode) {
        final Vector2 peek =
            previous + toTarget.normalized() * math.min(4, distance);
        if (!canOccupy(clampToInnerBounds(peek))) {
          clearTarget();
          return;
        }
      }
    }

    _refreshState();
  }

  void _refreshState() {
    if (target == null) {
      state = AnimalState.idle;
      return;
    }
    if (terrain?.kindAt(position) == TerrainKind.water) {
      state = AnimalState.swimming;
      return;
    }
    state = _followMode ? AnimalState.following : AnimalState.moving;
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
}
