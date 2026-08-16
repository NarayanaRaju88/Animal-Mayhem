import 'package:animal_mayhem/game/components/animals/animal_attributes.dart';
import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/command/follow_command.dart';
import 'package:animal_mayhem/game/systems/command/jump_command.dart';
import 'package:animal_mayhem/game/systems/command/move_command.dart';
import 'package:animal_mayhem/game/systems/behavior/follow_target.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:ui';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  AnimalComponent animal() {
    return AnimalComponent(
      attributes: AnimalAttributes(speed: 120, size: Vector2(20, 20)),
      worldBounds: bounds,
      position: Vector2(80, 80),
    );
  }

  test('command can be created in the pending state', () {
    final MoveCommand command = MoveCommand(
      actor: animal(),
      destination: Vector2(200, 80),
    );

    expect(command.status, CommandStatus.pending);
  });

  test('command execute starts the animal and marks executing', () {
    final AnimalComponent actor = animal();
    final MoveCommand command = MoveCommand(
      actor: actor,
      destination: Vector2(200, 80),
    );

    command.execute();

    expect(command.status, CommandStatus.executing);
    expect(actor.target, isNotNull);
  });

  test('command can complete after the animal arrives', () {
    final AnimalComponent actor = animal();
    final MoveCommand command = MoveCommand(
      actor: actor,
      destination: Vector2(100, 80),
    );
    command.execute();
    for (int i = 0; i < 120; i++) {
      actor.update(1 / 60);
      command.tick(1 / 60);
    }

    expect(command.status, CommandStatus.completed);
  });

  test('command can be cancelled', () {
    final AnimalComponent actor = animal();
    final FollowCommand command = FollowCommand(
      actor: actor,
      target: WorldPositionTarget(Vector2(300, 80)),
      followDistance: 72,
    );
    command.execute();
    command.cancel();

    expect(command.status, CommandStatus.cancelled);
    expect(actor.target, isNull);
  });

  test('JumpCommand can be created, executed, and completed', () {
    final FrogComponent frog = FrogComponent(
      worldBounds: bounds,
      position: Vector2(80, 120),
    );
    final JumpCommand command = JumpCommand(
      actor: frog,
      destination: Vector2(200, 120),
    );

    expect(command.status, CommandStatus.pending);
    command.execute();
    expect(command.status, CommandStatus.executing);
    expect(frog.isJumping, isTrue);

    for (int i = 0; i < 80; i++) {
      frog.update(1 / 60);
      command.tick(1 / 60);
    }

    expect(command.status, CommandStatus.completed);
  });
}
