import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/animals/animal_component.dart';
import '../systems/behavior/animal_target.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/behavior/interactable_target.dart';
import '../systems/command/command_kind.dart';
import '../systems/command/command_runner.dart';
import '../systems/command/follow_command.dart';
import '../systems/command/interact_command.dart';
import '../systems/command/jump_command.dart';
import '../systems/command/move_command.dart';
import '../systems/interaction/interactable.dart';
import '../systems/interaction/resettable.dart';
import '../systems/objective/game_objective.dart';

/// Player-facing session state. Flutter widgets observe this; they do not
/// move animals themselves.
class GameController extends ChangeNotifier {
  GameController({
    required this.animals,
    required this.spawns,
    required this.objective,
    List<Resettable>? resettables,
    this.environmentStatus,
  }) : resettables = resettables ?? <Resettable>[];

  final List<AnimalComponent> animals;
  final Map<AnimalComponent, Vector2> spawns;
  final GameObjective objective;
  final List<Resettable> resettables;
  final String Function()? environmentStatus;
  final CommandRunner commands = CommandRunner();

  AnimalComponent? selectedAnimal;
  CommandKind? commandKind;
  FollowTarget? selectedTarget;
  String targetDescription = 'None';
  bool _lastCanExecute = false;
  String _lastEnvironmentStatus = '';

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
    if (commandKind == CommandKind.interact) {
      return;
    }
    selectedTarget = WorldPositionTarget(worldPosition);
    targetDescription = 'World';
    notifyListeners();
  }

  void handleInteractableTap(Interactable interactable) {
    if (selectedAnimal == null || commandKind == null) {
      return;
    }
    if (commandKind == CommandKind.interact) {
      selectedTarget = InteractableTarget(interactable);
      targetDescription = interactable.label;
    } else if (commandKind == CommandKind.follow) {
      return;
    } else {
      selectedTarget = WorldPositionTarget(interactable.worldPosition);
      targetDescription = 'World';
    }
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
    if (!canExecute) {
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
      case CommandKind.interact:
        if (target is InteractableTarget) {
          commands.start(InteractCommand(actor: actor, target: target.object));
        }
    }
    notifyListeners();
  }

  void tick(double dt) {
    commands.tick(dt);
    final bool wasComplete = objective.isComplete;
    objective.update();
    final bool executeNow = canExecute;
    final String environmentNow = environmentLabel;
    if (objective.isComplete != wasComplete ||
        executeNow != _lastCanExecute ||
        environmentNow != _lastEnvironmentStatus) {
      _lastCanExecute = executeNow;
      _lastEnvironmentStatus = environmentNow;
      notifyListeners();
    } else {
      _lastCanExecute = executeNow;
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
    for (final Resettable object in resettables) {
      object.resetState();
    }
    objective.reset();
    selectedAnimal = null;
    commandKind = null;
    selectedTarget = null;
    targetDescription = 'None';
    _lastCanExecute = false;
    _lastEnvironmentStatus = '';
    notifyListeners();
  }

  bool get canExecute {
    final AnimalComponent? actor = selectedAnimal;
    final CommandKind? kind = commandKind;
    final FollowTarget? target = selectedTarget;
    if (actor == null || kind == null || target == null) {
      return false;
    }
    if (kind == CommandKind.interact) {
      if (target is! InteractableTarget) {
        return false;
      }
      return actor.canAttemptInteraction(target.object);
    }
    return true;
  }

  String get selectedLabel => selectedAnimal?.speciesName ?? 'None';

  String get objectiveLabel =>
      objective.isComplete ? 'Complete' : objective.description;

  String get environmentLabel => environmentStatus?.call() ?? '';

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
