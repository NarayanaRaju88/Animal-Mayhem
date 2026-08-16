import 'package:flame/components.dart';

import '../../components/animals/animal_state.dart';
import 'animal_command.dart';
import 'command_status.dart';

/// Jump toward a world position captured at execute time.
class JumpCommand extends AnimalCommand {
  JumpCommand({required super.actor, required Vector2 destination})
    : destination = destination.clone();

  final Vector2 destination;

  @override
  void onExecute() {
    final bool started = actor.startJump(destination);
    if (!started) {
      status = CommandStatus.cancelled;
    }
  }

  @override
  void tick(double dt) {
    if (status != CommandStatus.executing) {
      return;
    }
    if (!actor.isJumping && actor.state != AnimalState.landing) {
      complete();
    }
  }
}
