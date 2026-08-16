import '../../components/objects/coil_anchor_component.dart';
import 'animal_command.dart';
import 'command_status.dart';

/// Coil around a configured anchor. Completes immediately on success.
class CoilCommand extends AnimalCommand {
  CoilCommand({required super.actor, required this.anchor});

  final CoilAnchorComponent anchor;

  @override
  void onExecute() {
    if (!actor.startCoil(anchor)) {
      status = CommandStatus.cancelled;
      return;
    }
    complete();
  }
}
