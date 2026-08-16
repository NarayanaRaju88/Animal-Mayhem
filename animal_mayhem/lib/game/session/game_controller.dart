import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/animals/animal_component.dart';
import '../components/animals/dog_component.dart';
import '../components/animals/duck_component.dart';
import '../systems/behavior/animal_target.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/command/command_kind.dart';
import '../systems/command/command_runner.dart';
import '../systems/command/follow_command.dart';
import '../systems/command/move_command.dart';
import '../systems/objective/bring_animals_together_objective.dart';
import '../systems/objective/game_objective.dart';

/// Player-facing session state. Flutter widgets observe this; they do not
/// move animals themselves.
class GameController extends ChangeNotifier {
  GameController({
    required this.dog,
    required this.duck,
    required this.dogSpawn,
    required this.duckSpawn,
  });

  final DogComponent dog;
  final DuckComponent duck;
  final Vector2 dogSpawn;
  final Vector2 duckSpawn;
  final CommandRunner commands = CommandRunner();

  late final GameObjective objective = BringAnimalsTogetherObjective(
    first: dog,
    second: duck,
    distance: dog.attributes.followDistance + 16,
  );

  AnimalComponent? selectedAnimal;
  CommandKind? commandKind;
  FollowTarget? selectedTarget;
  String targetDescription = 'None';

  void bindInput() {
    dog.onTapped = handleAnimalTap;
    duck.onTapped = handleAnimalTap;
  }

  void handleAnimalTap(AnimalComponent animal) {
    if (commandKind == CommandKind.follow &&
        selectedAnimal != null &&
        !identical(animal, selectedAnimal)) {
      selectedTarget = AnimalTarget(animal);
      targetDescription = animal.speciesName;
    } else {
      _select(animal);
    }
    notifyListeners();
  }

  void handleWorldTap(Vector2 worldPosition) {
    if (selectedAnimal == null || commandKind == null) {
      return;
    }
    selectedTarget = WorldPositionTarget(worldPosition);
    targetDescription = 'World';
    notifyListeners();
  }

  void chooseCommand(CommandKind kind) {
    commandKind = kind;
    selectedTarget = null;
    targetDescription = 'None';
    notifyListeners();
  }

  void execute() {
    final AnimalComponent? actor = selectedAnimal;
    final CommandKind? kind = commandKind;
    final FollowTarget? target = selectedTarget;
    if (actor == null || kind == null || target == null) {
      return;
    }

    switch (kind) {
      case CommandKind.move:
        commands.start(
          MoveCommand(actor: actor, destination: target.worldPosition),
        );
      case CommandKind.follow:
        commands.start(
          FollowCommand(
            actor: actor,
            target: target,
            followDistance: actor.attributes.followDistance,
          ),
        );
    }
    notifyListeners();
  }

  void tick(double dt) {
    commands.tick(dt);
    final bool wasComplete = objective.isComplete;
    objective.update();
    if (objective.isComplete != wasComplete) {
      notifyListeners();
    }
  }

  void reset() {
    commands.reset();
    dog.resetTo(dogSpawn);
    duck.resetTo(duckSpawn);
    objective.reset();
    selectedAnimal = null;
    commandKind = null;
    selectedTarget = null;
    targetDescription = 'None';
    notifyListeners();
  }

  bool get canExecute =>
      selectedAnimal != null && commandKind != null && selectedTarget != null;

  String get selectedLabel => selectedAnimal?.speciesName ?? 'None';

  String get objectiveLabel =>
      objective.isComplete ? 'Complete' : 'Bring the Dog to the Duck';

  void _select(AnimalComponent animal) {
    for (final AnimalComponent candidate in <AnimalComponent>[dog, duck]) {
      candidate.isSelected = identical(candidate, animal);
    }
    selectedAnimal = animal;
    selectedTarget = null;
    targetDescription = 'None';
  }
}
