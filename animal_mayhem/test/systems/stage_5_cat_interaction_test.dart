import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/animal_state.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/environment/narrow_passage.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/components/objects/lever_component.dart';
import 'package:animal_mayhem/game/systems/abilities/ability_kind.dart';
import 'package:animal_mayhem/game/systems/behavior/interactable_target.dart';
import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/command/interact_command.dart';
import 'package:animal_mayhem/game/systems/environment/physical_profile.dart';
import 'package:animal_mayhem/game/systems/interaction/interactable.dart';
import 'package:animal_mayhem/game/systems/environment/route_state.dart';
import 'package:animal_mayhem/game/systems/objective/animal_at_location_objective.dart';
import 'package:animal_mayhem/game/systems/objective/composite_objective.dart';
import 'package:animal_mayhem/game/systems/objective/game_objective.dart';
import 'package:animal_mayhem/game/systems/objective/gate_open_objective.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  group('Cat', () {
    test('can be created from the shared animal architecture', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );

      expect(cat, isA<AnimalComponent>());
      expect(cat.state, AnimalState.idle);
      expect(cat.abilities.has(AbilityKind.interact), isTrue);
      expect(cat.availableCommands, contains(CommandKind.move));
      expect(cat.availableCommands, contains(CommandKind.follow));
      expect(cat.availableCommands, contains(CommandKind.interact));
      expect(cat.profile.bodyWidth, 34);
      expect(cat.profile.bodyHeight, 26);
    });

    test('can enter a narrow passage that matches its profile', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(121, 80),
      );
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 120),
        size: Vector2(42, 160),
        requiredClearance: 42,
      );
      cat.passages = <NarrowPassage>[passage];

      expect(passage.allows(cat.profile), isTrue);
      expect(cat.canOccupy(Vector2(121, 200)), isTrue);
    });
  });

  group('Passage', () {
    test('has configurable clearance and admits only fitting profiles', () {
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 100),
        size: Vector2(40, 80),
        requiredClearance: 40,
      );
      const PhysicalProfile small = PhysicalProfile(
        bodyWidth: 34,
        bodyHeight: 26,
      );
      const PhysicalProfile large = PhysicalProfile(
        bodyWidth: 64,
        bodyHeight: 40,
      );

      expect(passage.requiredClearance, 40);
      expect(passage.allows(small), isTrue);
      expect(passage.allows(large), isFalse);
    });

    test('oversized animal cannot occupy the passage', () {
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 40),
        size: Vector2(42, 120),
        requiredClearance: 42,
      );
      dog.passages = <NarrowPassage>[passage];

      expect(passage.allows(dog.profile), isFalse);
      expect(dog.canOccupy(Vector2(121, 80)), isFalse);
    });

    test('cat can walk through the passage without teleporting', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(121, 80),
      );
      final NarrowPassage passage = NarrowPassage(
        position: Vector2(100, 120),
        size: Vector2(42, 160),
        requiredClearance: 42,
      );
      cat.passages = <NarrowPassage>[passage];
      cat.moveTo(Vector2(121, 320));

      final List<double> samples = <double>[];
      for (int i = 0; i < 240; i++) {
        cat.update(1 / 60);
        samples.add(cat.position.y);
      }

      expect(cat.position.y, greaterThan(280));
      expect(samples.any((double y) => y > 120 && y < 280), isTrue);
      expect(cat.canOccupy(cat.position), isTrue);
    });
  });

  group('Interaction', () {
    test('InteractCommand can be created', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final LeverComponent lever = LeverComponent(position: Vector2(80, 80));
      final InteractCommand command = InteractCommand(
        actor: cat,
        target: lever,
      );

      expect(command.status, CommandStatus.pending);
    });

    test('invalid target is rejected', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final _StubInteractable target = _StubInteractable(
        position: Vector2(80, 80),
        interactable: false,
      );
      final InteractCommand command = InteractCommand(
        actor: cat,
        target: target,
      );

      command.execute();

      expect(command.status, CommandStatus.cancelled);
      expect(target.used, isFalse);
    });

    test('out-of-range interaction is rejected', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(40, 40),
      );
      final LeverComponent lever = LeverComponent(position: Vector2(400, 400));
      final InteractCommand command = InteractCommand(
        actor: cat,
        target: lever,
      );

      command.execute();

      expect(command.status, CommandStatus.cancelled);
      expect(lever.isActive, isFalse);
    });

    test('valid interaction succeeds and the command completes', () {
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final LeverComponent lever = LeverComponent(position: Vector2(90, 80));
      final InteractCommand command = InteractCommand(
        actor: cat,
        target: lever,
      );

      command.execute();

      expect(lever.isActive, isTrue);
      expect(command.status, CommandStatus.completed);
    });

    test('animal without interact ability is rejected', () {
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final LeverComponent lever = LeverComponent(position: Vector2(80, 80));

      expect(dog.interactWith(lever), isFalse);
      expect(lever.isActive, isFalse);
    });
  });

  group('Lever', () {
    test('starts inactive, activates once, and ignores repeats', () {
      int activations = 0;
      final LeverComponent lever = LeverComponent(
        position: Vector2(80, 80),
        onActivated: () => activations++,
      );

      expect(lever.isActive, isFalse);
      lever.interact();
      expect(lever.isActive, isTrue);
      expect(activations, 1);

      lever.interact();
      expect(lever.isActive, isTrue);
      expect(activations, 1);
    });
  });

  group('Gate', () {
    test('starts closed and blocks movement until opened', () {
      final DuckComponent duck = DuckComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      );
      final Gate gate = Gate(position: Vector2(140, 60), size: Vector2(40, 40));
      duck.obstacles = <Gate>[gate];

      expect(gate.isOpen, isFalse);
      expect(duck.canOccupy(Vector2(150, 80)), isFalse);

      gate.open();

      expect(gate.isOpen, isTrue);
      expect(duck.canOccupy(Vector2(150, 80)), isTrue);
    });

    test('lever opens the gate', () {
      final Gate gate = Gate(position: Vector2(0, 0), size: Vector2(40, 40));
      final LeverComponent lever = LeverComponent(
        position: Vector2(80, 80),
        onActivated: gate.open,
      );

      expect(gate.isOpen, isFalse);
      lever.interact();
      expect(gate.isOpen, isTrue);
    });
  });

  group('Stage 5 objective', () {
    test('starts incomplete and ignores duck at the goal before the route', () {
      final MayhemWorld world = MayhemWorld();

      expect(world.controller.objective.status, ObjectiveStatus.active);
      expect(world.controller.objective.isComplete, isFalse);

      world.duck.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.controller.objective.isComplete, isFalse);
    });

    test(
      'completes after the lever opens the gate and the duck reaches the goal',
      () {
        const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);
        const Rect goal = Rect.fromLTWH(200, 40, 80, 80);
        final DuckComponent duck = DuckComponent(
          worldBounds: bounds,
          position: Vector2(40, 400),
        );
        final Gate gate = Gate(position: Vector2(0, 0), size: Vector2(40, 40));
        final LeverComponent lever = LeverComponent(
          position: Vector2(80, 80),
          onActivated: gate.open,
        );
        final CompositeObjective objective = CompositeObjective(
          description: 'Open the gate, Duck to the Goal',
          children: <GameObjective>[
            GateOpenObjective(gate: gate),
            AnimalAtLocationObjective(animal: duck, zone: goal),
          ],
        );

        lever.interact();
        duck.position.setValues(220, 60);
        objective.update();

        expect(gate.isOpen, isTrue);
        expect(objective.isComplete, isTrue);
      },
    );

    test('reset restores animals, commands, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.cat);
      world.controller.chooseCommand(CommandKind.interact);
      world.controller.handleInteractableTap(world.routeSwitch);
      world.cat.position.setValues(200, 200);
      world.duck.position.setValues(300, 300);
      world.dog.position.setValues(400, 400);
      world.frog.position.setValues(500, 500);
      world.routeSwitch.interact();
      world.controller.objective.update();

      expect(world.routeSwitch.route, RouteId.b);

      world.reset();

      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(world.cat.position.y, closeTo(MayhemWorld.catSpawn.y, 0.01));
      expect(world.duck.position.x, closeTo(MayhemWorld.duckSpawn.x, 0.01));
      expect(world.dog.position.x, closeTo(MayhemWorld.dogSpawn.x, 0.01));
      expect(world.frog.position.x, closeTo(MayhemWorld.frogSpawn.x, 0.01));
      expect(world.controller.objective.isComplete, isFalse);
      expect(world.controller.selectedAnimal, isNull);
      expect(world.controller.commandKind, isNull);
      expect(world.controller.commands.current, isNull);
    });

    test(
      'INTERACT is executable only when the cat is in range of the switch',
      () {
        final MayhemWorld world = MayhemWorld();
        world.controller.handleAnimalTap(world.cat);
        world.controller.chooseCommand(CommandKind.interact);
        world.controller.handleInteractableTap(world.routeSwitch);

        expect(world.controller.selectedTarget, isA<InteractableTarget>());
        expect(world.controller.canExecute, isFalse);

        world.cat.position.setFrom(MayhemWorld.switchPosition);
        expect(world.controller.canExecute, isTrue);
      },
    );
  });
}

class _StubInteractable implements Interactable {
  _StubInteractable({required Vector2 position, required this.interactable})
    : worldPosition = position;

  @override
  final Vector2 worldPosition;

  final bool interactable;
  bool used = false;

  @override
  double get interactionRange => 70;

  @override
  bool get canInteract => interactable;

  @override
  String get label => 'Stub';

  @override
  void interact() {
    used = true;
  }
}
