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

    test('Route A solution completes the live puzzle', () {
      final MayhemWorld world = MayhemWorld();
      world.duckProgress.visitedWater = true;
      world.duck.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.routeSwitch.route, RouteId.a);
      expect(world.controller.objective.isComplete, isTrue);
    });

    test('Route B solution completes the live puzzle', () {
      final MayhemWorld world = MayhemWorld();
      world.routeSwitch.interact();
      world.routeALink.sync();
      world.routeBLink.sync();
      world.frogProgress.usedJump = true;
      world.frog.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();

      expect(world.routeSwitch.route, RouteId.b);
      expect(world.gateA.isOpen, isFalse);
      expect(world.gateB.isOpen, isTrue);
      expect(world.controller.objective.isComplete, isTrue);
    });

    test('goal without the required route condition stays incomplete', () {
      final MayhemWorld world = MayhemWorld();
      world.frog.position.setFrom(
        Vector2(
          MayhemWorld.goalBounds.center.dx,
          MayhemWorld.goalBounds.center.dy,
        ),
      );
      world.controller.objective.update();
      expect(world.controller.objective.isComplete, isFalse);
    });
  });

  group('Reset', () {
    test('returns route A, gates, animals, switch, and objective', () {
      final MayhemWorld world = MayhemWorld();
      world.routeSwitch.interact();
      world.routeALink.sync();
      world.routeBLink.sync();
      world.duckProgress.visitedWater = true;
      world.frogProgress.usedJump = true;
      world.cat.position.setValues(120, 120);
      world.controller.objective.update();

      expect(world.routeSwitch.route, RouteId.b);
      expect(world.gateB.isOpen, isTrue);

      world.reset();

      expect(world.routeSwitch.route, RouteId.a);
      expect(world.gateA.isOpen, isTrue);
      expect(world.gateB.isOpen, isFalse);
      expect(world.duckProgress.visitedWater, isFalse);
      expect(world.frogProgress.usedJump, isFalse);
      expect(world.cat.position.x, closeTo(MayhemWorld.catSpawn.x, 0.01));
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
