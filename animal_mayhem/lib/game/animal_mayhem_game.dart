import 'dart:ui';

import 'package:flame/game.dart';

/// Root Flame game for Animal Mayhem.
///
/// This class is the attachment point for future game systems. Keep Flutter
/// widgets out of this type: UI screens host [GameWidget], while animals,
/// physics, commands, and levels will live under `game/`.
///
/// Animals will share a common contract (attributes, movement, behavior,
/// abilities, interactions, and state) so new species can be added without
/// rewriting the engine. No animals or gameplay systems are registered yet.
class AnimalMayhemGame extends FlameGame {
  /// Solid development canvas color. Replaced when environments land.
  static const Color developmentBackground = Color(0xFF1B2A24);

  @override
  Color backgroundColor() => developmentBackground;
}
