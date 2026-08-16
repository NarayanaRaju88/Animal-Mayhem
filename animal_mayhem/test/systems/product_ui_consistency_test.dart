import 'dart:io';

import 'package:animal_mayhem/app/app.dart';
import 'package:animal_mayhem/core/constants/app_strings.dart';
import 'package:animal_mayhem/features/gameplay/development_command_bar.dart';
import 'package:animal_mayhem/features/home/home_screen.dart';
import 'package:animal_mayhem/game/components/environment/climbable_surface_component.dart';
import 'package:animal_mayhem/game/components/objects/coil_anchor_component.dart';
import 'package:animal_mayhem/game/components/objects/gate.dart';
import 'package:animal_mayhem/game/systems/behavior/follow_target.dart';
import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product', () {
    test('visible product name is Animal Mayhem', () {
      expect(AppStrings.appName, 'Animal Mayhem');
      expect(AppStrings.gameScreenTitle, 'Animal Mayhem');
    });

    test('home tagline describes a 10-stage gameplay prototype', () {
      expect(
        AppStrings.homeTagline.toLowerCase(),
        isNot(contains('later stages')),
      );
      expect(
        AppStrings.homeTagline.toLowerCase(),
        isNot(contains('gameplay arrives')),
      );
      expect(
        AppStrings.homeTagline.toLowerCase(),
        isNot(contains('coming later')),
      );
      expect(
        AppStrings.homeTagline.toLowerCase(),
        isNot(contains('10 complete levels')),
      );
      expect(AppStrings.homeTagline.toLowerCase(), contains('prototype'));
    });

    test('Android launcher label is Animal Mayhem', () {
      final String manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(manifest, contains('android:label="Animal Mayhem"'));
      expect(manifest, isNot(contains('android:label="animal_mayhem"')));
    });

    test('iOS display name is Animal Mayhem', () {
      final String plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('<string>Animal Mayhem</string>'));
    });
  });

  group('Command UI', () {
    test('selecting an animal exposes capability-driven commands', () {
      final MayhemWorld world = MayhemWorld();

      world.controller.handleAnimalTap(world.dog);
      expect(world.controller.availableCommands, contains(CommandKind.move));
      expect(world.controller.availableCommands, contains(CommandKind.follow));
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.climb)),
      );
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.coil)),
      );
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.interact)),
      );

      world.controller.handleAnimalTap(world.cat);
      expect(
        world.controller.availableCommands,
        contains(CommandKind.interact),
      );
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.climb)),
      );

      world.controller.handleAnimalTap(world.monkey);
      expect(world.controller.availableCommands, contains(CommandKind.climb));
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.coil)),
      );

      world.controller.handleAnimalTap(world.snake);
      expect(world.controller.availableCommands, contains(CommandKind.coil));
      expect(
        world.controller.availableCommands,
        isNot(contains(CommandKind.climb)),
      );
    });

    test(
      'target-based commands identify a valid target after command then tap',
      () {
        final MayhemWorld world = MayhemWorld();
        world.monkey.position.setFrom(world.climbable.bottom);

        world.controller.handleAnimalTap(world.monkey);
        world.controller.chooseCommand(CommandKind.climb);
        expect(world.controller.selectedTarget, isNull);

        world.controller.handleClimbableTap(world.climbable);
        expect(world.controller.selectedTarget, isNotNull);
        expect(world.controller.canExecute, isTrue);
        expect(world.controller.actionFeedback, isNull);
      },
    );

    test('invalid targets do not execute the command', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.selectedTarget = WorldPositionTarget(Vector2(200, 200));
      world.controller.execute();

      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.snake.hasCompletedCoil, isFalse);
      expect(world.controller.actionFeedback, AppStrings.wrongTarget);
    });

    test(
      'tapping a specialized object without a command asks for a command',
      () {
        final MayhemWorld world = MayhemWorld();
        world.controller.handleAnimalTap(world.monkey);
        world.controller.handleClimbableTap(world.climbable);

        expect(world.controller.selectedTarget, isNull);
        expect(world.controller.actionFeedback, AppStrings.selectCommandFirst);
      },
    );
  });

  group('Feedback', () {
    test('out-of-range action produces feedback', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.cat);
      world.controller.chooseCommand(CommandKind.interact);
      world.controller.handleInteractableTap(world.lever);

      expect(world.controller.canExecute, isFalse);
      expect(world.controller.actionFeedback, AppStrings.outOfRange);
      expect(world.lever.isActive, isFalse);
    });

    test('blocked climb produces feedback', () {
      final ClimbableSurfaceComponent climbable = ClimbableSurfaceComponent(
        position: Vector2(100, 40),
        size: Vector2(40, 200),
      );
      final Gate gate = Gate(position: Vector2(90, 100), size: Vector2(60, 40));
      final MayhemWorld world = MayhemWorld();
      world.monkey.position.setFrom(climbable.bottom);
      world.monkey.obstacles = <Gate>[gate];

      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.handleClimbableTap(climbable);

      expect(world.monkey.isClimbing, isFalse);
      expect(world.controller.actionFeedback, AppStrings.pathBlocked);
      expect(world.controller.canExecute, isFalse);
    });

    test('invalid climbable produces cannot-climb feedback', () {
      final ClimbableSurfaceComponent disabled = ClimbableSurfaceComponent(
        position: Vector2(100, 40),
        size: Vector2(40, 200),
        initiallyEnabled: false,
      );
      final MayhemWorld world = MayhemWorld();
      world.monkey.position.setFrom(disabled.bottom);

      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.handleClimbableTap(disabled);

      expect(world.controller.actionFeedback, AppStrings.cannotClimbHere);
      expect(world.monkey.isClimbing, isFalse);
    });

    test('invalid coil anchor produces cannot-coil feedback', () {
      final CoilAnchorComponent disabled = CoilAnchorComponent(
        position: Vector2(100, 80),
        size: Vector2(60, 60),
        initiallyEnabled: false,
      );
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(disabled.worldPosition);

      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.handleCoilAnchorTap(disabled);

      expect(world.controller.actionFeedback, AppStrings.cannotCoilHere);
      expect(disabled.isCoiled, isFalse);
    });

    test('wrong target produces feedback', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.handleCoilAnchorTap(world.coilAnchor);

      expect(world.controller.actionFeedback, AppStrings.wrongTarget);
      expect(world.controller.selectedTarget, isNull);
    });

    test('unavailable execute produces feedback', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.execute();

      expect(world.controller.actionFeedback, AppStrings.actionUnavailable);
      expect(world.monkey.isClimbing, isFalse);
    });

    test('feedback does not spam continuously', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);

      expect(world.controller.actionFeedback, isNull);
      world.controller.tick(1 / 60);
      world.controller.tick(1 / 60);
      expect(world.controller.actionFeedback, isNull);

      world.controller.handleWorldTap(Vector2(10, 10));
      expect(world.controller.actionFeedback, AppStrings.wrongTarget);
      world.controller.tick(1 / 60);
      world.controller.tick(1 / 60);
      expect(world.controller.actionFeedback, AppStrings.wrongTarget);
    });
  });

  group('Regression', () {
    test('Cat INTERACT still requires a valid in-range target', () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.cat);
      world.controller.chooseCommand(CommandKind.interact);
      world.controller.handleInteractableTap(world.lever);
      expect(world.controller.canExecute, isFalse);

      world.cat.position.setFrom(MayhemWorld.leverPosition);
      world.controller.handleInteractableTap(world.lever);
      expect(world.controller.canExecute, isTrue);

      world.controller.execute();
      expect(world.lever.isActive, isTrue);
    });

    test('Monkey CLIMB still runs after command then valid target', () {
      final MayhemWorld world = MayhemWorld();
      world.monkey.position.setFrom(world.climbable.bottom);
      world.controller.handleAnimalTap(world.monkey);
      world.controller.chooseCommand(CommandKind.climb);
      world.controller.handleClimbableTap(world.climbable);
      world.controller.execute();

      expect(world.monkey.isClimbing, isTrue);
    });

    test('Snake COIL still holds a valid anchor', () {
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.handleCoilAnchorTap(world.coilAnchor);
      world.controller.execute();

      expect(world.coilAnchor.isCoiled, isTrue);
      expect(world.snake.hasCompletedCoil, isTrue);
    });

    test('Buffalo force profile is unchanged', () {
      final MayhemWorld world = MayhemWorld();
      expect(world.buffalo.force.canActivateHeavyPad, isTrue);
      expect(world.buffalo.force.canPushHeavy, isTrue);
    });

    test('reset still restores selection and coil state', () {
      final MayhemWorld world = MayhemWorld();
      world.snake.position.setFrom(world.coilAnchor.worldPosition);
      world.controller.handleAnimalTap(world.snake);
      world.controller.chooseCommand(CommandKind.coil);
      world.controller.handleCoilAnchorTap(world.coilAnchor);
      world.controller.execute();
      expect(world.coilAnchor.isCoiled, isTrue);

      world.reset();

      expect(world.controller.selectedAnimal, isNull);
      expect(world.controller.commandKind, isNull);
      expect(world.controller.actionFeedback, isNull);
      expect(world.coilAnchor.isCoiled, isFalse);
      expect(world.snake.hasCompletedCoil, isFalse);
    });
  });

  testWidgets(
    'home screen shows Animal Mayhem without stale later-stage copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AnimalMayhemApp());

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.homeTagline), findsOneWidget);
      expect(find.textContaining('Gameplay arrives'), findsNothing);
      expect(find.textContaining('later stages'), findsNothing);
    },
  );

  testWidgets('command bar surfaces action feedback', (
    WidgetTester tester,
  ) async {
    final MayhemWorld world = MayhemWorld();
    world.controller.handleAnimalTap(world.monkey);
    world.controller.chooseCommand(CommandKind.climb);
    world.controller.handleWorldTap(Vector2(4, 4));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DevelopmentCommandBar(
            controller: world.controller,
            onReset: world.reset,
          ),
        ),
      ),
    );

    expect(find.byKey(DevelopmentCommandBar.feedbackKey), findsOneWidget);
    expect(find.text(AppStrings.wrongTarget), findsOneWidget);
    expect(find.textContaining(AppStrings.climb), findsWidgets);
  });
}
