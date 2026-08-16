import 'package:animal_mayhem/game/systems/command/command_kind.dart';
import 'package:animal_mayhem/game/world/mayhem_world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'contextual HUD commands omit MOVE while capabilities still expose it',
    () {
      final MayhemWorld world = MayhemWorld();
      world.controller.handleAnimalTap(world.cat);

      expect(world.controller.availableCommands, contains(CommandKind.move));
      expect(
        world.controller.availableCommands,
        contains(CommandKind.interact),
      );
      expect(
        world.controller.contextualCommands,
        isNot(contains(CommandKind.move)),
      );
      expect(
        world.controller.contextualCommands,
        contains(CommandKind.interact),
      );

      world.controller.handleAnimalTap(world.buffalo);
      expect(world.controller.availableCommands, contains(CommandKind.move));
      expect(
        world.controller.contextualCommands,
        isNot(contains(CommandKind.move)),
      );
    },
  );
}
