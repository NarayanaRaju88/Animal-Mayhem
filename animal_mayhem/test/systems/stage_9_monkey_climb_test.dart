import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/buffalo_component.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/components/animals/monkey_component.dart';
import 'package:animal_mayhem/game/components/environment/climbable_surface_component.dart';
import 'package:animal_mayhem/game/components/environment/narrow_passage.dart';
import 'package:animal_mayhem/game/systems/abilities/ability_kind.dart';
import 'package:animal_mayhem/game/systems/command/climb_command.dart';
import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/environment/height_level.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  ClimbableSurfaceComponent surface({
    Vector2? position,
    Vector2? size,
    bool enabled = true,
  }) {
    return ClimbableSurfaceComponent(
      position: position ?? Vector2(100, 40),
      size: size ?? Vector2(40, 200),
      initiallyEnabled: enabled,
    );
  }

  group('Monkey', () {
    test('can be created with climb, move, and follow capabilities', () {
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );

      expect(monkey, isA<AnimalComponent>());
      expect(monkey.hasClimbAbility, isTrue);
      expect(monkey.abilities.has(AbilityKind.climb), isTrue);
      expect(monkey.abilities.has(AbilityKind.walk), isTrue);
      expect(monkey.availableCommands, contains(CommandKind.move));
      expect(monkey.availableCommands, contains(CommandKind.follow));
      expect(monkey.availableCommands, contains(CommandKind.climb));
      expect(monkey.profile.bodyWidth, greaterThan(0));
      expect(monkey.profile.bodyHeight, greaterThan(0));
    });

    test('does not fit a narrow passage by physical profile', () {
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 40),
        size: Vector2(42, 120),
        requiredClearance: 42,
      );
      monkey.passages = <NarrowPassage>[passage];

      expect(passage.allows(monkey.profile), isFalse);
      expect(monkey.canOccupy(Vector2(121, 80)), isFalse);
    });
  });

  group('Climbable surface', () {
    test('can be created and used by a climbing animal', () {
      final ClimbableSurfaceComponent climbable = surface();
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: climbable.bottom.clone(),
      );

      expect(climbable.canBeUsedBy(monkey), isTrue);
      expect(monkey.canAttemptClimb(climbable), isTrue);
    });

    test('rejects animals without ClimbCapability', () {
      final ClimbableSurfaceComponent climbable = surface();
      final List<AnimalComponent> others = <AnimalComponent>[
        DogComponent(worldBounds: bounds, position: climbable.bottom.clone()),
        DuckComponent(worldBounds: bounds, position: climbable.bottom.clone()),
        FrogComponent(worldBounds: bounds, position: climbable.bottom.clone()),
        CatComponent(worldBounds: bounds, position: climbable.bottom.clone()),
        BuffaloComponent(
          worldBounds: bounds,
          position: climbable.bottom.clone(),
        ),
      ];

      for (final AnimalComponent animal in others) {
        expect(animal.hasClimbAbility, isFalse);
        expect(climbable.allows(animal), isFalse);
        expect(animal.canAttemptClimb(climbable), isFalse);
        expect(animal.startClimb(climbable), isFalse);
        expect(animal.position.y, closeTo(climbable.bottom.y, 0.01));
      }
    });

    test('disabled climbable surface cannot be used', () {
      final ClimbableSurfaceComponent climbable = surface(enabled: false);
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: climbable.bottom.clone(),
      );

      expect(climbable.canBeUsedBy(monkey), isFalse);
      expect(monkey.startClimb(climbable), isFalse);
      expect(monkey.isClimbing, isFalse);
    });

    test('out-of-range climb fails safely', () {
      final ClimbableSurfaceComponent climbable = surface();
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: Vector2(700, 500),
      );
      final Vector2 before = monkey.position.clone();

      expect(monkey.canAttemptClimb(climbable), isFalse);
      expect(monkey.startClimb(climbable), isFalse);
      expect(monkey.position.x, closeTo(before.x, 0.01));
      expect(monkey.position.y, closeTo(before.y, 0.01));
    });
  });

  group('Vertical movement', () {
    test('monkey moves from the lower anchor to the configured top', () {
      final ClimbableSurfaceComponent climbable = surface();
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: climbable.bottom.clone(),
      );

      expect(monkey.startClimb(climbable), isTrue);
      expect(monkey.isClimbing, isTrue);
      expect(monkey.heightLevel, HeightLevel.lower);

      for (int i = 0; i < 80; i++) {
        monkey.update(1 / 60);
      }

      expect(monkey.isClimbing, isFalse);
      expect(monkey.hasCompletedClimb, isTrue);
      expect(monkey.position.x, closeTo(climbable.top.x, 0.5));
      expect(monkey.position.y, closeTo(climbable.top.y, 0.5));
      expect(monkey.heightLevel, HeightLevel.upper);
    });

    test('ClimbCommand completes after a deterministic climb', () {
      final ClimbableSurfaceComponent climbable = surface();
      final MonkeyComponent monkey = MonkeyComponent(
        worldBounds: bounds,
        position: climbable.bottom.clone(),
      );
      final ClimbCommand command = ClimbCommand(
        actor: monkey,
        surface: climbable,
      );

      command.execute();
      expect(command.status, CommandStatus.executing);

      for (int i = 0; i < 80; i++) {
        monkey.update(1 / 60);
        command.tick(1 / 60);
      }

      expect(command.status, CommandStatus.completed);
      expect(monkey.hasCompletedClimb, isTrue);
    });
  });

  group('Commands', () {
    test('HUD shows CLIMB only for a climb-capable animal on a climbable', () {
      final MayhemWorld world = MayhemWorld();
      world.monkey.position.setFrom(world.climbable.bottom);

      world.controller.handleAnimalTap(world.dog);
      world.controller.handleClimbableTap(world.climbable);
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.climb)),
      );

      world.controller.handleAnimalTap(world.monkey);
      world.controller.handleClimbableTap(world.climbable);
      expect(world.controller.availableCommands, contains(CommandKind.climb));
    });

    test('invalid climb execute fails without corrupting the objective', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.dog);
      world.controller.commandKind = CommandKind.climb;
      world.controller.handleClimbableTap(world.climbable);
      world.controller.execute();

      expect(world.dog.hasCompletedClimb, isFalse);
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  group('Environment', () {
    test('existing gates, pads, crates, and links still work', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.wideGate.isOpen, isFalse);
      world.lever.interact();
      expect(world.wideGate.isOpen, isTrue);

      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      expect(
        (world.crate.position - MayhemWorld.crateSpawn).length,
        greaterThan(70),
      );

      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);
    });
  });

  group('Objective', () {
    test('starts incomplete', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.controller.objective.status, ObjectiveStatus.active);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('cat-only interaction is insufficient', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.controller.objective.update();
      expect(world.wideGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('buffalo-only heavy mechanism is insufficient', () {
      final MayhemWorld world = MayhemWorld();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.controller.objective.update();
      expect(world.heavyPad.isActive, isTrue);
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('monkey at the goal without the chain does not complete', () {
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

    test('complete chain completes the objective', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.wideGate.isOpen, isTrue);
      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isTrue);
    });
  });

  group('Reset', () {
    test('restores monkey, climb, platforms, gates, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.climbable.isEnabled = false;
      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(world.climbable.top);
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.cat.position.setFrom(MayhemWorld.leverPosition);
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.controller.objective.update();

      world.reset();

      expect(world.monkey.position.x, closeTo(MayhemWorld.monkeySpawn.x, 0.01));
      expect(world.monkey.position.y, closeTo(MayhemWorld.monkeySpawn.y, 0.01));
      expect(world.monkey.hasCompletedClimb, isFalse);
      expect(world.monkey.heightLevel, HeightLevel.lower);
      expect(world.climbable.isEnabled, isTrue);
      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(world.heavyPad.isActive, isFalse);
      expect(world.crate.position.x, closeTo(MayhemWorld.crateSpawn.x, 0.01));
      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(
        world.buffalo.position.x,
        closeTo(MayhemWorld.buffaloSpawn.x, 0.01),
      );
      expect(world.controller.objective.isComplete, isFalse);
    });
  });
}
