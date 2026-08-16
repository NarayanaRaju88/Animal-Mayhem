import 'dart:ui';

import 'package:animal_mayhem/game/components/animals/cat_component.dart';
import 'package:animal_mayhem/game/components/animals/dog_component.dart';
import 'package:animal_mayhem/game/components/animals/duck_component.dart';
import 'package:animal_mayhem/game/components/animals/frog_component.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/components/objects/obstacle_component.dart';
import 'package:animal_mayhem/game/components/objects/route_switch_component.dart';
import 'package:animal_mayhem/game/systems/command/command_status.dart';
import 'package:animal_mayhem/game/systems/command/interact_command.dart';
import 'package:animal_mayhem/game/systems/environment/environment_link.dart';
import 'package:animal_mayhem/game/systems/environment/route_state.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_kind.dart';
import 'package:animal_mayhem/game/systems/environment/terrain_map.dart';
import 'package:animal_mayhem/game/systems/objective/alternative_objective.dart';
import 'package:animal_mayhem/game/systems/objective/game_objective.dart';
import 'package:animal_mayhem/game/systems/objective/predicate_objective.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Rect bounds = Rect.fromLTWH(0, 0, 800, 600);

  group('Route switch', () {
    test('starts in Route A and toggles reversibly', () {
      final RouteSwitchComponent routeSwitch = RouteSwitchComponent(
        position: Vector2(80, 80),
      );

      expect(routeSwitch.route, RouteId.a);
      expect(routeSwitch.isActive, isTrue);

      routeSwitch.interact();
      expect(routeSwitch.route, RouteId.b);
      expect(routeSwitch.isActive, isFalse);

      routeSwitch.interact();
      expect(routeSwitch.route, RouteId.a);
      expect(routeSwitch.isActive, isTrue);
    });
  });

  group('Gates', () {
    test('route state opens one gate and closes the other', () {
      final RouteSwitchComponent routeSwitch = RouteSwitchComponent(
        position: Vector2(80, 80),
      );
      final Gate gateA = Gate(
        position: Vector2(0, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final Gate gateB = Gate(
        position: Vector2(80, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentLink linkA = EnvironmentLink(
        trigger: routeSwitch,
        responder: gateA,
      );
      final EnvironmentLink linkB = EnvironmentLink(
        trigger: InvertedTrigger(routeSwitch),
        responder: gateB,
      );

      linkA.sync(force: true);
      linkB.sync(force: true);
      expect(gateA.isOpen, isTrue);
      expect(gateB.isOpen, isFalse);

      routeSwitch.interact();
      linkA.sync();
      linkB.sync();
      expect(gateA.isOpen, isFalse);
      expect(gateB.isOpen, isTrue);

      routeSwitch.interact();
      linkA.sync();
      linkB.sync();
      expect(gateA.isOpen, isTrue);
      expect(gateB.isOpen, isFalse);
    });
  });

  group('Route A', () {
    test('duck can traverse required water and dog cannot', () {
      final TerrainMap terrain = TerrainMap(
        worldBounds: bounds,
        waterBounds: const Rect.fromLTWH(200, 0, 80, 600),
      );
      final DuckComponent duck = DuckComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
        terrain: terrain,
      );
      final DogComponent dog = DogComponent(
        worldBounds: bounds,
        position: Vector2(80, 200),
        terrain: terrain,
      );

      expect(duck.canOccupy(Vector2(240, 80)), isTrue);
      expect(dog.canOccupy(Vector2(240, 200)), isFalse);
      expect(terrain.kindAt(Vector2(240, 80)), TerrainKind.water);
    });
  });

  group('Route B', () {
    test('frog can jump the barrier and duck cannot', () {
      final JumpableBarrier barrier = JumpableBarrier(
        position: Vector2(160, 60),
        size: Vector2(80, 24),
      );
      final FrogComponent frog = FrogComponent(
        worldBounds: bounds,
        position: Vector2(80, 80),
      )..obstacles = <JumpableBarrier>[barrier];
      final DuckComponent duck = DuckComponent(
        worldBounds: bounds,
        position: Vector2(80, 200),
      )..obstacles = <JumpableBarrier>[barrier];

      expect(duck.canOccupy(Vector2(180, 70)), isFalse);
      expect(frog.startJump(Vector2(280, 80)), isTrue);
      expect(frog.isJumping, isTrue);
    });
  });

  group('Objective', () {
    test('accepts Route A or Route B, but not both required', () {
      bool routeA = false;
      bool routeB = false;
      final AlternativeObjective objective = AlternativeObjective(
        description: 'either',
        options: <GameObjective>[
          PredicateObjective(description: 'A', isSatisfied: () => routeA),
          PredicateObjective(description: 'B', isSatisfied: () => routeB),
        ],
      );

      objective.update();
      expect(objective.isComplete, isFalse);

      routeA = true;
      objective.update();
      expect(objective.isComplete, isTrue);
      expect(objective.options[1].isComplete, isFalse);

      objective.reset();
      routeA = false;
      routeB = true;
      objective.update();
      expect(objective.isComplete, isTrue);
      expect(objective.options[0].isComplete, isFalse);
    });

    test('Route A solution completes when its conditions are met', () {
      bool routeA = true;
      bool visitedWater = true;
      bool duckAtGoal = true;
      final AlternativeObjective objective = AlternativeObjective(
        description: 'either',
        options: <GameObjective>[
          PredicateObjective(
            description: 'A',
            isSatisfied: () => routeA && visitedWater && duckAtGoal,
          ),
          PredicateObjective(description: 'B', isSatisfied: () => false),
        ],
      );
      objective.update();
      expect(objective.isComplete, isTrue);
    });

    test('Route B solution completes when its conditions are met', () {
      final RouteSwitchComponent routeSwitch = RouteSwitchComponent(
        position: Vector2(80, 80),
      );
      final Gate gateA = Gate(
        position: Vector2(0, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final Gate gateB = Gate(
        position: Vector2(80, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentLink linkA = EnvironmentLink(
        trigger: routeSwitch,
        responder: gateA,
      );
      final EnvironmentLink linkB = EnvironmentLink(
        trigger: InvertedTrigger(routeSwitch),
        responder: gateB,
      );
      routeSwitch.interact();
      linkA.sync(force: true);
      linkB.sync(force: true);

      expect(routeSwitch.route, RouteId.b);
      expect(gateA.isOpen, isFalse);
      expect(gateB.isOpen, isTrue);

      final AlternativeObjective objective = AlternativeObjective(
        description: 'either',
        options: <GameObjective>[
          PredicateObjective(description: 'A', isSatisfied: () => false),
          PredicateObjective(
            description: 'B',
            isSatisfied: () => routeSwitch.route == RouteId.b && gateB.isOpen,
          ),
        ],
      );
      objective.update();
      expect(objective.isComplete, isTrue);
    });

    test('goal without the required route condition stays incomplete', () {
      final AlternativeObjective objective = AlternativeObjective(
        description: 'either',
        options: <GameObjective>[
          PredicateObjective(description: 'A', isSatisfied: () => false),
          PredicateObjective(description: 'B', isSatisfied: () => false),
        ],
      );
      objective.update();
      expect(objective.isComplete, isFalse);
    });
  });

  group('Reset', () {
    test('returns route A and connected gates to the initial pairing', () {
      final RouteSwitchComponent routeSwitch = RouteSwitchComponent(
        position: Vector2(80, 80),
      );
      final Gate gateA = Gate(
        position: Vector2(0, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final Gate gateB = Gate(
        position: Vector2(80, 0),
        size: Vector2(40, 40),
        followEnvironment: true,
      );
      final EnvironmentLink linkA = EnvironmentLink(
        trigger: routeSwitch,
        responder: gateA,
      );
      final EnvironmentLink linkB = EnvironmentLink(
        trigger: InvertedTrigger(routeSwitch),
        responder: gateB,
      );
      routeSwitch.interact();
      linkA.sync(force: true);
      linkB.sync(force: true);
      expect(routeSwitch.route, RouteId.b);

      routeSwitch.resetState();
      gateA.resetState();
      gateB.resetState();
      linkA.sync(force: true);
      linkB.sync(force: true);

      expect(routeSwitch.route, RouteId.a);
      expect(gateA.isOpen, isTrue);
      expect(gateB.isOpen, isFalse);
    });

    test('live world reset restores animals and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.cat.position.setValues(120, 120);
      world.buffalo.position.setValues(200, 200);
      world.controller.objective.update();
      world.reset();

      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
      expect(
        world.buffalo.position.x,
        closeTo(MayhemWorld.buffaloSpawn.x, 0.01),
      );
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  test('switch interaction is rejected out of range', () {
    final CatComponent cat = CatComponent(
      worldBounds: bounds,
      position: Vector2(40, 40),
    );
    final RouteSwitchComponent routeSwitch = RouteSwitchComponent(
      position: Vector2(400, 400),
    );
    final InteractCommand command = InteractCommand(
      actor: cat,
      target: routeSwitch,
    );

    command.execute();
    expect(command.status, CommandStatus.cancelled);
    expect(routeSwitch.route, RouteId.a);
  });
}
