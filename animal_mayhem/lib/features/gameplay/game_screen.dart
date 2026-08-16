import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/animal_mayhem_game.dart';
import 'gameplay_hud.dart';

/// Flutter host for the Flame game.
///
/// Contains no animal movement logic. The canvas is provided by
/// [AnimalMayhemGame]. Overlay HUD stays compact so the world dominates.
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
      backgroundColor: const Color(0xFF102018),
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(AppStrings.gameScreenTitle),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GameWidget<AnimalMayhemGame>(game: _game),
          GameplayHud(controller: _game.controller, onReset: _game.reset),
        ],
      ),
    );
  }
}
