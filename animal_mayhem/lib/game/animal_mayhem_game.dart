import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'world/mayhem_world.dart';

/// Root Flame game for Animal Mayhem.
///
/// Owns the camera and world lifecycle. Flutter screens only embed this type
/// through [GameWidget]; animal movement stays in the game layer.
class AnimalMayhemGame extends FlameGame<MayhemWorld> {
  AnimalMayhemGame() : super(world: MayhemWorld());

  /// Solid canvas clear color behind the development world.
  static const Color developmentBackground = Color(0xFF1B2A24);

  @override
  Color backgroundColor() => developmentBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(world.dog, snap: true);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, MayhemWorld.size.x, MayhemWorld.size.y),
      considerViewport: true,
    );
  }

  /// Restores the dog and camera to the development spawn.
  void reset() {
    world.reset();
    camera.viewfinder.position = world.dog.position.clone();
  }
}
