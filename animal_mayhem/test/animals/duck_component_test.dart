import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_kind.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_map.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);
  final TerrainMap terrain = TerrainMap(
    worldBounds: bounds,
    waterBounds: const Rect.fromLTWH(0, 250, 800, 120),
  );

  test('duck can be created idle', () {
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(100, 80),
      terrain: terrain,
    );

    expect(duck.speciesName, 'Duck');
    expect(duck.state, AnimalState.idle);
    expect(duck.canOccupy(Vector2(400, 300)), isTrue);
  });

  test('duck can move toward a world target', () {
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(80, 80),
      terrain: terrain,
    );
    duck.moveTo(Vector2(220, 80));

    duck.update(0.4);

    expect(duck.position.x, greaterThan(80));
    expect(duck.state, AnimalState.moving);
  });

  test('duck can move through water', () {
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(400, 180),
      terrain: terrain,
    );
    duck.moveTo(Vector2(400, 310));

    var sawSwimming = false;
    for (int i = 0; i < 180; i++) {
      duck.update(1 / 60);
      if (duck.state == AnimalState.swimming) {
        sawSwimming = true;
      }
    }

    expect(terrain.kindAt(duck.position), TerrainKind.water);
    expect(sawSwimming, isTrue);
  });
}
