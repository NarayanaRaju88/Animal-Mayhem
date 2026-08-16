import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/buffalo_component.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/components/animals/monkey_component.dart';
import 'package:animal_mayhem/game/components/animals/snake_component.dart';
import 'package:animal_mayhem/game/components/objects/coil_anchor_component.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/systems/abilities/ability_kind.dart';
import 'package:animal_mayhem/game/systems/behavior/follow_target.dart';
import 'package:animal_mayhem/game/systems/command/coil_command.dart';
import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/environment/environment_link.dart';
import 'package:animal_mayhem/game/systems/environment/force_capability.dart';
import 'package:animal_mayhem/game/systems/environment/height_level.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  CoilAnchorComponent anchor({Vector2? position, bool enabled = true}) {
    return CoilAnchorComponent(
      position: position ?? Vector2(100, 80),
      size: Vector2(60, 60),
      initiallyEnabled: enabled,
    );
  }

  group('Snake', () {
    test('can be created with move, follow, and coil capabilities', () {
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );

      expect(snake, isA<AnimalComponent>());
      expect(snake.hasCoilAbility, isTrue);
      expect(snake.abilities.has(AbilityKind.walk), isTrue);
      expect(snake.abilities.has(AbilityKind.coil), isTrue);
      expect(snake.availableCommands, contains(CommandKind.move));
      expect(snake.availableCommands, contains(CommandKind.follow));
      expect(snake.availableCommands, contains(CommandKind.coil));
      expect(snake.profile.bodyWidth, greaterThan(0));
      expect(snake.profile.bodyHeight, greaterThan(0));
      expect(snake.hasJumpAbility, isFalse);
      expect(snake.hasClimbAbility, isFalse);
      expect(snake.abilities.has(AbilityKind.swim), isFalse);
      expect(snake.abilities.has(AbilityKind.interact), isFalse);
      expect(snake.force.canActivateHeavyPad, isFalse);
      expect(snake.force.weightClass, isNot(WeightClass.heavy));
    });
  });

  group('Coil', () {
    test('anchor can be created and used by a coiling animal', () {
      final CoilAnchorComponent coil = anchor();
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: coil.worldPosition.clone(),
      );

      expect(coil.isCoiled, isFalse);
      expect(coil.isActive, isFalse);
      expect(coil.canBeUsedBy(snake), isTrue);
      expect(snake.canAttemptCoil(coil), isTrue);
      expect(snake.startCoil(coil), isTrue);
      expect(coil.isCoiled, isTrue);
      expect(coil.isActive, isTrue);
      expect(snake.hasCompletedCoil, isTrue);
    });

    test('linked mechanism stays active after the animal moves away', () {
      final CoilAnchorComponent coil = anchor();
      final Gate gate = Gate(
        position: Vector2(0, 200),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentLink link = EnvironmentLink(
        trigger: coil,
        responder: gate,
      );
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: coil.worldPosition.clone(),
      );

      expect(snake.startCoil(coil), isTrue);
      link.sync(force: true);
      expect(gate.isOpen, isTrue);

      snake.position.setValues(700, 500);
      link.sync();
      expect(coil.isCoiled, isTrue);
      expect(gate.isOpen, isTrue);
    });

    test('rejects animals without CoilCapability', () {
      final CoilAnchorComponent coil = anchor();
      final List<AnimalComponent> others = <AnimalComponent>[
        DogComponent(worldBounds: bounds, position: coil.worldPosition.clone()),
        DuckComponent(
          worldBounds: bounds,
          position: coil.worldPosition.clone(),
        ),
        FrogComponent(
          worldBounds: bounds,
          position: coil.worldPosition.clone(),
        ),
        CatComponent(worldBounds: bounds, position: coil.worldPosition.clone()),
        BuffaloComponent(
          worldBounds: bounds,
          position: coil.worldPosition.clone(),
        ),
        MonkeyComponent(
          worldBounds: bounds,
          position: coil.worldPosition.clone(),
        ),
      ];

      for (final AnimalComponent animal in others) {
        expect(animal.hasCoilAbility, isFalse);
        expect(coil.allows(animal), isFalse);
        expect(animal.canAttemptCoil(coil), isFalse);
        expect(animal.startCoil(coil), isFalse);
        expect(coil.isCoiled, isFalse);
      }
    });

    test('disabled anchor cannot be used and does not change state', () {
      final CoilAnchorComponent coil = anchor(enabled: false);
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: coil.worldPosition.clone(),
      );

      expect(snake.startCoil(coil), isFalse);
      expect(coil.isCoiled, isFalse);
      expect(snake.hasCompletedCoil, isFalse);
    });

    test('out-of-range coil fails safely', () {
      final CoilAnchorComponent coil = anchor();
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: Vector2(700, 500),
      );

      expect(snake.startCoil(coil), isFalse);
      expect(coil.isCoiled, isFalse);
      expect(snake.hasCompletedCoil, isFalse);
    });

    test('blocked route fails safely', () {
      final CoilAnchorComponent coil = anchor();
      final Gate gate = Gate(
        position: Vector2(100, 120),
        size: Vector2(80, 40),
      );
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: Vector2(130, 220),
      )..obstacles = <Gate>[gate];

      expect(snake.canAttemptCoil(coil), isFalse);
      expect(snake.startCoil(coil), isFalse);
      expect(coil.isCoiled, isFalse);
    });

    test('CoilCommand completes on a valid coil', () {
      final CoilAnchorComponent coil = anchor();
      final SnakeComponent snake = SnakeComponent(
        worldBounds: bounds,
        position: coil.worldPosition.clone(),
      );
      final CoilCommand command = CoilCommand(actor: snake, anchor: coil);

      command.execute();
      expect(command.status, CommandStatus.completed);
      expect(coil.isCoiled, isTrue);
    });
  });

  group('Commands', () {
    test('HUD shows COIL only for a coil-capable animal on an anchor', () {
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);

      world.controller.handleAnimalTap(world.dog);
      world.controller.handleCoilAnchorTap(world.coilAnchor);
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.coil)),
      );

      world.controller.handleAnimalTap(world.snake);
      world.controller.handleCoilAnchorTap(world.coilAnchor);
      expect(world.controller.availableCommands, contains(CommandKind.coil));
    });

    test('invalid coil target fails safely', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.snake);
      world.controller.commandKind = CommandKind.coil;
      world.controller.selectedTarget = WorldPositionTarget(Vector2(200, 200));
      world.controller.execute();

      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  group('Objective', () {
    test('starts incomplete', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.controller.objective.status, ObjectiveStatus.active);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('cat action alone does not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('buffalo action alone does not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('snake coil alone does not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.snake.startCoil(world.coilAnchor), isTrue);
      world.coilGateLink.sync();
      world.controller.objective.update();
      expect(world.coilAnchor.isCoiled, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('monkey climb alone does not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('cat and buffalo without snake do not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('cat, buffalo, and snake without monkey do not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.snake.startCoil(world.coilAnchor), isTrue);
      world.coilGateLink.sync();
      world.controller.objective.update();
      expect(world.coilGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('monkey goal without prerequisites does not complete', () {
      final MayhemWorld world = MayhemWorld();
      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('complete cat-buffalo-snake-monkey chain succeeds', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.snake.startCoil(world.coilAnchor), isTrue);
      world.coilGateLink.sync();
      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isTrue);
    });
  });

  group('Reset', () {
    test('restores snake, coil, linked gate, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.snake.startCoil(world.coilAnchor), isTrue);
      world.coilGateLink.sync();
      world.monkey.hasCompletedClimb = true;
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.controller.objective.update();

      world.reset();

      expect(world.snake.position.x, closeTo(MayhemWorld.snakeSpawn.x, 0.01));
      expect(world.snake.position.y, closeTo(MayhemWorld.snakeSpawn.y, 0.01));
      expect(world.snake.hasCompletedCoil, isFalse);
      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
      expect(world.monkey.hasCompletedClimb, isFalse);
      expect(world.monkey.heightLevel, HeightLevel.lower);
      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(world.heavyPad.isActive, isFalse);
      expect(world.crate.position.x, closeTo(MayhemWorld.crateSpawn.x, 0.01));
      expect(world.controller.objective.isComplete, isFalse);
    });
  });
}
