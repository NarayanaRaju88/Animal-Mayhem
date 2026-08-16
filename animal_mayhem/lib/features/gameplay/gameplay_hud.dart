import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/components/animals/animal_art.dart';
import '../../game/components/animals/animal_component.dart';
import '../../game/session/game_controller.dart';
import '../../game/systems/command/command_kind.dart';
import '../../game/systems/objective/game_objective.dart';
import 'development_command_bar.dart';

/// Compact overlay HUD: game world stays full-bleed; commands are contextual.
class GameplayHud extends StatelessWidget {
  const GameplayHud({
    super.key,
    required this.controller,
    required this.onReset,
  });

  final GameController controller;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: 10,
              right: 10,
              top: 8,
              child: _TopHud(controller: controller, onReset: onReset),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: SafeArea(
                top: false,
                child: _BottomHud(controller: controller),
              ),
            ),
            if (controller.actionFeedback != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: 118,
                child: IgnorePointer(
                  child: _FeedbackToast(
                    key: DevelopmentCommandBar.feedbackKey,
                    text: controller.actionFeedback!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.controller, required this.onReset});

  final GameController controller;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xE61A2A24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x55E8D5A3)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppStrings.gameScreenTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFFF3E6C8),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ObjectiveStrip(controller: controller),
                  if (controller.interactionHint.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      controller.interactionHint,
                      style: const TextStyle(
                        color: Color(0xFFB7CDBE),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              key: const Key('game_reset_button'),
              tooltip: AppStrings.reset,
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              color: const Color(0xFFF3E6C8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveStrip extends StatelessWidget {
  const _ObjectiveStrip({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final List<GameObjective> steps = controller.objectiveSteps;
    if (steps.isEmpty) {
      return Text(
        controller.objectiveLabel,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: const Color(0xFFD7E8DC)),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: <Widget>[
        for (final GameObjective step in steps)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: step.isComplete
                  ? const Color(0xFF2E7D4F)
                  : const Color(0x3322AA66),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: step.isComplete
                    ? const Color(0xFF8FE0B0)
                    : const Color(0x55FFFFFF),
              ),
            ),
            child: Text(
              '${_compact(step.description)}${step.isComplete ? ' ✓' : ''}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: step.isComplete
                    ? const Color(0xFFE8FFF0)
                    : const Color(0xFFE6F0E8),
              ),
            ),
          ),
      ],
    );
  }

  static String _compact(String description) {
    switch (description) {
      case 'Activate the lever':
        return 'LEVER';
      case 'Open the wide gate':
        return 'WIDE GATE';
      case 'Clear the crate':
        return 'CRATE';
      case 'Hold the heavy pad':
        return 'HEAVY PAD';
      case 'Coil the anchor':
        return 'COIL';
      case 'Hold the coil gate':
        return 'COIL GATE';
      case 'Climb to the upper platform':
        return 'GOAL';
      default:
        return description.toUpperCase();
    }
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final List<CommandKind> contextual = controller.contextualCommands;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (contextual.isNotEmpty || controller.canExecute)
          _ActionRow(controller: controller),
        const SizedBox(height: 8),
        _AnimalSelector(controller: controller),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final List<CommandKind> commands = controller.contextualCommands;
    return Row(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final CommandKind kind in commands)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CommandChip(
                      kind: kind,
                      selected: controller.commandKind == kind,
                      onTap: () => controller.chooseCommand(kind),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (controller.canExecute) ...<Widget>[
          const SizedBox(width: 8),
          _ExecuteButton(onPressed: controller.execute),
        ],
      ],
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final CommandKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF3D8B5A) : const Color(0xEE1E332A),
      shape: const StadiumBorder(),
      elevation: selected ? 4 : 1,
      child: InkWell(
        key: DevelopmentCommandBar.commandKey(kind),
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(_iconFor(kind), size: 20, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  DevelopmentCommandBar.commandLabel(kind),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(CommandKind kind) {
    switch (kind) {
      case CommandKind.move:
        return Icons.near_me_rounded;
      case CommandKind.follow:
        return Icons.group_rounded;
      case CommandKind.jump:
        return Icons.arrow_upward_rounded;
      case CommandKind.interact:
        return Icons.touch_app_rounded;
      case CommandKind.climb:
        return Icons.terrain_rounded;
      case CommandKind.coil:
        return Icons.sync_rounded;
    }
  }
}

class _ExecuteButton extends StatelessWidget {
  const _ExecuteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD4A017),
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        key: DevelopmentCommandBar.executeButtonKey,
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.play_arrow_rounded, color: Color(0xFF1A1204)),
                SizedBox(width: 4),
                Text(
                  'GO',
                  style: TextStyle(
                    color: Color(0xFF1A1204),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalSelector extends StatelessWidget {
  const _AnimalSelector({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE61A2A24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55E8D5A3)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.animals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final AnimalComponent animal = controller.animals[index];
          final bool selected = identical(animal, controller.selectedAnimal);
          return _AnimalPortrait(
            animal: animal,
            selected: selected,
            onTap: () => controller.handleAnimalTap(animal),
          );
        },
      ),
    );
  }
}

class _AnimalPortrait extends StatelessWidget {
  const _AnimalPortrait({
    required this.animal,
    required this.selected,
    required this.onTap,
  });

  final AnimalComponent animal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AnimalArtKind kind = AnimalArt.kindForSpecies(animal.speciesName);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Select ${animal.speciesName}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            width: selected ? 72 : 62,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF3D8B5A)
                  : const Color(0xFF24382F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFF3E6C8)
                    : const Color(0x3344AA66),
                width: selected ? 2.4 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CustomPaint(
                      painter: AnimalPortraitPainter(kind),
                      size: const Size(48, 40),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    animal.speciesName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : const Color(0xFFD7E8DC),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimalPortraitPainter extends CustomPainter {
  AnimalPortraitPainter(this.kind);

  final AnimalArtKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    AnimalArt.paint(canvas, size, kind: kind);
  }

  @override
  bool shouldRepaint(covariant AnimalPortraitPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _FeedbackToast extends StatelessWidget {
  const _FeedbackToast({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEE1A1208),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x88E8C56A)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF8EED8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
