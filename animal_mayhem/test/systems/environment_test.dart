import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_kind.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_map.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);
  final TerrainMap terrain = TerrainMap(
    worldBounds: bounds,
    waterBounds: const Rect.fromLTWH(0, 280, 800, 140),
  );

  test('water region can be detected', () {
    expect(terrain.kindAt(Vector2(100, 100)), TerrainKind.land);
    expect(terrain.kindAt(Vector2(100, 300)), TerrainKind.water);
  });

  test('dog cannot enter water', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(400, 180),
      terrain: terrain,
    );
    dog.moveTo(Vector2(400, 360));

    for (int i = 0; i < 240; i++) {
      dog.update(1 / 60);
    }

    expect(terrain.kindAt(dog.position), TerrainKind.land);
    expect(dog.position.y, lessThan(280));
  });

  test('duck can enter water', () {
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(400, 180),
      terrain: terrain,
    );
    duck.moveTo(Vector2(400, 340));

    for (int i = 0; i < 240; i++) {
      duck.update(1 / 60);
    }

    expect(terrain.kindAt(duck.position), TerrainKind.water);
  });
}
