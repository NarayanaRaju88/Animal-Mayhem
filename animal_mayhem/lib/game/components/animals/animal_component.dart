import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/utils/angles.dart';
import '../../systems/abilities/ability_kind.dart';
import '../../systems/abilities/animal_abilities.dart';
import '../../systems/abilities/climb_capability.dart';
import '../../systems/abilities/climb_motion.dart';
import '../../systems/abilities/coil_capability.dart';
import '../../systems/abilities/jump_ability.dart';
import '../../systems/abilities/jump_motion.dart';
import '../../systems/behavior/follow_target.dart';
import '../../systems/command/command_kind.dart';
import '../../systems/environment/force_capability.dart';
import '../../systems/environment/height_level.dart';
import '../../systems/environment/movement_capabilities.dart';
import '../../systems/environment/physical_profile.dart';
import '../../systems/environment/terrain_kind.dart';
import '../../systems/environment/terrain_map.dart';
import '../../systems/interaction/interactable.dart';
import '../environment/climbable_surface_component.dart';
import '../environment/narrow_passage.dart';
import '../objects/bridge_component.dart';
import '../objects/coil_anchor_component.dart';
import '../objects/gate.dart';
import '../objects/obstacle_component.dart';
import '../objects/pushable_component.dart';
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
    this.force = ForceCapability.medium,
    this.jumpAbility,
    this.climbAbility,
    this.coilAbility,
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
  final ForceCapability force;
  final JumpAbility? jumpAbility;
  final ClimbCapability? climbAbility;
  final CoilCapability? coilAbility;
  TerrainMap? terrain;
  List<ObstacleComponent> obstacles = <ObstacleComponent>[];
  List<NarrowPassage> passages = <NarrowPassage>[];
  List<BridgeComponent> bridges = <BridgeComponent>[];
  List<PushableComponent> pushables = <PushableComponent>[];
  void Function(AnimalComponent animal)? onTapped;
  Rect worldBounds;

  AnimalState state = AnimalState.idle;
  FollowTarget? target;

  final Vector2 velocity = Vector2.zero();

  bool _followMode = false;
  double _stopDistance = 0;
  JumpMotion? _jump;
  ClimbMotion? _climb;
  bool hasCompletedClimb = false;
  bool hasCompletedCoil = false;
  double _landingTimer = 0;
  late final SelectionRing _selectionRing = SelectionRing(ownerSize: size);

  bool get isSelected => _selectionRing.isActive;

  set isSelected(bool value) {
    _selectionRing.isActive = value;
  }

  bool get isJumping => _jump != null;

  bool get isClimbing => _climb != null;

  bool get hasJumpAbility =>
      abilities.has(AbilityKind.jump) && jumpAbility != null;

  bool get hasClimbAbility =>
      abilities.has(AbilityKind.climb) && climbAbility != null;

  bool get hasCoilAbility =>
      abilities.has(AbilityKind.coil) && coilAbility != null;

  HeightLevel get heightLevel => HeightLevel.fromY(position.y);

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
    if (isJumping || isClimbing) {
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
    if (isJumping || isClimbing) {
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
    if (isJumping || isClimbing || state == AnimalState.landing) {
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

  bool canAttemptClimb(ClimbableSurfaceComponent surface) {
    if (!hasClimbAbility || isClimbing || isJumping) {
      return false;
    }
    if (!surface.canBeUsedBy(this)) {
      return false;
    }
    if (!_isWithinClimbRange(surface)) {
      return false;
    }
    return _climbRouteIsClear(surface);
  }

  /// Starts a commanded climb. Returns false if the animal cannot climb now.
  bool startClimb(ClimbableSurfaceComponent surface) {
    final ClimbCapability? ability = climbAbility;
    if (ability == null || !canAttemptClimb(surface)) {
      return false;
    }
    target = null;
    _followMode = false;
    velocity.setZero();
    _climb = ClimbMotion(
      start: position.clone(),
      end: surface.climbDestination.clone(),
      duration: ability.duration,
    );
    state = AnimalState.climbing;
    return true;
  }

  bool canAttemptCoil(CoilAnchorComponent anchor) {
    if (!hasCoilAbility || isClimbing || isJumping) {
      return false;
    }
    if (!anchor.canBeUsedBy(this)) {
      return false;
    }
    if (!_isWithinCoilRange(anchor)) {
      return false;
    }
    return _coilRouteIsClear(anchor);
  }

  /// Holds [anchor] when the animal can coil. Returns false otherwise.
  bool startCoil(CoilAnchorComponent anchor) {
    if (!canAttemptCoil(anchor)) {
      return false;
    }
    if (!anchor.hold(this)) {
      return false;
    }
    target = null;
    _followMode = false;
    velocity.setZero();
    hasCompletedCoil = true;
    state = AnimalState.idle;
    return true;
  }

  void clearTarget() {
    _cancelJump();
    _cancelClimb();
    target = null;
    _followMode = false;
    _landingTimer = 0;
    state = AnimalState.idle;
    velocity.setZero();
  }

  void resetTo(Vector2 spawn) {
    _cancelJump();
    _cancelClimb();
    _landingTimer = 0;
    hasCompletedClimb = false;
    hasCompletedCoil = false;
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

  bool canOccupy(Vector2 point, {bool ignorePushables = false}) {
    final TerrainMap? map = terrain;
    if (map != null &&
        !capabilities.canTraverse(map.kindAt(point)) &&
        !_enabledBridgeAt(point)) {
      return false;
    }
    if (!_fitsPassages(point)) {
      return false;
    }
    if (isJumping || isClimbing) {
      return true;
    }
    return !_blockedByObstacle(
      point,
      allowJumpable: false,
      ignorePushables: ignorePushables,
    );
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

    if (_climb != null) {
      _updateClimb(dt);
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
      final PushableComponent? crate = _pushableAt(position);
      final Vector2 delta = position - previous;
      final bool pushed =
          crate != null && force.canPushHeavy && crate.tryPush(delta);
      if (pushed && canOccupy(position, ignorePushables: true)) {
        // Heavy animal slid the crate and kept moving.
      } else {
        if (pushed) {
          crate.undoLastPush();
        }
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

  void _updateClimb(double dt) {
    final ClimbMotion climb = _climb!;
    climb.advance(dt);
    position.setFrom(climb.position);
    final Vector2 delta = climb.end - climb.start;
    if (delta.length2 > 0) {
      angle = math.atan2(delta.y, delta.x);
    }
    if (climb.isComplete) {
      position.setFrom(climb.end);
      _climb = null;
      hasCompletedClimb = true;
      state = AnimalState.idle;
    }
  }

  void _cancelJump() {
    final JumpMotion? jump = _jump;
    if (jump != null) {
      position.setFrom(jump.groundPosition);
      _jump = null;
    }
  }

  void _cancelClimb() {
    _climb = null;
  }

  bool _isWithinClimbRange(ClimbableSurfaceComponent surface) {
    final ClimbCapability? ability = climbAbility;
    if (ability == null) {
      return false;
    }
    final double range = math.min(ability.range, surface.climbRange);
    final double minX = surface.position.x;
    final double maxX = surface.position.x + surface.size.x;
    final double minY = surface.position.y;
    final double maxY = surface.position.y + surface.size.y;
    final Vector2 closest = Vector2(
      position.x.clamp(minX, maxX),
      position.y.clamp(minY, maxY),
    );
    return position.distanceTo(closest) <= range;
  }

  bool _climbRouteIsClear(ClimbableSurfaceComponent surface) {
    if (!surface.isEnabled) {
      return false;
    }
    final Vector2 end = surface.climbDestination;
    for (int i = 1; i <= 8; i++) {
      final double t = i / 9;
      final Vector2 sample = position + (end - position) * t;
      for (final ObstacleComponent obstacle in obstacles) {
        if (obstacle is Gate && obstacle.containsWorldPoint(sample)) {
          return false;
        }
      }
    }
    return true;
  }

  bool _isWithinCoilRange(CoilAnchorComponent anchor) {
    final CoilCapability? ability = coilAbility;
    if (ability == null) {
      return false;
    }
    final double range = math.min(ability.range, anchor.coilRange);
    return position.distanceTo(anchor.worldPosition) <= range;
  }

  bool _coilRouteIsClear(CoilAnchorComponent anchor) {
    if (!anchor.isEnabled) {
      return false;
    }
    final Vector2 end = anchor.worldPosition;
    for (int i = 1; i <= 8; i++) {
      final double t = i / 9;
      final Vector2 sample = position + (end - position) * t;
      for (final ObstacleComponent obstacle in obstacles) {
        if (obstacle is Gate && obstacle.containsWorldPoint(sample)) {
          return false;
        }
      }
    }
    return true;
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

  bool _blockedByObstacle(
    Vector2 point, {
    required bool allowJumpable,
    bool ignorePushables = false,
  }) {
    for (final ObstacleComponent obstacle in obstacles) {
      if (ignorePushables && obstacle is PushableComponent) {
        continue;
      }
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

  PushableComponent? _pushableAt(Vector2 point) {
    for (final PushableComponent crate in pushables) {
      if (crate.containsWorldPoint(point)) {
        return crate;
      }
    }
    return null;
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
