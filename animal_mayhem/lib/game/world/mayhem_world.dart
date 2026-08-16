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
import '../components/objects/bridge_component.dart';
import '../components/objects/gate.dart';
import '../components/objects/goal_zone.dart';
import '../components/objects/lever_component.dart';
import '../components/objects/lily_pad_component.dart';
import '../components/objects/obstacle_component.dart';
import '../components/objects/pressure_pad_component.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/environment_link.dart';
import '../systems/environment/occupancy_requirement.dart';
import '../systems/environment/terrain_map.dart';
import '../systems/interaction/resettable.dart';
import '../systems/objective/animal_at_location_objective.dart';
import '../systems/objective/bridge_enabled_objective.dart';
import '../systems/objective/composite_objective.dart';
import '../systems/objective/game_objective.dart';
import '../systems/objective/gate_open_objective.dart';
import '../systems/objective/pressure_pad_active_objective.dart';

/// Stage 6 development puzzle.
///
/// Cat uses the narrow passage and lever to open the gate. Duck swims north
/// and stands on the pressure pad, which enables a bridge over the water. Dog
/// crosses the bridge and walks through the open gate to the goal.
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
        position: Vector2(40, 1480),
        size: Vector2(160, 90),
      ),
      normalBarrier = NormalBarrier(
        position: Vector2(40, 1680),
        size: Vector2(140, 70),
      ),
      lilyPad = LilyPadComponent(position: MayhemWorld.lilyPadPosition),
      goal = GoalZone(bounds: MayhemWorld.goalBounds),
      lever = LeverComponent(position: MayhemWorld.leverPosition),
      pad = PressurePadComponent(
        position: MayhemWorld.padPosition,
        size: MayhemWorld.padSize,
        requirement: const SpeciesRequirement('Duck'),
      ),
      bridge = BridgeComponent(
        position: MayhemWorld.bridgePosition,
        size: MayhemWorld.bridgeSize,
      ) {
    final List<ObstacleComponent> blockers = <ObstacleComponent>[
      westWall,
      gate,
      midWall,
      eastWall,
      jumpableBarrier,
      normalBarrier,
    ];
    final List<NarrowPassage> corridors = <NarrowPassage>[passage];
    final List<BridgeComponent> crossings = <BridgeComponent>[bridge];
    final List<AnimalComponent> roster = <AnimalComponent>[
      dog,
      duck,
      frog,
      cat,
    ];
    for (final AnimalComponent animal in roster) {
      animal.terrain = terrain;
      animal.obstacles = blockers;
      animal.passages = corridors;
      animal.bridges = crossings;
    }
    pad.animals = roster;
    lever.onActivated = gate.open;
    padBridgeLink = EnvironmentLink(trigger: pad, responder: bridge);
    controller = GameController(
      animals: roster,
      spawns: <AnimalComponent, Vector2>{
        dog: MayhemWorld.dogSpawn,
        duck: MayhemWorld.duckSpawn,
        frog: MayhemWorld.frogSpawn,
        cat: MayhemWorld.catSpawn,
      },
      objective: CompositeObjective(
        description: 'Open the gate, Duck on pad, Dog across the bridge',
        children: <GameObjective>[
          GateOpenObjective(gate: gate),
          PressurePadActiveObjective(pad: pad),
          BridgeEnabledObjective(bridge: bridge),
          AnimalAtLocationObjective(animal: dog, zone: MayhemWorld.goalBounds),
        ],
      ),
      resettables: <Resettable>[lever, gate, pad, bridge],
      environmentStatus: () =>
          'Gate: ${gate.isOpen ? 'OPEN' : 'CLOSED'}  '
          'Pad: ${pad.isActive ? 'ACTIVE' : 'INACTIVE'}  '
          'Bridge: ${bridge.isEnabled ? 'ON' : 'OFF'}',
    )..bindInput();
    lilyPad.onTapped = controller.handleWorldTap;
    lever.onTapped = controller.handleInteractableTap;
  }

  static final Vector2 size = Vector2(1400, 2200);

  static const double passageClearance = 42;

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => Rect.fromLTWH(0, 1000, size.x, 280);

  static Rect get goalBounds => const Rect.fromLTWH(180, 60, 300, 160);

  static Vector2 get padPosition => Vector2(280, 680);

  static Vector2 get padSize => Vector2(100, 100);

  static Vector2 get bridgePosition => Vector2(1040, 1000);

  static Vector2 get bridgeSize => Vector2(140, 280);

  static Vector2 get catSpawn => Vector2(700, 880);

  static Vector2 get frogSpawn => Vector2(700, 1700);

  static Vector2 get duckSpawn => Vector2(420, 1550);

  static Vector2 get dogSpawn => Vector2(1110, 1880);

  static Vector2 get lilyPadPosition => Vector2(420, 1140);

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
  final PressurePadComponent pad;
  final BridgeComponent bridge;
  late final EnvironmentLink padBridgeLink;
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
    await add(bridge);
    await add(goal);
    await add(westWall);
    await add(gate);
    await add(midWall);
    await add(passage);
    await add(eastWall);
    await add(jumpableBarrier);
    await add(normalBarrier);
    await add(lilyPad);
    await add(pad);
    await add(lever);
    await add(dog);
    await add(duck);
    await add(frog);
    await add(cat);
  }

  @override
  void update(double dt) {
    super.update(dt);
    padBridgeLink.sync();
    controller.tick(dt);
    _syncTargetMarker();
  }

  void reset() {
    controller.reset();
    pad.refresh();
    padBridgeLink.sync(force: true);
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
