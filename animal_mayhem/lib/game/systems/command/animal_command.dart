import '../../components/animals/animal_component.dart';
import 'command_status.dart';

/// One instruction for an animal.
///
/// Stage 3 runs a single command at a time. The type is queue-friendly later
/// without depending on a specific species.
abstract class AnimalCommand {
  AnimalCommand({required this.actor});

  final AnimalComponent actor;
  CommandStatus status = CommandStatus.pending;

  void execute() {
    if (status != CommandStatus.pending) {
      return;
    }
    status = CommandStatus.executing;
    onExecute();
  }

  void cancel() {
    if (status != CommandStatus.pending && status != CommandStatus.executing) {
      return;
    }
    status = CommandStatus.cancelled;
    actor.clearTarget();
  }

  void complete() {
    if (status != CommandStatus.executing) {
      return;
    }
    status = CommandStatus.completed;
  }

  /// Species-agnostic work when the command starts.
  void onExecute();

  /// Optional per-frame bookkeeping while [status] is executing.
  void tick(double dt) {}
}
