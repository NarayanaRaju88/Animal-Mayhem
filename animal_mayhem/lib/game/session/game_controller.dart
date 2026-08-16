import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_strings.dart';
import '../components/animals/animal_component.dart';
import '../components/environment/climbable_surface_component.dart';
import '../components/objects/coil_anchor_component.dart';
import '../systems/behavior/animal_target.dart';
import '../systems/behavior/climbable_target.dart';
import '../systems/behavior/coilable_target.dart';
import '../systems/behavior/follow_target.dart';
import '../systems/behavior/interactable_target.dart';
import '../systems/command/attempt_failure.dart';
import '../systems/command/climb_command.dart';
import '../systems/command/coil_command.dart';
import '../systems/command/command_kind.dart';
import '../systems/command/command_runner.dart';
import '../systems/command/follow_command.dart';
import '../systems/command/interact_command.dart';
import '../systems/command/jump_command.dart';
import '../systems/command/move_command.dart';
import '../systems/environment/height_level.dart';
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
  String targetDescription = AppStrings.none;
  String? actionFeedback;
  bool _lastCanExecute = false;
  String _lastEnvironmentStatus = '';

  void bindInput() {
    for (final AnimalComponent animal in animals) {
      animal.onTapped = handleAnimalTap;
    }
  }

  /// Commands come from the selected animal's capabilities.
  List<CommandKind> get availableCommands {
    final AnimalComponent? animal = selectedAnimal;
    if (animal == null) {
      return const <CommandKind>[];
    }
    return animal.availableCommands;
  }

  void handleAnimalTap(AnimalComponent animal) {
    if (commandKind == CommandKind.follow &&
        selectedAnimal != null &&
        !identical(animal, selectedAnimal)) {
      selectedTarget = AnimalTarget(animal);
      targetDescription = animal.speciesName;
      actionFeedback = null;
    } else {
      _select(animal);
    }
    notifyListeners();
  }

  void handleWorldTap(Vector2 worldPosition) {
    if (selectedAnimal == null || commandKind == null) {
      return;
    }
    if (commandKind == CommandKind.interact ||
        commandKind == CommandKind.climb ||
        commandKind == CommandKind.coil) {
      actionFeedback = AppStrings.wrongTarget;
      notifyListeners();
      return;
    }
    selectedTarget = WorldPositionTarget(worldPosition);
    targetDescription = 'World';
    if (commandKind == CommandKind.jump) {
      actionFeedback = _messageFor(
        CommandKind.jump,
        selectedAnimal!.jumpFailure(worldPosition),
      );
    } else {
      actionFeedback = null;
    }
    notifyListeners();
  }

  void handleInteractableTap(Interactable interactable) {
    if (selectedAnimal == null) {
      return;
    }
    if (commandKind == null) {
      actionFeedback = AppStrings.selectCommandFirst;
      notifyListeners();
      return;
    }
    if (commandKind == CommandKind.interact) {
      selectedTarget = InteractableTarget(interactable);
      targetDescription = interactable.label;
      actionFeedback = _messageFor(
        CommandKind.interact,
        selectedAnimal!.interactFailure(interactable),
      );
    } else if (commandKind == CommandKind.follow) {
      return;
    } else if (commandKind == CommandKind.climb ||
        commandKind == CommandKind.coil) {
      actionFeedback = AppStrings.wrongTarget;
    } else {
      selectedTarget = WorldPositionTarget(interactable.worldPosition);
      targetDescription = 'World';
      actionFeedback = null;
    }
    notifyListeners();
  }

  void handleClimbableTap(ClimbableSurfaceComponent surface) {
    if (selectedAnimal == null) {
      return;
    }
    if (commandKind == null) {
      actionFeedback = AppStrings.selectCommandFirst;
      notifyListeners();
      return;
    }
    if (commandKind == CommandKind.climb) {
      selectedTarget = ClimbableTarget(surface);
      targetDescription = surface.label;
      actionFeedback = _messageFor(
        CommandKind.climb,
        selectedAnimal!.climbFailure(surface),
      );
    } else if (commandKind == CommandKind.move ||
        commandKind == CommandKind.jump) {
      selectedTarget = WorldPositionTarget(surface.worldPosition);
      targetDescription = 'World';
      actionFeedback = null;
    } else {
      actionFeedback = AppStrings.wrongTarget;
    }
    notifyListeners();
  }

  void handleCoilAnchorTap(CoilAnchorComponent anchor) {
    if (selectedAnimal == null) {
      return;
    }
    if (commandKind == null) {
      actionFeedback = AppStrings.selectCommandFirst;
      notifyListeners();
      return;
    }
    if (commandKind == CommandKind.coil) {
      selectedTarget = CoilableTarget(anchor);
      targetDescription = anchor.label;
      actionFeedback = _messageFor(
        CommandKind.coil,
        selectedAnimal!.coilFailure(anchor),
      );
    } else if (commandKind == CommandKind.move ||
        commandKind == CommandKind.jump) {
      selectedTarget = WorldPositionTarget(anchor.worldPosition);
      targetDescription = 'World';
      actionFeedback = null;
    } else {
      actionFeedback = AppStrings.wrongTarget;
    }
    notifyListeners();
  }

  void chooseCommand(CommandKind kind) {
    if (!availableCommands.contains(kind)) {
      return;
    }
    commandKind = kind;
    selectedTarget = null;
    targetDescription = AppStrings.none;
    actionFeedback = null;
    notifyListeners();
  }

  void execute() {
    final AnimalComponent? actor = selectedAnimal;
    final CommandKind? kind = commandKind;
    final FollowTarget? target = selectedTarget;
    if (actor == null || kind == null) {
      actionFeedback = AppStrings.actionUnavailable;
      notifyListeners();
      return;
    }
    if (!actor.availableCommands.contains(kind)) {
      actionFeedback = AppStrings.requiresDifferentCapability;
      notifyListeners();
      return;
    }
    if (target == null) {
      actionFeedback = AppStrings.actionUnavailable;
      notifyListeners();
      return;
    }

    switch (kind) {
      case CommandKind.move:
        commands.start(
          MoveCommand(actor: actor, destination: target.worldPosition),
        );
        actionFeedback = null;
      case CommandKind.follow:
        commands.start(
          FollowCommand(
            actor: actor,
            target: target,
            followDistance: actor.attributes.followDistance,
          ),
        );
        actionFeedback = null;
      case CommandKind.jump:
        final AttemptFailure jump = actor.jumpFailure(target.worldPosition);
        if (jump != AttemptFailure.none) {
          actionFeedback = _messageFor(kind, jump);
          notifyListeners();
          return;
        }
        commands.start(
          JumpCommand(actor: actor, destination: target.worldPosition),
        );
        actionFeedback = null;
      case CommandKind.interact:
        if (target is! InteractableTarget) {
          actionFeedback = AppStrings.wrongTarget;
          notifyListeners();
          return;
        }
        final AttemptFailure interact = actor.interactFailure(target.object);
        if (interact != AttemptFailure.none) {
          actionFeedback = _messageFor(kind, interact);
          notifyListeners();
          return;
        }
        commands.start(InteractCommand(actor: actor, target: target.object));
        actionFeedback = null;
      case CommandKind.climb:
        if (target is! ClimbableTarget) {
          actionFeedback = AppStrings.wrongTarget;
          notifyListeners();
          return;
        }
        final AttemptFailure climb = actor.climbFailure(target.surface);
        if (climb != AttemptFailure.none) {
          actionFeedback = _messageFor(kind, climb);
          notifyListeners();
          return;
        }
        commands.start(ClimbCommand(actor: actor, surface: target.surface));
        actionFeedback = null;
      case CommandKind.coil:
        if (target is! CoilableTarget) {
          actionFeedback = AppStrings.wrongTarget;
          notifyListeners();
          return;
        }
        final AttemptFailure coil = actor.coilFailure(target.anchor);
        if (coil != AttemptFailure.none) {
          actionFeedback = _messageFor(kind, coil);
          notifyListeners();
          return;
        }
        commands.start(CoilCommand(actor: actor, anchor: target.anchor));
        actionFeedback = null;
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
    targetDescription = AppStrings.none;
    actionFeedback = null;
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
    if (kind == CommandKind.climb) {
      if (target is! ClimbableTarget) {
        return false;
      }
      return actor.canAttemptClimb(target.surface);
    }
    if (kind == CommandKind.coil) {
      if (target is! CoilableTarget) {
        return false;
      }
      return actor.canAttemptCoil(target.anchor);
    }
    return true;
  }

  String get selectedLabel => selectedAnimal?.speciesName ?? AppStrings.none;

  String get commandDescription {
    switch (commandKind) {
      case CommandKind.move:
        return AppStrings.move;
      case CommandKind.follow:
        return AppStrings.follow;
      case CommandKind.jump:
        return AppStrings.jump;
      case CommandKind.interact:
        return AppStrings.interact;
      case CommandKind.climb:
        return AppStrings.climb;
      case CommandKind.coil:
        return AppStrings.coil;
      case null:
        return AppStrings.none;
    }
  }

  String get interactionHint {
    if (selectedAnimal == null) {
      return AppStrings.selectAnimalHint;
    }
    if (commandKind == null) {
      return AppStrings.selectCommandHint;
    }
    if (selectedTarget == null) {
      return AppStrings.selectTargetHint;
    }
    return '';
  }

  String get objectiveLabel =>
      objective.isComplete ? 'Complete' : objective.description;

  String get environmentLabel {
    final String reported = environmentStatus?.call() ?? '';
    final AnimalComponent? animal = selectedAnimal;
    if (animal == null) {
      return reported;
    }
    final String level = animal.heightLevel == HeightLevel.upper
        ? 'UPPER'
        : 'LOWER';
    if (reported.isEmpty) {
      return 'Level: $level';
    }
    return 'Level: $level  $reported';
  }

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
    targetDescription = AppStrings.none;
    actionFeedback = null;
  }

  String? _messageFor(CommandKind kind, AttemptFailure failure) {
    switch (failure) {
      case AttemptFailure.none:
        return null;
      case AttemptFailure.missingCapability:
        return AppStrings.requiresDifferentCapability;
      case AttemptFailure.busy:
        return AppStrings.actionUnavailable;
      case AttemptFailure.incompatible:
        if (kind == CommandKind.climb) {
          return AppStrings.cannotClimbHere;
        }
        if (kind == CommandKind.coil) {
          return AppStrings.cannotCoilHere;
        }
        return AppStrings.wrongTarget;
      case AttemptFailure.outOfRange:
        return AppStrings.outOfRange;
      case AttemptFailure.pathBlocked:
        return AppStrings.pathBlocked;
    }
  }
}
