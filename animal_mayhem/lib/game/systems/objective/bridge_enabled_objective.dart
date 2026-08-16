import '../../components/objects/bridge_component.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes once [bridge] is enabled, then latches until [reset].
class BridgeEnabledObjective extends GameObjective {
  BridgeEnabledObjective({
    required this.bridge,
    this.description = 'Enable the bridge',
  });

  final BridgeComponent bridge;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if (bridge.isEnabled) {
      status = ObjectiveStatus.completed;
    }
  }
}
