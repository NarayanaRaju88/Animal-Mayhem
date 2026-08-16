import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/systems/abilities/ability_kind.dart';
import 'package:animal_mayhem/game/systems/command/command_kind.dart';
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

  test('frog can be created from the animal architecture', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(120, 90),
    );

    expect(frog, isA<AnimalComponent>());
    expect(frog.state, AnimalState.idle);
    expect(frog.hasJumpAbility, isTrue);
    expect(frog.abilities.has(AbilityKind.jump), isTrue);
    expect(frog.availableCommands, contains(CommandKind.jump));
  });

  test('frog can enter water', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(400, 180),
      terrain: terrain,
    );
    frog.moveTo(Vector2(400, 310));

    for (int i = 0; i < 180; i++) {
      frog.update(1 / 60);
    }

    expect(terrain.kindAt(frog.position), TerrainKind.water);
  });

  test('frog can receive a jump target', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(100, 100),
    );

    expect(frog.startJump(Vector2(220, 100)), isTrue);
    expect(frog.state, AnimalState.jumping);
    expect(frog.isJumping, isTrue);
  });
}
