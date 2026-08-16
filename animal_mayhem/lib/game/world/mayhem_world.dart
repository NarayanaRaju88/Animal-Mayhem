import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/animal_component.dart';
import '../components/animals/cat_component.dart';
import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../components/animals/frog_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/environment/route_label_component.dart';
import '../components/environment/water_region.dart';
import '../components/objects/gate.dart';
import '../components/objects/goal_zone.dart';
import '../components/objects/lily_pad_component.dart';
import '../components/objects/obstacle_component.dart';
import '../components/objects/route_switch_component.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/environment_link.dart';
import '../systems/environment/route_progress_tracker.dart';
import '../systems/environment/route_state.dart';
import '../systems/environment/terrain_map.dart';
import '../systems/interaction/resettable.dart';
import '../systems/objective/alternative_objective.dart';
import '../systems/objective/game_objective.dart';
import '../systems/objective/predicate_objective.dart';

/// Stage 7 development puzzle.
///
/// Cat toggles a reversible route switch. Route A is a water path for the Duck.
/// Route B is a jumpable-barrier path for the Frog. Either solution completes
/// the objective.
class MayhemWorld extends World {
  MayhemWorld()
    : terrain = TerrainMap(
        worldBounds: MayhemWorld.bounds,
        waterBounds: MayhemWorld.waterBounds,
      ),
      dog = DogComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.dogSpawn,
      ),
      duck = DuckComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.duckSpawn,
      ),
      frog = FrogComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.frogSpawn,
      ),
      cat = CatComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.catSpawn,
      ),
      westWall = NormalBarrier(
        position: Vector2(0, 240),
        size: Vector2(180, 64),
      ),
      gateA = Gate(
        position: Vector2(180, 240),
        size: Vector2(320, 64),
        followEnvironment: true,
      ),
      midWall = NormalBarrier(
        position: Vector2(500, 240),
        size: Vector2(400, 560),
      ),
      gateB = Gate(
        position: Vector2(900, 240),
        size: Vector2(320, 64),
        followEnvironment: true,
      ),
      eastWall = NormalBarrier(
        position: Vector2(1220, 240),
        size: Vector2(180, 64),
      ),
      jumpableBarrier = JumpableBarrier(
        position: Vector2(900, 480),
        size: Vector2(500, 56),
      ),
      lilyPad = LilyPadComponent(position: MayhemWorld.lilyPadPosition),
      goal = GoalZone(bounds: MayhemWorld.goalBounds),
      routeSwitch = RouteSwitchComponent(position: MayhemWorld.switchPosition) {
    final List<ObstacleComponent> blockers = <ObstacleComponent>[
      westWall,
      gateA,
      midWall,
      gateB,
      eastWall,
      jumpableBarrier,
    ];
    final List<AnimalComponent> roster = <AnimalComponent>[
      dog,
      duck,
      frog,
      cat,
    ];
    for (final AnimalComponent animal in roster) {
      animal.terrain = terrain;
      animal.obstacles = blockers;
    }
    duckProgress = RouteProgressTracker(animal: duck, terrain: terrain);
    frogProgress = RouteProgressTracker(animal: frog, terrain: terrain);
    routeALink = EnvironmentLink(trigger: routeSwitch, responder: gateA);
    routeBLink = EnvironmentLink(
      trigger: InvertedTrigger(routeSwitch),
      responder: gateB,
    );
    routeALink.sync(force: true);
    routeBLink.sync(force: true);
    controller = GameController(
      animals: roster,
      spawns: <AnimalComponent, Vector2>{
        dog: MayhemWorld.dogSpawn,
        duck: MayhemWorld.duckSpawn,
        frog: MayhemWorld.frogSpawn,
        cat: MayhemWorld.catSpawn,
      },
      objective: AlternativeObjective(
        description: 'Reach the goal via Route A or Route B',
        options: <GameObjective>[
          PredicateObjective(
            description: 'Route A',
            isSatisfied: () =>
                routeSwitch.route == RouteId.a &&
                duckProgress.visitedWater &&
                MayhemWorld.goalBounds.contains(
                  Offset(duck.position.x, duck.position.y),
                ),
          ),
          PredicateObjective(
            description: 'Route B',
            isSatisfied: () =>
                routeSwitch.route == RouteId.b &&
                frogProgress.usedJump &&
                MayhemWorld.goalBounds.contains(
                  Offset(frog.position.x, frog.position.y),
                ),
          ),
        ],
      ),
      resettables: <Resettable>[
        routeSwitch,
        gateA,
        gateB,
        duckProgress,
        frogProgress,
      ],
      environmentStatus: () =>
          'Route A: ${routeSwitch.route == RouteId.a ? 'ACTIVE' : 'INACTIVE'}  '
          'Route B: ${routeSwitch.route == RouteId.b ? 'ACTIVE' : 'INACTIVE'}',
    )..bindInput();
    lilyPad.onTapped = controller.handleWorldTap;
    routeSwitch.onTapped = controller.handleInteractableTap;
  }

  static final Vector2 size = Vector2(1400, 2200);

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => const Rect.fromLTWH(0, 420, 500, 280);

  static Rect get goalBounds => const Rect.fromLTWH(500, 40, 400, 160);

  static Vector2 get switchPosition => Vector2(700, 960);

  static Vector2 get catSpawn => Vector2(700, 1180);

  static Vector2 get frogSpawn => Vector2(1060, 820);

  static Vector2 get duckSpawn => Vector2(250, 820);

  static Vector2 get dogSpawn => Vector2(700, 1700);

  static Vector2 get lilyPadPosition => Vector2(250, 560);

  static Vector2 get spawnPoint => dogSpawn;

  final TerrainMap terrain;
  final DogComponent dog;
  final DuckComponent duck;
  final FrogComponent frog;
  final CatComponent cat;
  final NormalBarrier westWall;
  final Gate gateA;
  final NormalBarrier midWall;
  final Gate gateB;
  final NormalBarrier eastWall;
  final JumpableBarrier jumpableBarrier;
  final LilyPadComponent lilyPad;
  final GoalZone goal;
  final RouteSwitchComponent routeSwitch;
  late final RouteProgressTracker duckProgress;
  late final RouteProgressTracker frogProgress;
  late final EnvironmentLink routeALink;
  late final EnvironmentLink routeBLink;
  late final GameController controller;

  TargetMarker? _targetMarker;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      DevelopmentPlayArea(
        worldSize: size,
        onWorldTap: controller.handleWorldTap,
      ),
    );
    await add(WaterRegion(bounds: waterBounds));
    await add(goal);
    await add(westWall);
    await add(gateA);
    await add(midWall);
    await add(gateB);
    await add(eastWall);
    await add(jumpableBarrier);
    await add(lilyPad);
    await add(
      RouteLabelComponent(
        position: Vector2(180, 360),
        text: 'ROUTE A',
        color: const Color(0xFF2F6F8A),
      ),
    );
    await add(
      RouteLabelComponent(
        position: Vector2(980, 360),
        text: 'ROUTE B',
        color: const Color(0xFF8A6A3B),
      ),
    );
    await add(routeSwitch);
    await add(dog);
    await add(duck);
    await add(frog);
    await add(cat);
  }

  @override
  void update(double dt) {
    super.update(dt);
    duckProgress.sample();
    frogProgress.sample();
    _syncRoutes();
    controller.tick(dt);
    _syncRoutes();
    _syncTargetMarker();
  }

  void reset() {
    controller.reset();
    _syncRoutes(force: true);
    _clearMarker();
  }

  void _syncRoutes({bool force = false}) {
    routeALink.sync(force: force);
    routeBLink.sync(force: force);
  }

  void _syncTargetMarker() {
    final FollowTarget? target = controller.selectedTarget;
    if (target is WorldPositionTarget) {
      final Vector2 point = target.worldPosition;
      if (_targetMarker == null) {
        _targetMarker = TargetMarker(position: point);
        add(_targetMarker!);
      } else {
        _targetMarker!.position.setFrom(point);
      }
    } else {
      _clearMarker();
    }
  }

  void _clearMarker() {
    _targetMarker?.removeFromParent();
    _targetMarker = null;
  }
}
