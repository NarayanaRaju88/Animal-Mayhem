import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/animal_component.dart';
import '../components/animals/buffalo_component.dart';
import '../components/animals/cat_component.dart';
import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../components/animals/frog_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/environment/narrow_passage.dart';
import '../components/environment/water_region.dart';
import '../components/objects/gate.dart';
import '../components/objects/goal_zone.dart';
import '../components/objects/heavy_pressure_pad_component.dart';
import '../components/objects/lever_component.dart';
import '../components/objects/lily_pad_component.dart';
import '../components/objects/obstacle_component.dart';
import '../components/objects/pushable_component.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/environment_link.dart';
import '../systems/environment/terrain_map.dart';
import '../systems/interaction/resettable.dart';
import '../systems/objective/animal_at_location_objective.dart';
import '../systems/objective/composite_objective.dart';
import '../systems/objective/game_objective.dart';
import '../systems/objective/gate_open_objective.dart';
import '../systems/objective/predicate_objective.dart';
import '../systems/objective/pressure_pad_active_objective.dart';

/// Stage 8 development puzzle.
///
/// Cat uses the narrow alley and lever to open a wide gate. Buffalo (too large
/// for the alley) pushes a crate aside, then stands on a heavy pad to open the
/// heavy gate. Dog walks through to the goal while the pad stays active.
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
      buffalo = BuffaloComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.buffaloSpawn,
      ),
      westWall = NormalBarrier(
        position: Vector2(700, 240),
        size: Vector2(200, 70),
      ),
      heavyGate = Gate(
        position: Vector2(900, 240),
        size: Vector2(280, 70),
        followEnvironment: true,
      ),
      midWall = NormalBarrier(
        position: Vector2(1180, 240),
        size: Vector2(100, 70),
      ),
      passage = NarrowPassage(
        position: Vector2(1280, 240),
        size: Vector2(MayhemWorld.passageClearance, 1160),
        requiredClearance: MayhemWorld.passageClearance,
      ),
      eastWall = NormalBarrier(
        position: Vector2(1322, 240),
        size: Vector2(78, 70),
      ),
      lowerWestWall = NormalBarrier(
        position: Vector2(700, 720),
        size: Vector2(200, 70),
      ),
      wideGate = Gate(position: Vector2(900, 720), size: Vector2(280, 70)),
      lowerEastWall = NormalBarrier(
        position: Vector2(1180, 720),
        size: Vector2(100, 70),
      ),
      lowerFarWall = NormalBarrier(
        position: Vector2(1322, 720),
        size: Vector2(78, 70),
      ),
      crate = PushableComponent(
        position: MayhemWorld.crateSpawn,
        size: MayhemWorld.crateSize,
      ),
      heavyPad = HeavyPressurePadComponent(
        position: MayhemWorld.padPosition,
        size: MayhemWorld.padSize,
      ),
      lilyPad = LilyPadComponent(position: MayhemWorld.lilyPadPosition),
      goal = GoalZone(bounds: MayhemWorld.goalBounds),
      lever = LeverComponent(position: MayhemWorld.leverPosition) {
    crate.worldBounds = MayhemWorld.bounds;
    crate.terrain = terrain;
    final List<ObstacleComponent> blockers = <ObstacleComponent>[
      westWall,
      heavyGate,
      midWall,
      eastWall,
      lowerWestWall,
      wideGate,
      lowerEastWall,
      lowerFarWall,
      crate,
    ];
    crate.blockers = blockers;
    final List<NarrowPassage> corridors = <NarrowPassage>[passage];
    final List<PushableComponent> movables = <PushableComponent>[crate];
    final List<AnimalComponent> roster = <AnimalComponent>[
      dog,
      duck,
      frog,
      cat,
      buffalo,
    ];
    for (final AnimalComponent animal in roster) {
      animal.terrain = terrain;
      animal.obstacles = blockers;
      animal.passages = corridors;
      animal.pushables = movables;
    }
    heavyPad.animals = roster;
    lever.onActivated = wideGate.open;
    padGateLink = EnvironmentLink(trigger: heavyPad, responder: heavyGate);
    padGateLink.sync(force: true);
    controller = GameController(
      animals: roster,
      spawns: <AnimalComponent, Vector2>{
        dog: MayhemWorld.dogSpawn,
        duck: MayhemWorld.duckSpawn,
        frog: MayhemWorld.frogSpawn,
        cat: MayhemWorld.catSpawn,
        buffalo: MayhemWorld.buffaloSpawn,
      },
      objective: CompositeObjective(
        description:
            'Cat opens the way, Buffalo clears a path, Dog to the Goal',
        children: <GameObjective>[
          GateOpenObjective(gate: wideGate, description: 'Open the wide gate'),
          PredicateObjective(
            description: 'Clear the crate',
            isSatisfied: () =>
                (crate.position - MayhemWorld.crateSpawn).length > 70,
          ),
          PressurePadActiveObjective(
            pad: heavyPad,
            description: 'Hold the heavy pad',
          ),
          AnimalAtLocationObjective(animal: dog, zone: MayhemWorld.goalBounds),
        ],
      ),
      resettables: <Resettable>[lever, wideGate, heavyGate, heavyPad, crate],
      environmentStatus: () =>
          'Wide: ${wideGate.isOpen ? 'OPEN' : 'CLOSED'}  '
          'Heavy: ${heavyGate.isOpen ? 'OPEN' : 'CLOSED'}  '
          'Pad: ${heavyPad.isActive ? 'ACTIVE' : 'INACTIVE'}',
    )..bindInput();
    lilyPad.onTapped = controller.handleWorldTap;
    lever.onTapped = controller.handleInteractableTap;
  }

  static final Vector2 size = Vector2(1400, 2200);

  static const double passageClearance = 42;

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => const Rect.fromLTWH(0, 1000, 700, 280);

  static Rect get goalBounds => const Rect.fromLTWH(900, 40, 280, 160);

  static Vector2 get padPosition => Vector2(1020, 600);

  static Vector2 get padSize => Vector2(140, 90);

  static Vector2 get crateSpawn => Vector2(980, 430);

  static Vector2 get crateSize => Vector2(140, 80);

  static Vector2 get leverPosition => Vector2(1301, 160);

  static Vector2 get catSpawn => Vector2(1300, 1500);

  static Vector2 get frogSpawn => Vector2(450, 1700);

  static Vector2 get duckSpawn => Vector2(250, 1400);

  static Vector2 get dogSpawn => Vector2(850, 1650);

  static Vector2 get buffaloSpawn => Vector2(1050, 1800);

  static Vector2 get lilyPadPosition => Vector2(250, 1140);

  static Vector2 get spawnPoint => dogSpawn;

  final TerrainMap terrain;
  final DogComponent dog;
  final DuckComponent duck;
  final FrogComponent frog;
  final CatComponent cat;
  final BuffaloComponent buffalo;
  final NormalBarrier westWall;
  final Gate heavyGate;
  final NormalBarrier midWall;
  final NarrowPassage passage;
  final NormalBarrier eastWall;
  final NormalBarrier lowerWestWall;
  final Gate wideGate;
  final NormalBarrier lowerEastWall;
  final NormalBarrier lowerFarWall;
  final PushableComponent crate;
  final HeavyPressurePadComponent heavyPad;
  final LilyPadComponent lilyPad;
  final GoalZone goal;
  final LeverComponent lever;
  late final EnvironmentLink padGateLink;
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
    await add(heavyGate);
    await add(midWall);
    await add(passage);
    await add(eastWall);
    await add(lowerWestWall);
    await add(wideGate);
    await add(lowerEastWall);
    await add(lowerFarWall);
    await add(crate);
    await add(heavyPad);
    await add(lilyPad);
    await add(lever);
    await add(dog);
    await add(duck);
    await add(frog);
    await add(cat);
    await add(buffalo);
  }

  @override
  void update(double dt) {
    super.update(dt);
    heavyPad.refresh();
    padGateLink.sync();
    controller.tick(dt);
    padGateLink.sync();
    _syncTargetMarker();
  }

  void reset() {
    controller.reset();
    heavyPad.refresh();
    padGateLink.sync(force: true);
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
