import 'animal_command.dart';
import 'command_status.dart';

/// Runs one command at a time. A later queue can sit in front of this runner.
class CommandRunner {
  AnimalCommand? current;

  void start(AnimalCommand command) {
    current?.cancel();
    current = command;
    command.execute();
  }

  void tick(double dt) {
    final AnimalCommand? command = current;
    if (command == null || command.status != CommandStatus.executing) {
      return;
    }
    command.tick(dt);
  }

  void reset() {
    current?.cancel();
    current = null;
  }
}
