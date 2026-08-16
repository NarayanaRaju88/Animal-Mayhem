import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/session/game_controller.dart';
import '../../game/systems/command/command_kind.dart';

/// Development-only command panel. Contains no animal movement logic.
class DevelopmentCommandBar extends StatelessWidget {
  const DevelopmentCommandBar({
    super.key,
    required this.controller,
    required this.onReset,
  });

  static const Key moveButtonKey = Key('command_move_button');
  static const Key followButtonKey = Key('command_follow_button');
  static const Key jumpButtonKey = Key('command_jump_button');
  static const Key interactButtonKey = Key('command_interact_button');
  static const Key climbButtonKey = Key('command_climb_button');
  static const Key coilButtonKey = Key('command_coil_button');
  static const Key executeButtonKey = Key('command_execute_button');

  final GameController controller;
  final VoidCallback onReset;

  static Key _keyFor(CommandKind kind) {
    switch (kind) {
      case CommandKind.move:
        return moveButtonKey;
      case CommandKind.follow:
        return followButtonKey;
      case CommandKind.jump:
        return jumpButtonKey;
      case CommandKind.interact:
        return interactButtonKey;
      case CommandKind.climb:
        return climbButtonKey;
      case CommandKind.coil:
        return coilButtonKey;
    }
  }

  static String _labelFor(CommandKind kind) {
    switch (kind) {
      case CommandKind.move:
        return AppStrings.move;
      case CommandKind.follow:
        return AppStrings.follow;
      case CommandKind.jump:
        return AppStrings.jump;
      case CommandKind.interact:
        return AppStrings.interact;
      case CommandKind.climb:
        return AppStrings.climb;
      case CommandKind.coil:
        return AppStrings.coil;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<CommandKind> commands = controller.availableCommands;

    return Material(
      color: colors.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${AppStrings.objective}: ${controller.objectiveLabel}',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (controller.environmentLabel.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.environment}: ${controller.environmentLabel}',
                  style: textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${AppStrings.selected}: ${controller.selectedLabel}   '
                '${AppStrings.target}: ${controller.targetDescription}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (commands.isEmpty)
                Text(AppStrings.selectAnimalHint, style: textTheme.bodyMedium)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final CommandKind kind in commands)
                      SizedBox(
                        width: 110,
                        child: _CommandButton(
                          key: _keyFor(kind),
                          label: _labelFor(kind),
                          selected: controller.commandKind == kind,
                          onPressed: () => controller.chooseCommand(kind),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      key: executeButtonKey,
                      onPressed: controller.canExecute
                          ? controller.execute
                          : null,
                      child: const Text(AppStrings.execute),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    key: const Key('game_reset_button'),
                    onPressed: onReset,
                    child: const Text(AppStrings.reset),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = selected
        ? FilledButton.styleFrom(minimumSize: const Size(48, 48))
        : OutlinedButton.styleFrom(minimumSize: const Size(48, 48));

    if (selected) {
      return FilledButton(
        style: style,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlinedButton(
      style: style,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
