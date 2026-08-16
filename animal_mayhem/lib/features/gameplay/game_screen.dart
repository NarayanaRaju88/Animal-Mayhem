import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../game/animal_mayhem_game.dart';

/// Flutter host for the Flame game.
///
/// Contains no game logic. The canvas is provided by [AnimalMayhemGame].
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
      body: GameWidget<AnimalMayhemGame>(game: _game),
    );
  }
}
