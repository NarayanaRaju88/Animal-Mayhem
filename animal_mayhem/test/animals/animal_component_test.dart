import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_attributes.dart';
import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  AnimalComponent createAnimal({Vector2? position}) {
    return AnimalComponent(
      attributes: AnimalAttributes(speed: 120, size: Vector2(40, 24)),
      worldBounds: bounds,
      position: position ?? Vector2(100, 100),
    );
  }

  test('animal can be created with idle state and position', () {
    final AnimalComponent animal = createAnimal(position: Vector2(40, 80));

    expect(animal.state, AnimalState.idle);
    expect(animal.target, isNull);
    expect(animal.position.x, 40);
    expect(animal.position.y, 80);
    expect(animal.attributes.speed, 120);
  });

  test('moveTo assigns a target and enters moving', () {
    final AnimalComponent animal = createAnimal();

    animal.moveTo(Vector2(200, 100));

    expect(animal.state, AnimalState.moving);
    expect(animal.target, isNotNull);
    expect(animal.target!.worldPosition.x, 200);
  });
}
