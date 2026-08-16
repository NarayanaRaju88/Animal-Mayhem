import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/animals/animal_component.dart';
import '../systems/behavior/animal_target.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/command/command_kind.dart';
import '../systems/command/command_runner.dart';
import '../systems/command/follow_command.dart';
import '../systems/command/jump_command.dart';
import '../systems/command/move_command.dart';
import '../systems/objective/game_objective.dart';

/// Player-facing session state. Flutter widgets observe this; they do not
/// move animals themselves.
class GameController extends ChangeNotifier {
  GameController({
    required this.animals,
    required this.spawns,
    required this.objective,
  });

  final List<AnimalComponent> animals;
  final Map<AnimalComponent, Vector2> spawns;
  final GameObjective objective;
  final CommandRunner commands = CommandRunner();

  AnimalComponent? selectedAnimal;
  CommandKind? commandKind;
  FollowTarget? selectedTarget;
  String targetDescription = 'None';

  void bindInput() {
    for (final AnimalComponent animal in animals) {
      animal.onTapped = handleAnimalTap;
    }
  }

  List<CommandKind> get availableCommands =>
      selectedAnimal?.availableCommands ?? const <CommandKind>[];

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
    if (!availableCommands.contains(kind)) {
      return;
    }
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
    if (!actor.availableCommands.contains(kind)) {
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
      case CommandKind.jump:
        commands.start(
          JumpCommand(actor: actor, destination: target.worldPosition),
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
    for (final AnimalComponent animal in animals) {
      final Vector2? spawn = spawns[animal];
      if (spawn != null) {
        animal.resetTo(spawn);
      }
    }
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
      objective.isComplete ? 'Complete' : objective.description;

  void _select(AnimalComponent animal) {
    for (final AnimalComponent candidate in animals) {
      candidate.isSelected = identical(candidate, animal);
    }
    selectedAnimal = animal;
    if (commandKind != null &&
        !animal.availableCommands.contains(commandKind)) {
      commandKind = null;
    }
    selectedTarget = null;
    targetDescription = 'None';
  }
}
