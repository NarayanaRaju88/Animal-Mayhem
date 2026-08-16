import 'package:flame/components.dart';

import 'animal_command.dart';
import 'command_status.dart';

/// Move an animal toward a world position captured at execute time.
class MoveCommand extends AnimalCommand {
  MoveCommand({required super.actor, required Vector2 destination})
    : destination = destination.clone();

  final Vector2 destination;

  @override
  void onExecute() {
    actor.moveTo(destination);
  }

  @override
  void tick(double dt) {
    if (status != CommandStatus.executing) {
      return;
    }
    if (actor.target == null) {
      complete();
    }
  }
}
