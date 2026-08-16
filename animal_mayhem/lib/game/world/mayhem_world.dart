import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/animal_component.dart';
import '../components/animals/cat_component.dart';
import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../components/animals/frog_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/environment/narrow_passage.dart';
import '../components/environment/water_region.dart';
import '../components/objects/gate.dart';
import '../components/objects/goal_zone.dart';
import '../components/objects/lever_component.dart';
import '../components/objects/lily_pad_component.dart';
import '../components/objects/obstacle_component.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/terrain_map.dart';
import '../systems/interaction/resettable.dart';
import '../systems/objective/animal_at_location_objective.dart';
import '../systems/objective/composite_objective.dart';
import '../systems/objective/game_objective.dart';
import '../systems/objective/gate_open_objective.dart';

/// Stage 5 development puzzle.
///
/// The Cat uses a narrow passage to reach a lever that opens a gate. The Duck
/// must swim north of the water and walk through the opened gate to the goal.
/// The Dog cannot cross water. Passage fit uses physical profiles, not species.
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
        position: Vector2(0, 320),
        size: Vector2(180, 80),
      ),
      gate = Gate(position: Vector2(180, 320), size: Vector2(300, 80)),
      midWall = NormalBarrier(
        position: Vector2(480, 320),
        size: Vector2(440, 80),
      ),
      passage = NarrowPassage(
        position: Vector2(920, 320),
        size: Vector2(MayhemWorld.passageClearance, 80),
        requiredClearance: MayhemWorld.passageClearance,
      ),
      eastWall = NormalBarrier(
        position: Vector2(920 + MayhemWorld.passageClearance, 320),
        size: Vector2(1400 - (920 + MayhemWorld.passageClearance), 80),
      ),
      jumpableBarrier = JumpableBarrier(
        position: Vector2(1180, 1480),
        size: Vector2(160, 90),
      ),
      normalBarrier = NormalBarrier(
        position: Vector2(40, 1680),
        size: Vector2(140, 70),
      ),
      lilyPad = LilyPadComponent(position: MayhemWorld.lilyPadPosition),
      goal = GoalZone(bounds: MayhemWorld.goalBounds),
      lever = LeverComponent(position: MayhemWorld.leverPosition) {
    final List<ObstacleComponent> blockers = <ObstacleComponent>[
      westWall,
      gate,
      midWall,
      eastWall,
      jumpableBarrier,
      normalBarrier,
    ];
    final List<NarrowPassage> corridors = <NarrowPassage>[passage];
    for (final AnimalComponent animal in <AnimalComponent>[
      dog,
      duck,
      frog,
      cat,
    ]) {
      animal.terrain = terrain;
      animal.obstacles = blockers;
      animal.passages = corridors;
    }
    lever.onActivated = gate.open;
    controller = GameController(
      animals: <AnimalComponent>[dog, duck, frog, cat],
      spawns: <AnimalComponent, Vector2>{
        dog: MayhemWorld.dogSpawn,
        duck: MayhemWorld.duckSpawn,
        frog: MayhemWorld.frogSpawn,
        cat: MayhemWorld.catSpawn,
      },
      objective: CompositeObjective(
        description: 'Open the gate, Duck to the Goal',
        children: <GameObjective>[
          GateOpenObjective(gate: gate),
          AnimalAtLocationObjective(animal: duck, zone: MayhemWorld.goalBounds),
        ],
      ),
      resettables: <Resettable>[lever, gate],
    )..bindInput();
    lilyPad.onTapped = controller.handleWorldTap;
    lever.onTapped = controller.handleInteractableTap;
  }

  static final Vector2 size = Vector2(1400, 2200);

  static const double passageClearance = 42;

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => Rect.fromLTWH(0, 1000, size.x, 280);

  static Rect get goalBounds => const Rect.fromLTWH(180, 60, 300, 160);

  static Vector2 get catSpawn => Vector2(700, 880);

  static Vector2 get frogSpawn => Vector2(700, 1700);

  static Vector2 get duckSpawn => Vector2(420, 1550);

  static Vector2 get dogSpawn => Vector2(980, 1880);

  static Vector2 get lilyPadPosition => Vector2(size.x / 2, 1140);

  static Vector2 get leverPosition => Vector2(941, 180);

  static Vector2 get spawnPoint => dogSpawn;

  final TerrainMap terrain;
  final DogComponent dog;
  final DuckComponent duck;
  final FrogComponent frog;
  final CatComponent cat;
  final NormalBarrier westWall;
  final Gate gate;
  final NormalBarrier midWall;
  final NarrowPassage passage;
  final NormalBarrier eastWall;
  final JumpableBarrier jumpableBarrier;
  final NormalBarrier normalBarrier;
  final LilyPadComponent lilyPad;
  final GoalZone goal;
  final LeverComponent lever;
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
    await add(gate);
    await add(midWall);
    await add(passage);
    await add(eastWall);
    await add(jumpableBarrier);
    await add(normalBarrier);
    await add(lilyPad);
    await add(lever);
    await add(dog);
    await add(duck);
    await add(frog);
    await add(cat);
  }

  @override
  void update(double dt) {
    super.update(dt);
    controller.tick(dt);
    _syncTargetMarker();
  }

  void reset() {
    controller.reset();
    _clearMarker();
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
