import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/components/objects/obstacle_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('obstacle can be created', () {
    final JumpableBarrier barrier = JumpableBarrier(
      position: Vector2(40, 40),
      size: Vector2(80, 20),
    );
    final NormalBarrier wall = NormalBarrier(
      position: Vector2(40, 80),
      size: Vector2(80, 20),
    );

    expect(barrier.jumpable, isTrue);
    expect(wall.jumpable, isFalse);
    expect(barrier.containsWorldPoint(Vector2(50, 45)), isTrue);
  });

  test('obstacle blocks normal movement', () {
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(80, 100),
    );
    dog.obstacles = <ObstacleComponent>[
      NormalBarrier(position: Vector2(140, 80), size: Vector2(40, 40)),
    ];
    dog.moveTo(Vector2(300, 100));

    for (int i = 0; i < 180; i++) {
      dog.update(1 / 60);
    }

    expect(dog.position.x, lessThan(140));
  });

  test('jumpable obstacle can be crossed by a frog jump', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(80, 120),
    );
    frog.obstacles = <ObstacleComponent>[
      JumpableBarrier(position: Vector2(150, 90), size: Vector2(40, 60)),
    ];

    expect(frog.startJump(Vector2(240, 120)), isTrue);
    for (int i = 0; i < 80; i++) {
      frog.update(1 / 60);
    }

    expect(frog.position.x, greaterThan(190));
  });
}
