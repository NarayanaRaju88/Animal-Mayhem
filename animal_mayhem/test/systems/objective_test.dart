import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/systems/objective/bring_animals_together_objective.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('objective starts active', () {
    final BringAnimalsTogetherObjective objective =
        BringAnimalsTogetherObjective(
          first: DogComponent(worldBounds: bounds, position: Vector2(40, 40)),
          second: DuckComponent(
            worldBounds: bounds,
            position: Vector2(400, 40),
          ),
          distance: 80,
        );

    expect(objective.status, ObjectiveStatus.active);
    expect(objective.isComplete, isFalse);
  });

  test('objective completes when the dog reaches the duck', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 80),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(150, 80),
    );
    final BringAnimalsTogetherObjective objective =
        BringAnimalsTogetherObjective(first: dog, second: duck, distance: 80);

    objective.update();

    expect(objective.status, ObjectiveStatus.completed);
  });

  test('objective reset restores the active state', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(100, 80),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(120, 80),
    );
    final BringAnimalsTogetherObjective objective =
        BringAnimalsTogetherObjective(first: dog, second: duck, distance: 80);

    objective.update();
    expect(objective.isComplete, isTrue);

    dog.position.setValues(40, 40);
    duck.position.setValues(400, 400);
    objective.reset();
    objective.update();

    expect(objective.status, ObjectiveStatus.active);
  });
}
