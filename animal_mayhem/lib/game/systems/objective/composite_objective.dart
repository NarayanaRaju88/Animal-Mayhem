import 'game_objective.dart';
import 'objective_status.dart';

/// Completes when every child objective is complete, then latches until [reset].
class CompositeObjective extends GameObjective {
  CompositeObjective({required this.children, required this.description});

  final List<GameObjective> children;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    for (final GameObjective child in children) {
      child.update();
    }
    if (children.every((GameObjective child) => child.isComplete)) {
      status = ObjectiveStatus.completed;
    }
  }

  @override
  void reset() {
    for (final GameObjective child in children) {
      child.reset();
    }
    super.reset();
  }
}
