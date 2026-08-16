import '../../components/objects/pressure_pad_component.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes once [pad] has been active.
class PressurePadActiveObjective extends GameObjective {
  PressurePadActiveObjective({
    required this.pad,
    this.description = 'Activate the pressure pad',
  });

  final PressurePadComponent pad;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if (pad.isActive) {
      status = ObjectiveStatus.completed;
    }
  }
}
