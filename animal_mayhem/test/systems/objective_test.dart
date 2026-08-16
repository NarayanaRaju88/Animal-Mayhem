import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/systems/objective/animal_at_location_objective.dart';
import 'package:animal_mayhem/game/systems/objective/bring_animals_together_objective.dart';
import 'package:animal_mayhem/game/systems/objective/composite_objective.dart';
import 'package:animal_mayhem/game/systems/objective/game_objective.dart';
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

  test('stage 4 composite objective starts incomplete and can complete', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(40, 40),
    );
    final DuckComponent duck = DuckComponent(
      worldBounds: bounds,
      position: Vector2(400, 40),
    );
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(40, 400),
    );
    const Rect goal = Rect.fromLTWH(200, 350, 80, 80);
    final CompositeObjective objective = CompositeObjective(
      description: 'Frog to the Goal, Dog with Duck',
      children: <GameObjective>[
        AnimalAtLocationObjective(animal: frog, zone: goal),
        BringAnimalsTogetherObjective(first: dog, second: duck, distance: 80),
      ],
    );

    expect(objective.status, ObjectiveStatus.active);
    objective.update();
    expect(objective.isComplete, isFalse);

    frog.position.setValues(220, 380);
    duck.position.setValues(50, 40);
    objective.update();
    expect(objective.status, ObjectiveStatus.completed);

    frog.position.setValues(40, 400);
    duck.position.setValues(400, 40);
    objective.reset();
    objective.update();
    expect(objective.status, ObjectiveStatus.active);
  });
}
