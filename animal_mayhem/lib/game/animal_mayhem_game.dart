import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'session/game_controller.dart';
import 'world/mayhem_world.dart';

/// Root Flame game for Animal Mayhem.
///
/// Owns the camera and world lifecycle. Flutter screens only embed this type
/// through [GameWidget]; animal movement stays in the game layer.
class AnimalMayhemGame extends FlameGame<MayhemWorld> {
  AnimalMayhemGame() : super(world: MayhemWorld());

  /// Solid canvas clear color behind the development world.
  static const Color developmentBackground = Color(0xFF1B2A24);

  GameController get controller => world.controller;

  @override
  Color backgroundColor() => developmentBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _fitCamera();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _fitCamera();
    }
  }

  /// Restores the level without restarting the application.
  void reset() {
    world.reset();
    _fitCamera();
  }

  void _fitCamera() {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = MayhemWorld.size / 2;
    final Vector2 view = camera.viewport.virtualSize;
    if (view.x <= 0 || view.y <= 0) {
      return;
    }
    final double zoomX = view.x / MayhemWorld.size.x;
    final double zoomY = view.y / MayhemWorld.size.y;
    camera.viewfinder.zoom = (zoomX < zoomY ? zoomX : zoomY) * 0.96;
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, MayhemWorld.size.x, MayhemWorld.size.y),
      considerViewport: true,
    );
  }
}
