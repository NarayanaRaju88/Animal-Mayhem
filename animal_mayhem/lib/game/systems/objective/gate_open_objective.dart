import '../../components/objects/gate.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes the first time [gate] is open, then latches until [reset].
///
/// Physical gate open/close is independent: a follow-environment gate may close
/// again without un-completing this objective.
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
