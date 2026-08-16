import '../../components/animals/animal_state.dart';
import '../../components/environment/climbable_surface_component.dart';
import 'animal_command.dart';
import 'command_status.dart';

/// Climb a configured surface. Completes when the actor finishes the climb.
class ClimbCommand extends AnimalCommand {
  ClimbCommand({required super.actor, required this.surface});

  final ClimbableSurfaceComponent surface;

  @override
  void onExecute() {
    final bool started = actor.startClimb(surface);
    if (!started) {
      status = CommandStatus.cancelled;
    }
  }

  @override
  void tick(double dt) {
    if (status != CommandStatus.executing) {
      return;
    }
    if (!actor.isClimbing && actor.state != AnimalState.landing) {
      complete();
    }
  }
}
