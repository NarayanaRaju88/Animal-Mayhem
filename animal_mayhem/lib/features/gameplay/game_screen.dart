import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/animal_mayhem_game.dart';

/// Flutter host for the Flame game.
///
/// Contains no animal movement logic. The canvas is provided by
/// [AnimalMayhemGame].
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const Key resetButtonKey = Key('game_reset_button');

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AnimalMayhemGame _game;

  @override
  void initState() {
    super.initState();
    _game = AnimalMayhemGame();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.gameScreenTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: colors.surfaceContainerHighest,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      AppStrings.dogTest,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton(
                      key: GameScreen.resetButtonKey,
                      onPressed: _game.reset,
                      child: const Text(AppStrings.reset),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: GameWidget<AnimalMayhemGame>(game: _game)),
        ],
      ),
    );
  }
}
