import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/animal_mayhem_game.dart';
import 'development_command_bar.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.gameScreenTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListenableBuilder(
            listenable: _game.controller,
            builder: (BuildContext context, Widget? _) {
              return DevelopmentCommandBar(
                controller: _game.controller,
                onReset: _game.reset,
              );
            },
          ),
          Expanded(child: GameWidget<AnimalMayhemGame>(game: _game)),
        ],
      ),
    );
  }
}
