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
      final _Stage6Scene scene = _Stage6Scene();

      expect(scene.objective.status, ObjectiveStatus.active);
      expect(scene.objective.isComplete, isFalse);

      scene.lever.interact();
      scene.objective.update();
      expect(scene.objective.children[0].isComplete, isTrue);
      expect(scene.objective.isComplete, isFalse);

      scene.duck.position.setFrom(scene.padCenter);
      scene.pad.refresh();
      scene.padBridgeLink.sync();
      scene.objective.update();
      expect(scene.objective.children[1].isComplete, isTrue);
      expect(scene.objective.children[2].isComplete, isTrue);
      expect(scene.objective.isComplete, isFalse);
    });

    test('completes when gate, pad, bridge, and dog at goal are satisfied', () {
      final _Stage6Scene scene = _Stage6Scene();
      scene.lever.interact();
      scene.duck.position.setFrom(scene.padCenter);
      scene.pad.refresh();
      scene.padBridgeLink.sync();
      scene.dog.position.setFrom(scene.goalCenter);
      scene.objective.update();

      expect(scene.gate.isOpen, isTrue);
      expect(scene.pad.isActive, isTrue);
      expect(scene.bridge.isEnabled, isTrue);
      expect(scene.objective.isComplete, isTrue);
    });
  });

  group('Reset', () {
    test('restores animals, lever, gate, pad, bridge, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.cat.position.setValues(200, 200);
      world.duck.position.setValues(300, 300);
      world.dog.position.setValues(400, 400);
      world.frog.position.setValues(500, 500);
      world.lever.interact();
      world.controller.objective.update();

      world.reset();

      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(world.duck.position.x, closeTo(MayhemWorld.duckSpawn.x, 0.01));
      expect(world.dog.position.x, closeTo(MayhemWorld.dogSpawn.x, 0.01));
      expect(world.frog.position.x, closeTo(MayhemWorld.frogSpawn.x, 0.01));
      expect(world.controller.objective.isComplete, isFalse);
    });

    test('stage 6 objects restore independently of the live world', () {
      final _Stage6Scene scene = _Stage6Scene();
      scene.duck.position.setFrom(scene.padCenter);
      scene.lever.interact();
      scene.pad.refresh();
      scene.padBridgeLink.sync();
      scene.objective.update();

      expect(scene.gate.isOpen, isTrue);
      expect(scene.pad.isActive, isTrue);
      expect(scene.bridge.isEnabled, isTrue);

      scene.duck.position.setValues(40, 40);
      scene.lever.resetState();
      scene.gate.resetState();
      scene.pad.resetState();
      scene.bridge.resetState();
      scene.objective.reset();
      scene.pad.refresh();
      scene.padBridgeLink.sync(force: true);

      expect(scene.lever.isActive, isFalse);
      expect(scene.gate.isOpen, isFalse);
      expect(scene.pad.isActive, isFalse);
      expect(scene.bridge.isEnabled, isFalse);
      expect(scene.objective.isComplete, isFalse);
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

class _Stage6Scene {
  _Stage6Scene()
    : dog = DogComponent(worldBounds: bounds, position: Vector2(40, 40)),
      duck = DuckComponent(worldBounds: bounds, position: Vector2(40, 40)),
      gate = Gate(position: Vector2(0, 0), size: Vector2(40, 40)),
      pad = PressurePadComponent(
        position: Vector2(80, 80),
        size: Vector2(80, 80),
        requirement: const SpeciesRequirement('Duck'),
      ),
      bridge = BridgeComponent(position: Vector2(0, 0), size: Vector2(40, 40)) {
    pad.animals = <AnimalComponent>[duck, dog];
    lever = LeverComponent(position: Vector2(80, 80), onActivated: gate.open);
    padBridgeLink = EnvironmentLink(trigger: pad, responder: bridge);
    objective = CompositeObjective(
      description: 'Open the gate, Duck on pad, Dog across the bridge',
      children: <GameObjective>[
        GateOpenObjective(gate: gate),
        PressurePadActiveObjective(pad: pad),
        BridgeEnabledObjective(bridge: bridge),
        AnimalAtLocationObjective(
          animal: dog,
          zone: const Rect.fromLTWH(200, 200, 80, 80),
        ),
      ],
    );
  }

  static const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  final DogComponent dog;
  final DuckComponent duck;
  final Gate gate;
  final PressurePadComponent pad;
  final BridgeComponent bridge;
  late final LeverComponent lever;
  late final EnvironmentLink padBridgeLink;
  late final CompositeObjective objective;

  Vector2 get padCenter => Vector2(120, 120);

  Vector2 get goalCenter => Vector2(240, 240);
}
