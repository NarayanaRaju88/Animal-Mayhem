import '../../systems/interaction/interactable.dart';
import 'animal_command.dart';
import 'command_status.dart';

/// Generic interaction with an [Interactable] object.
class InteractCommand extends AnimalCommand {
  InteractCommand({required super.actor, required this.target});

  final Interactable target;

  @override
  void onExecute() {
    if (!actor.interactWith(target)) {
      status = CommandStatus.cancelled;
      return;
    }
    complete();
  }
}
