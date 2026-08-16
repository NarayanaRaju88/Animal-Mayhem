import '../command/command_kind.dart';
import 'ability_kind.dart';

/// Which abilities an animal may use. Commands are derived from this set.
final class AnimalAbilities {
  const AnimalAbilities(this.kinds);

  static const AnimalAbilities walk = AnimalAbilities(<AbilityKind>{
    AbilityKind.walk,
  });

  static const AnimalAbilities walkAndSwim = AnimalAbilities(<AbilityKind>{
    AbilityKind.walk,
    AbilityKind.swim,
  });

  static const AnimalAbilities walkerSwimmerJumper = AnimalAbilities(
    <AbilityKind>{AbilityKind.walk, AbilityKind.swim, AbilityKind.jump},
  );

  static const AnimalAbilities walkAndInteract = AnimalAbilities(<AbilityKind>{
    AbilityKind.walk,
    AbilityKind.interact,
  });

  final Set<AbilityKind> kinds;

  bool has(AbilityKind kind) => kinds.contains(kind);

  /// Commands the player may issue to this animal.
  List<CommandKind> get availableCommands {
    final List<CommandKind> commands = <CommandKind>[];
    if (has(AbilityKind.walk) || has(AbilityKind.swim)) {
      commands.add(CommandKind.move);
      commands.add(CommandKind.follow);
    }
    if (has(AbilityKind.jump)) {
      commands.add(CommandKind.jump);
    }
    if (has(AbilityKind.interact)) {
      commands.add(CommandKind.interact);
    }
    return commands;
  }
}
