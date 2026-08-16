import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/animal_component.dart';
import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/objects/bridge_component.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/components/objects/lever_component.dart';
import 'package:animal_mayhem/game/components/objects/pressure_pad_component.dart';
import 'package:animal_mayhem/game/systems/environment/environment_link.dart';
import 'package:animal_mayhem/game/systems/environment/occupancy_requirement.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_map.dart';
import 'package:animal_mayhem/game/systems/objective/animal_at_location_objective.dart';
import 'package:animal_mayhem/game/systems/objective/bridge_enabled_objective.dart';
import 'package:animal_mayhem/game/systems/objective/composite_objective.dart';
import 'package:animal_mayhem/game/systems/objective/game_objective.dart';
import 'package:animal_mayhem/game/systems/objective/gate_open_objective.dart';
import 'package:animal_mayhem/game/systems/objective/objective_status.dart';
import 'package:animal_mayhem/game/systems/objective/pressure_pad_active_objective.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  group('Pressure pad', () {
    test('starts inactive and follows the required occupant', () {
      final DuckComponent duck = DuckComponent(
        worldBounds: bounds,
        position: Vector2(40, 40),
      );
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(200, 200),
      );
      final PressurePadComponent pad = PressurePadComponent(
        position: Vector2(80, 80),
        size: Vector2(80, 80),
        requirement: const SpeciesRequirement('Duck'),
      )..animals = <AnimalComponent>[duck, dog];

      expect(pad.isActive, isFalse);

      duck.position.setValues(120, 120);
      pad.refresh();
      expect(pad.isActive, isTrue);

      duck.position.setValues(40, 40);
      pad.refresh();
      expect(pad.isActive, isFalse);
    });

    test('wrong animal does not activate it', () {
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(120, 120),
      );
      final CatComponent cat = CatComponent(
        worldBounds: bounds,
        position: Vector2(120, 120),
      );
      final PressurePadComponent pad = PressurePadComponent(
        position: Vector2(80, 80),
        size: Vector2(80, 80),
        requirement: const SpeciesRequirement('Duck'),
      )..animals = <AnimalComponent>[dog, cat];

      pad.refresh();
      expect(pad.isActive, isFalse);
    });
  });

  group('Bridge', () {
    test('starts disabled and cannot be crossed until enabled', () {
      final TerrainMap terrain = TerrainMap(
        worldBounds: bounds,
        waterBounds: const Rect.fromLTWH(200, 0, 80, 600),
      );
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
        terrain: terrain,
      );
      final BridgeComponent bridge = BridgeComponent(
        position: Vector2(200, 40),
        size: Vector2(80, 80),
      );
      dog.bridges = <BridgeComponent>[bridge];

      expect(bridge.isEnabled, isFalse);
      expect(dog.canOccupy(Vector2(240, 80)), isFalse);

      bridge.applyEnvironmentState(true);

      expect(bridge.isEnabled, isTrue);
      expect(dog.canOccupy(Vector2(240, 80)), isTrue);
    });
  });

  group('Gate', () {
    test('lever still opens a latching gate', () {
      final Gate gate = Gate(position: Vector2(0, 0), size: Vector2(40, 40));
      final LeverComponent lever = LeverComponent(
        position: Vector2(80, 80),
        onActivated: gate.open,
      );

      lever.interact();
      expect(gate.isOpen, isTrue);
      gate.applyEnvironmentState(false);
      expect(gate.isOpen, isTrue);
    });

    test('environmental state can open and close a following gate', () {
      final Gate gate = Gate(
        position: Vector2(0, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentSignal signal = EnvironmentSignal(id: 'gate');
      final EnvironmentLink link = EnvironmentLink(
        trigger: signal,
        responder: gate,
      );

      link.sync(force: true);
      expect(gate.isOpen, isFalse);

      signal.setActive(true);
      link.sync();
      expect(gate.isOpen, isTrue);

      signal.setActive(false);
      link.sync();
      expect(gate.isOpen, isFalse);
    });
  });

  group('Environment link', () {
    test('trigger activates and restores the responder', () {
      final EnvironmentSignal signal = EnvironmentSignal();
      final BridgeComponent bridge = BridgeComponent(
        position: Vector2(0, 0),
        size: Vector2(40, 40),
      );
      final EnvironmentLink link = EnvironmentLink(
        trigger: signal,
        responder: bridge,
      );

      link.sync(force: true);
      expect(bridge.isEnabled, isFalse);

      signal.setActive(true);
      link.sync();
      expect(bridge.isEnabled, isTrue);

      signal.setActive(false);
      link.sync();
      expect(bridge.isEnabled, isFalse);
    });
  });

  group('Stage 6 objective', () {
    test('starts incomplete and does not complete prematurely', () {
      final MayhemWorld world = MayhemWorld();
      final CompositeObjective objective =
          world.controller.objective as CompositeObjective;

      expect(objective.status, ObjectiveStatus.active);
      expect(objective.isComplete, isFalse);

      world.lever.interact();
      objective.update();
      expect(objective.children[0].isComplete, isTrue);
      expect(objective.isComplete, isFalse);

      world.duck.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.pad.refresh();
      world.padBridgeLink.sync();
      objective.update();
      expect(objective.children[1].isComplete, isTrue);
      expect(objective.children[2].isComplete, isTrue);
      expect(objective.isComplete, isFalse);
    });

    test('completes when gate, pad, bridge, and dog at goal are satisfied', () {
      final MayhemWorld world = MayhemWorld();
      world.lever.interact();
      world.duck.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.pad.refresh();
      world.padBridgeLink.sync();
      world.dog.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.gate.isOpen, isTrue);
      expect(world.pad.isActive, isTrue);
      expect(world.bridge.isEnabled, isTrue);
      expect(world.controller.objective.isComplete, isTrue);
    });
  });

  group('Reset', () {
    test('restores animals, lever, gate, pad, bridge, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.cat.position.setValues(200, 200);
      world.duck.position.setFrom(
        MayhemWorld.padPosition + MayhemWorld.padSize / 2,
      );
      world.dog.position.setValues(400, 400);
      world.frog.position.setValues(500, 500);
      world.lever.interact();
      world.pad.refresh();
      world.padBridgeLink.sync();
      world.controller.objective.update();

      expect(world.gate.isOpen, isTrue);
      expect(world.pad.isActive, isTrue);
      expect(world.bridge.isEnabled, isTrue);

      world.reset();

      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(world.duck.position.x, closeTo(MayhemWorld.duckSpawn.x, 0.01));
      expect(world.dog.position.x, closeTo(MayhemWorld.dogSpawn.x, 0.01));
      expect(world.frog.position.x, closeTo(MayhemWorld.frogSpawn.x, 0.01));
      expect(world.lever.isActive, isFalse);
      expect(world.gate.isOpen, isFalse);
      expect(world.pad.isActive, isFalse);
      expect(world.bridge.isEnabled, isFalse);
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  test('composite chain objective types can be constructed', () {
    final Gate gate = Gate(position: Vector2.zero(), size: Vector2(10, 10));
    final PressurePadComponent pad = PressurePadComponent(
      position: Vector2.zero(),
      size: Vector2(10, 10),
      requirement: const SpeciesRequirement('Duck'),
    );
    final BridgeComponent bridge = BridgeComponent(
      position: Vector2.zero(),
      size: Vector2(10, 10),
    );
    final DogComponent dog = DogComponent(
      worldBounds: bounds,
      position: Vector2(20, 20),
    );

    final CompositeObjective objective = CompositeObjective(
      description: 'chain',
      children: <GameObjective>[
        GateOpenObjective(gate: gate),
        PressurePadActiveObjective(pad: pad),
        BridgeEnabledObjective(bridge: bridge),
        AnimalAtLocationObjective(
          animal: dog,
          zone: const Rect.fromLTWH(0, 0, 40, 40),
        ),
      ],
    );

    objective.update();
    expect(objective.isComplete, isFalse);
  });
}
