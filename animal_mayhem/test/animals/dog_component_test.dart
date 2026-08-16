import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/systems/behavior/follow_target.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('dog can be created and reuses animal movement', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(120, 90),
    );

    expect(dog, isA<AnimalComponent>());
    expect(dog.state, AnimalState.idle);
    expect(dog.position.x, 120);
    expect(dog.position.y, 90);
  });

  test('dog can receive a world position target', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 100),
    );

    dog.moveTo(Vector2(300, 140));

    expect(dog.state, AnimalState.moving);
    expect(dog.target, isA<WorldPositionTarget>());
    expect(dog.target!.worldPosition.x, 300);
    expect(dog.target!.worldPosition.y, 140);
  });

  test('dog follow uses the following state', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 100),
    );

    dog.follow(WorldPositionTarget(Vector2(180, 100)));

    expect(dog.state, AnimalState.following);
    expect(dog.target, isNotNull);
  });
}
