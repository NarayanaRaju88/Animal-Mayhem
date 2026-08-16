import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_attributes.dart';
import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void step(AnimalComponent animal, {required int frames, double dt = 1 / 60}) {
  for (int i = 0; i < frames; i++) {
    animal.update(dt);
  }
}

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('dog moves toward a target over time', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 200),
    );
    dog.moveTo(Vector2(400, 200));

    step(dog, frames: 30);

    expect(dog.position.x, greaterThan(100));
    expect(dog.position.x, lessThan(400));
    expect((dog.position.y - 200).abs(), lessThan(8));
  });

  test('dog stops close to the target and returns to idle', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 100),
    );
    final Vector2 destination = Vector2(160, 100);
    dog.moveTo(destination);

    step(dog, frames: 180);

    expect(dog.state, AnimalState.idle);
    expect(dog.target, isNull);
    expect((dog.position - destination).length, lessThan(1));
  });

  test('dog stays inside world boundaries', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(40, 40),
    );
    dog.moveTo(Vector2(-400, -400));

    step(dog, frames: 240);

    final double minX = dog.size.x / 2;
    final double minY = dog.size.y / 2;
    expect(dog.position.x, greaterThanOrEqualTo(minX - 0.01));
    expect(dog.position.y, greaterThanOrEqualTo(minY - 0.01));
    expect(dog.position.x, lessThanOrEqualTo(800 - minX + 0.01));
    expect(dog.position.y, lessThanOrEqualTo(600 - minY + 0.01));
  });

  test('custom-speed animal does not depend on a single frame size', () {
    final AnimalComponent animal = AnimalComponent(
      attributes: AnimalAttributes(speed: 100, size: Vector2(20, 20)),
      worldBounds: bounds,
      position: Vector2(50, 50),
    );
    animal.moveTo(Vector2(250, 50));

    animal.update(0.25);
    final double afterQuarterSecond = animal.position.x;
    animal.update(0.25);
    final double afterHalfSecond = animal.position.x;

    expect(afterQuarterSecond, greaterThan(50));
    expect(afterHalfSecond, greaterThan(afterQuarterSecond));
  });
}
