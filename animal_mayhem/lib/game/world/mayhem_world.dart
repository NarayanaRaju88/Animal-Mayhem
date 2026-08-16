import 'dart:ui';

import 'package:flame/components.dart';

import '../components/animals/animal_state.dart';
import '../components/animals/dog_component.dart';
import '../components/environment/development_play_area.dart';
import '../components/objects/target_marker.dart';

/// Playable development world. Larger than a typical phone viewport.
class MayhemWorld extends World {
  MayhemWorld()
    : dog = DogComponent(
        worldBounds: MayhemWorld.bounds,
        position: MayhemWorld.spawnPoint,
      );

  static final Vector2 size = Vector2(3200, 2400);

  static Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  static Vector2 get spawnPoint => size / 2;

  final DogComponent dog;

  TargetMarker? _targetMarker;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(DevelopmentPlayArea(worldSize: size, onWorldTap: setDogTarget));
    await add(dog);
  }

  void setDogTarget(Vector2 worldPosition) {
    dog.moveTo(worldPosition);
    _targetMarker?.removeFromParent();
    _targetMarker = TargetMarker(position: dog.target!.worldPosition);
    add(_targetMarker!);
  }

  void reset() {
    dog.resetTo(spawnPoint);
    _clearMarker();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dog.state == AnimalState.idle) {
      _clearMarker();
    }
  }

  void _clearMarker() {
    _targetMarker?.removeFromParent();
    _targetMarker = null;
  }
}
