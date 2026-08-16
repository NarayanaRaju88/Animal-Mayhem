/// Category A: Buffalo/force history. Live MayhemWorld cases follow current
/// Stage 10 composite rules (coil + climb), not a Stage-8-only objective.
library;

import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/buffalo_component.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/environment/narrow_passage.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/components/objects/heavy_pressure_pad_component.dart';
import 'package:animal_mayhem/game/components/objects/pushable_component.dart';
import 'package:animal_mayhem/game/systems/environment/environment_link.dart';
import 'package:animal_mayhem/game/systems/environment/force_capability.dart';
import 'package:animal_mayhem/game/systems/environment/occupancy_requirement.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  group('Buffalo', () {
    test('uses the shared animal architecture and a heavy force profile', () {
      final BuffaloComponent buffalo = BuffaloComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );

      expect(buffalo, isA<AnimalComponent>());
      expect(buffalo.force.canActivateHeavyPad, isTrue);
      expect(buffalo.force.canPushHeavy, isTrue);
      expect(buffalo.profile.bodyWidth, greaterThan(64));
      expect(buffalo.force.weightClass, WeightClass.heavy);
      expect(buffalo.hasJumpAbility, isFalse);
    });

    test('does not fit a narrow passage by physical profile', () {
      final BuffaloComponent buffalo = BuffaloComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 40),
        size: Vector2(42, 120),
        requiredClearance: 42,
      );
      buffalo.passages = <NarrowPassage>[passage];
      cat.passages = <NarrowPassage>[passage];

      expect(passage.allows(buffalo.profile), isFalse);
      expect(passage.allows(cat.profile), isTrue);
      expect(buffalo.canOccupy(Vector2(121, 80)), isFalse);
    });
  });

  group('Heavy pressure pad', () {
    test('starts inactive and only a heavy animal activates it', () {
      final BuffaloComponent buffalo = BuffaloComponent(
        worldBounds: bounds,
        position: Vector2(40, 40),
      );
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(120, 120),
      );
      final HeavyPressurePadComponent pad = HeavyPressurePadComponent(
        position: Vector2(80, 80),
        size: Vector2(80, 80),
      )..animals = <AnimalComponent>[buffalo, dog];

      expect(pad.isActive, isFalse);
      expect(
        const WeightRequirement(WeightClass.heavy).isSatisfiedBy(dog),
        isFalse,
      );
      expect(
        const WeightRequirement(WeightClass.heavy).isSatisfiedBy(buffalo),
        isTrue,
      );

      dog.position.setValues(120, 120);
      pad.refresh();
      expect(pad.isActive, isFalse);

      buffalo.position.setValues(120, 120);
      pad.refresh();
      expect(pad.isActive, isTrue);

      buffalo.position.setValues(40, 40);
      pad.refresh();
      expect(pad.isActive, isFalse);
    });

    test('opens a following gate through an environment link', () {
      final BuffaloComponent buffalo = BuffaloComponent(
        worldBounds: bounds,
        position: Vector2(120, 120),
      );
      final HeavyPressurePadComponent pad = HeavyPressurePadComponent(
        position: Vector2(80, 80),
        size: Vector2(80, 80),
      )..animals = <AnimalComponent>[buffalo];
      final Gate gate = Gate(
        position: Vector2(0, 200),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentLink link = EnvironmentLink(
        trigger: pad,
        responder: gate,
      );

      pad.refresh();
      link.sync(force: true);
      expect(gate.isOpen, isTrue);

      buffalo.position.setValues(20, 20);
      pad.refresh();
      link.sync();
      expect(gate.isOpen, isFalse);
    });
  });

  group('Pushable', () {
    test('heavy animal can slide a crate and a lighter animal cannot', () {
      final PushableComponent crate = PushableComponent(
        position: Vector2(160, 60),
        size: Vector2(40, 40),
      )..worldBounds = bounds;
      final BuffaloComponent buffalo = BuffaloComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(80, 200),
      );
      buffalo.obstacles = <PushableComponent>[crate];
      buffalo.pushables = <PushableComponent>[crate];
      dog.obstacles = <PushableComponent>[crate];
      dog.pushables = <PushableComponent>[crate];

      expect(dog.canOccupy(Vector2(180, 80)), isFalse);
      expect(buffalo.force.canPushHeavy, isTrue);

      buffalo.moveTo(Vector2(300, 80));
      for (int i = 0; i < 240; i++) {
        buffalo.update(1 / 60);
      }

      expect(crate.position.x, greaterThan(160));
    });
  });

  group('Stage 8 objective', () {
    test('starts incomplete and does not complete from the dog alone', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.controller.objective.status, ObjectiveStatus.active);
      world.dog.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('completes after the chain conditions are satisfied', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.dog.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.wideGate.isOpen, isTrue);
      expect(world.heavyPad.isActive, isTrue);
      expect(world.heavyGate.isOpen, isTrue);
      expect(
        world.controller.objective.isComplete,
        isFalse,
        reason: 'Stage 9 requires the monkey climb, not the dog at the goal',
      );

      world.monkey.hasCompletedClimb = true;
      world.monkey.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(
        world.controller.objective.isComplete,
        isFalse,
        reason: 'Stage 10 requires Snake coil in addition to the monkey climb',
      );

      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      expect(world.snake.startCoil(world.coilAnchor), isTrue);
      world.coilGateLink.sync();
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isTrue);
    });
  });

  group('Reset', () {
    test('restores buffalo, crate, pad, gates, lever, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.crate.position.setFrom(MayhemWorld.crateSpawn + Vector2(-90, 0));
      world.buffalo.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.heavyPad.refresh();
      world.padGateLink.sync();
      world.reset();

      expect(world.lever.isActive, isFalse);
      expect(world.wideGate.isOpen, isFalse);
      expect(world.heavyGate.isOpen, isFalse);
      expect(world.heavyPad.isActive, isFalse);
      expect(world.crate.position.x, closeTo(MayhemWorld.crateSpawn.x, 0.01));
      expect(
        world.buffalo.position.x,
        closeTo(MayhemWorld.buffaloSpawn.x, 0.01),
      );
      expect(world.controller.objective.isComplete, isFalse);
    });
  });
}
