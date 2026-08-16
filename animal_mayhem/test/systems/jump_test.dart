import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('jump starts, progresses, and lands', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(80, 200),
    );
    final Vector2 landing = Vector2(260, 200);

    expect(frog.startJump(landing), isTrue);
    expect(frog.state, AnimalState.jumping);

    final double startX = frog.position.x;
    frog.update(0.2);
    expect(frog.position.x, greaterThan(startX));
    expect(frog.isJumping, isTrue);

    for (int i = 0; i < 60; i++) {
      frog.update(1 / 60);
    }

    expect(frog.isJumping, isFalse);
    expect((frog.position - landing).length, lessThan(1));
  });

  test('jump command completes after landing', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(80, 160),
    );
    frog.startJump(Vector2(200, 160));
    for (int i = 0; i < 80; i++) {
      frog.update(1 / 60);
    }
    expect(frog.state, anyOf(AnimalState.idle, AnimalState.landing));
  });

  test('frog cannot start a second jump while jumping', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(80, 120),
    );

    expect(frog.startJump(Vector2(200, 120)), isTrue);
    expect(frog.startJump(Vector2(300, 120)), isFalse);
    expect(frog.isJumping, isTrue);
  });
}
