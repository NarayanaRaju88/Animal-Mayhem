import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/systems/behavior/animal_target.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/command/follow_command.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void stepBoth(
  AnimalComponent first,
  AnimalComponent second, {
  required int frames,
  double dt = 1 / 60,
}) {
  for (int i = 0; i < frames; i++) {
    first.update(dt);
    second.update(dt);
  }
}

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 1200, 600);

  test('dog can receive a FollowCommand', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(80, 80),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(400, 80),
    );
    final FollowCommand command = FollowCommand(
      actor: dog,
      target: AnimalTarget(duck),
      followDistance: dog.attributes.followDistance,
    );

    command.execute();

    expect(command.status, CommandStatus.executing);
    expect(dog.state, AnimalState.following);
  });

  test('dog follows a moving duck target', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(80, 200),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(280, 200),
    );
    dog.follow(AnimalTarget(duck), stopDistance: 72);
    duck.moveTo(Vector2(700, 200));

    final double startX = dog.position.x;
    stepBoth(dog, duck, frames: 45);

    expect(dog.position.x, greaterThan(startX));
    expect(dog.position.x, lessThan(duck.position.x));
  });

  test('dog stops at the configured follow distance', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(80, 120),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(400, 120),
    );
    const double followDistance = 72;
    dog.follow(AnimalTarget(duck), stopDistance: followDistance);

    stepBoth(dog, duck, frames: 240);

    final double distance = (dog.position - duck.position).length;
    expect(distance, lessThanOrEqualTo(followDistance + 8));
    expect(distance, greaterThan(40));
    expect(dog.state, AnimalState.following);
  });
}
