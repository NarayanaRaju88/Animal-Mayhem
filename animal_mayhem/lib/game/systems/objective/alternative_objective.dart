import 'game_objective.dart';
import 'objective_status.dart';

/// Completes when any child option is complete.
class AlternativeObjective extends GameObjective {
  AlternativeObjective({required this.options, required this.description});

  final List<GameObjective> options;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    for (final GameObjective option in options) {
      option.update();
    }
    if (options.any((GameObjective option) => option.isComplete)) {
      status = ObjectiveStatus.completed;
    }
  }

  @override
  void reset() {
    for (final GameObjective option in options) {
      option.reset();
    }
    super.reset();
  }
}
