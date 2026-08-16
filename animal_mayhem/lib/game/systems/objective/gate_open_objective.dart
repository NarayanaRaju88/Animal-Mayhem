import '../../components/objects/gate.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes when [gate] is open.
class GateOpenObjective extends GameObjective {
  GateOpenObjective({required this.gate, this.description = 'Open the gate'});

  final Gate gate;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if (gate.isOpen) {
      status = ObjectiveStatus.completed;
    }
  }
}
