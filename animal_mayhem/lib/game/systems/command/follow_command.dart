import '../../systems/behavior/follow_target.dart';
import 'animal_command.dart';
import 'command_status.dart';

/// Keep an animal following a (possibly moving) target.
class FollowCommand extends AnimalCommand {
  FollowCommand({
    required super.actor,
    required this.target,
    required this.followDistance,
  });

  final FollowTarget target;
  final double followDistance;

  @override
  void onExecute() {
    actor.follow(target, stopDistance: followDistance);
  }

  @override
  void tick(double dt) {
    if (status != CommandStatus.executing) {
      return;
    }
    final double distance = (target.worldPosition - actor.position).length;
    if (distance <= followDistance) {
      complete();
    }
  }
}
