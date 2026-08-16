import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/animal_component.dart';
import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../components/animals/frog_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/environment/water_region.dart';
import '../components/objects/goal_zone.dart';
import '../components/objects/lily_pad_component.dart';
import '../components/objects/obstacle_component.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/terrain_map.dart';
import '../systems/objective/animal_at_location_objective.dart';
import '../systems/objective/bring_animals_together_objective.dart';
import '../systems/objective/composite_objective.dart';
import '../systems/objective/game_objective.dart';

/// Stage 4 development puzzle.
///
/// Frog starts north of the water and cannot walk to the goal (jumpable
/// barrier). Duck starts in the south and must reach the Dog, who cannot
/// cross water. Lily pads are valid frog jump landings in the water.
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
      jumpableBarrier = JumpableBarrier(
        position: Vector2(0, 280),
        size: Vector2(MayhemWorld.size.x, 56),
      ),
      normalBarrier = NormalBarrier(
        position: Vector2(1180, 1480),
        size: Vector2(160, 90),
      ),
      lilyPad = LilyPadComponent(position: MayhemWorld.lilyPadPosition),
      goal = GoalZone(bounds: MayhemWorld.goalBounds) {
    final List<ObstacleComponent> blockers = <ObstacleComponent>[
      jumpableBarrier,
      normalBarrier,
    ];
    for (final AnimalComponent animal in <AnimalComponent>[dog, duck, frog]) {
      animal.terrain = terrain;
      animal.obstacles = blockers;
    }
    controller = GameController(
      animals: <AnimalComponent>[dog, duck, frog],
      spawns: <AnimalComponent, Vector2>{
        dog: MayhemWorld.dogSpawn,
        duck: MayhemWorld.duckSpawn,
        frog: MayhemWorld.frogSpawn,
      },
      objective: CompositeObjective(
        description: 'Frog to the Goal, Dog with Duck',
        children: <GameObjective>[
          AnimalAtLocationObjective(animal: frog, zone: MayhemWorld.goalBounds),
          BringAnimalsTogetherObjective(
            first: dog,
            second: duck,
            distance: dog.attributes.followDistance + 16,
          ),
        ],
      ),
    )..bindInput();
    lilyPad.onTapped = controller.handleWorldTap;
  }

  static final Vector2 size = Vector2(1400, 2200);

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => Rect.fromLTWH(0, 700, size.x, 420);

  static Rect get goalBounds => const Rect.fromLTWH(480, 60, 440, 160);

  static Vector2 get frogSpawn => Vector2(size.x / 2, 480);

  static Vector2 get duckSpawn => Vector2(420, 1380);

  static Vector2 get dogSpawn => Vector2(980, 1880);

  static Vector2 get lilyPadPosition => Vector2(size.x / 2, 910);

  static Vector2 get spawnPoint => dogSpawn;

  final TerrainMap terrain;
  final DogComponent dog;
  final DuckComponent duck;
  final FrogComponent frog;
  final JumpableBarrier jumpableBarrier;
  final NormalBarrier normalBarrier;
  final LilyPadComponent lilyPad;
  final GoalZone goal;
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
    await add(jumpableBarrier);
    await add(normalBarrier);
    await add(lilyPad);
    await add(dog);
    await add(duck);
    await add(frog);
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
