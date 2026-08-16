import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/utils/angles.dart';
import '../../systems/abilities/ability_kind.dart';
import '../../systems/abilities/animal_abilities.dart';
import '../../systems/abilities/jump_ability.dart';
import '../../systems/abilities/jump_motion.dart';
import '../../systems/behavior/follow_target.dart';
import '../../systems/command/command_kind.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import '../../systems/environment/terrain_kind.dart';
import '../../systems/environment/terrain_map.dart';
import '../../systems/interaction/interactable.dart';
import '../environment/narrow_passage.dart';
import '../objects/bridge_component.dart';
import '../objects/obstacle_component.dart';
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
    this.abilities = AnimalAbilities.walk,
    this.jumpAbility,
    PhysicalProfile? profile,
    this.terrain,
    this.onTapped,
    Vector2? position,
  }) : profile =
           profile ??
           PhysicalProfile.fromSize(
             width: attributes.size.x,
             height: attributes.size.y,
           ),
       super(
         position: position?.clone() ?? Vector2.zero(),
         size: attributes.size.clone(),
         anchor: Anchor.center,
         priority: 5,
       );

  final AnimalAttributes attributes;
  final PhysicalProfile profile;
  final String speciesName;
  final MovementCapabilities capabilities;
  final AnimalAbilities abilities;
  final JumpAbility? jumpAbility;
  TerrainMap? terrain;
  List<ObstacleComponent> obstacles = <ObstacleComponent>[];
  List<NarrowPassage> passages = <NarrowPassage>[];
  List<BridgeComponent> bridges = <BridgeComponent>[];
  void Function(AnimalComponent animal)? onTapped;
  Rect worldBounds;

  AnimalState state = AnimalState.idle;
  FollowTarget? target;

  final Vector2 velocity = Vector2.zero();

  bool _followMode = false;
  double _stopDistance = 0;
  JumpMotion? _jump;
  double _landingTimer = 0;
  late final SelectionRing _selectionRing = SelectionRing(ownerSize: size);

  bool get isSelected => _selectionRing.isActive;

  set isSelected(bool value) {
    _selectionRing.isActive = value;
  }

  bool get isJumping => _jump != null;

  bool get hasJumpAbility =>
      abilities.has(AbilityKind.jump) && jumpAbility != null;

  List<CommandKind> get availableCommands => abilities.availableCommands;

  bool canAttemptInteraction(Interactable object) {
    if (!abilities.has(AbilityKind.interact)) {
      return false;
    }
    if (!object.canInteract) {
      return false;
    }
    return object.worldPosition.distanceTo(position) <= object.interactionRange;
  }

  /// Uses [object] when the animal has the interact ability and is in range.
  bool interactWith(Interactable object) {
    if (!canAttemptInteraction(object)) {
      return false;
    }
    object.interact();
    return true;
  }

  /// Moves toward a fixed world point. Clamped to the playable inner bounds.
  void moveTo(Vector2 worldPosition) {
    if (isJumping) {
      return;
    }
    _followMode = false;
    _stopDistance = attributes.arrivalThreshold;
    final Vector2 clamped = clampToInnerBounds(worldPosition);
    target = WorldPositionTarget(clamped);
    state = AnimalState.moving;
  }

  /// Follows any [FollowTarget], including a later moving animal or object.
  void follow(FollowTarget newTarget, {double? stopDistance}) {
    if (isJumping) {
      return;
    }
    _followMode = true;
    _stopDistance = stopDistance ?? attributes.followDistance;
    target = newTarget;
    state = AnimalState.following;
  }

  /// Starts a commanded jump. Returns false if the animal cannot jump now.
  bool startJump(Vector2 worldPosition) {
    final JumpAbility? ability = jumpAbility;
    if (!hasJumpAbility || ability == null) {
      return false;
    }
    if (isJumping || state == AnimalState.landing) {
      return false;
    }

    Vector2 destination = clampToInnerBounds(worldPosition);
    final Vector2 offset = destination - position;
    final double distance = offset.length;
    if (distance < 4) {
      return false;
    }
    if (distance > ability.maxDistance) {
      destination = position + offset.normalized() * ability.maxDistance;
      destination = clampToInnerBounds(destination);
    }
    if (!_canLandAt(destination) || !_jumpPathIsClear(destination)) {
      return false;
    }

    target = null;
    _followMode = false;
    velocity.setZero();
    _jump = JumpMotion(
      start: position,
      end: destination,
      height: ability.height,
      duration: ability.duration,
    );
    state = AnimalState.jumping;
    return true;
  }

  void clearTarget() {
    _cancelJump();
    target = null;
    _followMode = false;
    _landingTimer = 0;
    state = AnimalState.idle;
    velocity.setZero();
  }

  void resetTo(Vector2 spawn) {
    _cancelJump();
    _landingTimer = 0;
    position.setFrom(clampToInnerBounds(spawn));
    angle = 0;
    isSelected = false;
    target = null;
    _followMode = false;
    state = AnimalState.idle;
    velocity.setZero();
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
    if (map != null &&
        !capabilities.canTraverse(map.kindAt(point)) &&
        !_enabledBridgeAt(point)) {
      return false;
    }
    if (!_fitsPassages(point)) {
      return false;
    }
    if (isJumping) {
      return true;
    }
    return !_blockedByObstacle(point, allowJumpable: false);
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

    if (_jump != null) {
      _updateJump(dt);
      return;
    }

    if (state == AnimalState.landing) {
      _landingTimer -= dt;
      if (_landingTimer <= 0) {
        state = AnimalState.idle;
      }
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

  void _updateJump(double dt) {
    final JumpMotion jump = _jump!;
    jump.advance(dt);
    position.setFrom(jump.position);
    final Vector2 delta = jump.end - jump.start;
    if (delta.length2 > 0) {
      angle = math.atan2(delta.y, delta.x);
    }
    if (jump.isComplete) {
      position.setFrom(jump.end);
      _jump = null;
      state = AnimalState.landing;
      _landingTimer = 0.12;
    }
  }

  void _cancelJump() {
    final JumpMotion? jump = _jump;
    if (jump != null) {
      position.setFrom(jump.groundPosition);
      _jump = null;
    }
  }

  bool _canLandAt(Vector2 point) {
    final TerrainMap? map = terrain;
    if (map != null &&
        !capabilities.canTraverse(map.kindAt(point)) &&
        !_enabledBridgeAt(point)) {
      return false;
    }
    if (!_fitsPassages(point)) {
      return false;
    }
    return !_blockedByObstacle(point, allowJumpable: false);
  }

  bool _jumpPathIsClear(Vector2 destination) {
    for (int i = 1; i <= 8; i++) {
      final double t = i / 9;
      final Vector2 sample = position + (destination - position) * t;
      if (_blockedByObstacle(sample, allowJumpable: true)) {
        return false;
      }
    }
    return true;
  }

  bool _enabledBridgeAt(Vector2 point) {
    for (final BridgeComponent bridge in bridges) {
      if (bridge.isEnabled && bridge.containsWorldPoint(point)) {
        return true;
      }
    }
    return false;
  }

  bool _fitsPassages(Vector2 point) {
    for (final NarrowPassage passage in passages) {
      if (passage.containsWorldPoint(point) && !passage.allows(profile)) {
        return false;
      }
    }
    return true;
  }

  bool _blockedByObstacle(Vector2 point, {required bool allowJumpable}) {
    for (final ObstacleComponent obstacle in obstacles) {
      if (!obstacle.containsWorldPoint(point)) {
        continue;
      }
      if (allowJumpable && obstacle.jumpable) {
        continue;
      }
      return true;
    }
    return false;
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
