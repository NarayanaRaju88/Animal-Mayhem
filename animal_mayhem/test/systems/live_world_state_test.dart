import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/systems/objective/composite_objective.dart';
import 'package:animal_mayhem/game/systems/objective/game_objective.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// Category B: current live MayhemWorld state, reset, and bypass coverage.
void main() {
  void syncEnvironment(MayhemWorld world) {
    world.heavyPad.refresh();
    world.padGateLink.sync();
    world.coilGateLink.sync();
  }

  void satisfyCat(MayhemWorld world) {
    world.cat.position.setFrom(MayhemWorld.leverPosition);
    world.controller.handleAnimalTap(world.cat);
    world.controller.chooseCommand(CommandKind.interact);
    world.controller.handleInteractableTap(world.lever);
    world.controller.execute();
  }

  void satisfyBuffalo(MayhemWorld world) {
    world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
    world.buffalo.position.setFrom(
      MayhemWorld.padPosition + MayhemWorld.padSize / 2,
    );
    syncEnvironment(world);
  }

  void satisfySnake(MayhemWorld world) {
    world.snake.position.setFrom(world.coilAnchor.worldPosition);
    world.controller.handleAnimalTap(world.snake);
    world.controller.chooseCommand(CommandKind.coil);
    world.controller.handleCoilAnchorTap(world.coilAnchor);
    world.controller.execute();
    world.coilGateLink.sync();
  }

  void satisfyMonkey(MayhemWorld world) {
    world.monkey.position.setFrom(world.climbable.bottom);
    world.controller.handleAnimalTap(world.monkey);
    world.controller.chooseCommand(CommandKind.climb);
    world.controller.handleClimbableTap(world.climbable);
    world.controller.execute();
    for (int i = 0; i < 80; i++) {
      world.monkey.update(1 / 60);
      world.controller.commands.tick(1 / 60);
    }
    world.monkey.position.setFrom(
      Vector2(
        MayhemWorld.goalBounds.center.dx,
        MayhemWorld.goalBounds.center.dy,
      ),
    );
  }

  List<GameObjective> childrenOf(MayhemWorld world) {
    return (world.controller.objective as CompositeObjective).children;
  }

  group('Live-world pad and gate semantics', () {
    test('heavy pad is occupancy-based and the linked gate follows it', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.heavyPad.isActive, isFalse);
      expect(world.heavyGate.isOpen, isFalse);

      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      syncEnvironment(world);
      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);

      world.buffalo.position.setFrom(MayhemWorld.buffaloSpawn);
      syncEnvironment(world);
      expect(world.heavyPad.isActive, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
    });

    test('pad objective latches after the buffalo leaves the pad', () {
      final MayhemWorld world = MayhemWorld();
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      syncEnvironment(world);
      world.controller.objective.update();
      expect(childrenOf(world)[3].isComplete, isTrue);

      world.buffalo.position.setFrom(MayhemWorld.buffaloSpawn);
      syncEnvironment(world);
      world.controller.objective.update();

      expect(world.heavyPad.isActive, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(childrenOf(world)[3].isComplete, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('a non-heavy animal on the pad does not open the heavy gate', () {
      final MayhemWorld world = MayhemWorld();
      world.dog.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      syncEnvironment(world);
      world.controller.objective.update();

      expect(world.heavyPad.isActive, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(childrenOf(world)[3].isComplete, isFalse);
    });
  });

  group('Live-world composite bypasses', () {
    test('Cat INTERACT alone does not complete the composite', () {
      final MayhemWorld world = MayhemWorld();
      satisfyCat(world);
      world.controller.objective.update();

      expect(world.lever.isActive, isTrue);
      expect(world.wideGate.isOpen, isTrue);
      expect(childrenOf(world)[0].isComplete, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('Buffalo pad/crate alone does not complete the composite', () {
      final MayhemWorld world = MayhemWorld();
      satisfyBuffalo(world);
      world.controller.objective.update();

      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('Snake COIL alone does not complete the composite', () {
      final MayhemWorld world = MayhemWorld();
      satisfySnake(world);
      world.controller.objective.update();

      expect(world.coilAnchor.isCoiled, isTrue);
      expect(world.coilGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('Monkey CLIMB alone does not complete the composite', () {
      final MayhemWorld world = MayhemWorld();
      satisfyMonkey(world);
      world.controller.objective.update();

      expect(world.monkey.hasCompletedClimb, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('Cat, Buffalo, and Snake without Monkey do not complete', () {
      final MayhemWorld world = MayhemWorld();
      satisfyCat(world);
      satisfyBuffalo(world);
      satisfySnake(world);
      world.controller.objective.update();

      expect(world.coilGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  group('Invalid actions do not mutate live-world state', () {
    test(
      'out-of-range INTERACT leaves lever, gate, and objective unchanged',
      () {
        final MayhemWorld world = MayhemWorld();
        world.controller.handleAnimalTap(world.cat);
        world.controller.chooseCommand(CommandKind.interact);
        world.controller.handleInteractableTap(world.lever);
        world.controller.execute();

        expect(world.lever.isActive, isFalse);
        expect(world.wideGate.isOpen, isFalse);
        world.controller.objective.update();
        expect(world.controller.objective.isComplete, isFalse);
      },
    );

    test('wrong-target INTERACT does not activate the lever', () {
      final MayhemWorld world = MayhemWorld();
      world.cat.position.setFrom(MayhemWorld.leverPosition);
      world.controller.handleAnimalTap(world.cat);
      world.controller.chooseCommand(CommandKind.interact);
      world.controller.handleClimbableTap(world.climbable);
      world.controller.execute();

      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
    });

    test('animal without interact capability cannot use the lever', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.dog.interactWith(world.lever), isFalse);
      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
    });

    test('out-of-range COIL leaves coil, gate, and objective unchanged', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.handleCoilAnchorTap(world.coilAnchor);
      world.controller.execute();

      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
      expect(world.snake.hasCompletedCoil, isFalse);
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('wrong-target COIL does not hold the anchor', () {
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.handleClimbableTap(world.climbable);
      world.controller.execute();

      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
    });

    test('animal without coil capability cannot hold the anchor', () {
      final MayhemWorld world = MayhemWorld();
      world.dog.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.dog.startCoil(world.coilAnchor), isFalse);
      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
    });

    test('blocked CLIMB leaves monkey, climbable, and objective unchanged', () {
      final MayhemWorld world = MayhemWorld();
      final Vector2 before = world.monkey.position.clone();
      world.monkey.position.setValues(
        world.climbable.bottom.x,
        world.climbable.bottom.y + 60,
      );
      expect(world.heavyGate.isOpen, isFalse);
      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.handleClimbableTap(world.climbable);
      world.controller.execute();

      expect(world.monkey.isClimbing, isFalse);
      expect(world.monkey.hasCompletedClimb, isFalse);
      expect(world.climbable.isEnabled, isTrue);
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
      world.monkey.position.setFrom(before);
    });

    test('animal without climb capability cannot climb', () {
      final MayhemWorld world = MayhemWorld();
      world.dog.position.setFrom(world.climbable.bottom);
      expect(world.dog.startClimb(world.climbable), isFalse);
      expect(world.dog.hasCompletedClimb, isFalse);
      expect(world.climbable.isEnabled, isTrue);
    });

    test('animal without heavy force cannot slide the crate', () {
      final MayhemWorld world = MayhemWorld();
      final Vector2 crateBefore = world.crate.position.clone();
      world.dog.position.setValues(
        crateBefore.x - world.dog.size.x,
        crateBefore.y + world.crate.size.y / 2,
      );
      world.dog.moveTo(crateBefore + world.crate.size / 2);
      for (int i = 0; i < 180; i++) {
        world.dog.update(1 / 60);
      }

      expect(world.crate.position.x, closeTo(crateBefore.x, 0.5));
      expect(world.crate.position.y, closeTo(crateBefore.y, 0.5));
      expect(world.heavyPad.isActive, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
    });
  });

  group('Live-world puzzle flow and reset', () {
    test('Cat, Buffalo, Snake, and Monkey complete the current world', () {
      final MayhemWorld world = MayhemWorld();
      satisfyCat(world);
      satisfyBuffalo(world);
      satisfySnake(world);
      satisfyMonkey(world);
      world.controller.objective.update();

      expect(world.lever.isActive, isTrue);
      expect(world.wideGate.isOpen, isTrue);
      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);
      expect(world.coilAnchor.isCoiled, isTrue);
      expect(world.coilGate.isOpen, isTrue);
      expect(world.snake.hasCompletedCoil, isTrue);
      expect(world.monkey.hasCompletedClimb, isTrue);
      expect(world.controller.objective.isComplete, isTrue);
    });

    test('coil remains held after the snake moves away', () {
      final MayhemWorld world = MayhemWorld();
      satisfySnake(world);
      world.snake.position.setFrom(MayhemWorld.snakeSpawn);
      world.coilGateLink.sync();

      expect(world.coilAnchor.isCoiled, isTrue);
      expect(world.coilGate.isOpen, isTrue);
    });

    test('reset restores animals, environment, objectives, and command UI', () {
      final MayhemWorld world = MayhemWorld();
      satisfyCat(world);
      satisfyBuffalo(world);
      satisfySnake(world);
      satisfyMonkey(world);
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isTrue);

      world.reset();

      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(
        world.buffalo.position.x,
        closeTo(MayhemWorld.buffaloSpawn.x, 0.01),
      );
      expect(world.snake.position.x, closeTo(MayhemWorld.snakeSpawn.x, 0.01));
      expect(world.monkey.position.x, closeTo(MayhemWorld.monkeySpawn.x, 0.01));
      expect(world.monkey.hasCompletedClimb, isFalse);
      expect(world.snake.hasCompletedCoil, isFalse);
      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(world.heavyPad.isActive, isFalse);
      expect(world.crate.position.x, closeTo(MayhemWorld.crateSpawn.x, 0.01));
      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.coilGate.isOpen, isFalse);
      expect(world.climbable.isEnabled, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
      expect(world.controller.selectedAnimal, isNull);
      expect(world.controller.commandKind, isNull);
      expect(world.controller.selectedTarget, isNull);
      expect(world.controller.actionFeedback, isNull);
      expect(world.controller.commands.current, isNull);
      for (final GameObjective child in childrenOf(world)) {
        expect(child.isComplete, isFalse);
      }
    });
  });
}
