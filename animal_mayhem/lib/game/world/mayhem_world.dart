import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/environment/water_region.dart';
import '../components/objects/target_marker.dart';
import '../session/game_controller.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/environment/terrain_map.dart';

/// First playable development level: land, water, land.
///
/// Dog starts north of the water and cannot cross it. Duck starts south and
/// can swim. Bring the animals together, typically by moving the duck across
/// the water and then following with the dog.
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
      ) {
    dog.terrain = terrain;
    duck.terrain = terrain;
    controller = GameController(
      dog: dog,
      duck: duck,
      dogSpawn: MayhemWorld.dogSpawn,
      duckSpawn: MayhemWorld.duckSpawn,
    )..bindInput();
  }

  static final Vector2 size = Vector2(1400, 2000);

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Rect get waterBounds => Rect.fromLTWH(0, 820, size.x, 360);

  static Vector2 get dogSpawn => Vector2(size.x / 2, 420);

  static Vector2 get duckSpawn => Vector2(size.x / 2, 1680);

  static Vector2 get spawnPoint => dogSpawn;

  final TerrainMap terrain;
  final DogComponent dog;
  final DuckComponent duck;
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
    await add(dog);
    await add(duck);
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
