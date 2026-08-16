import 'game_objective.dart';
import 'objective_status.dart';

/// Completes the first time [isSatisfied] returns true.
class PredicateObjective extends GameObjective {
  PredicateObjective({required this.description, required this.isSatisfied});

  final bool Function() isSatisfied;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if (isSatisfied()) {
      status = ObjectiveStatus.completed;
    }
  }
}
