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

  static const Color developmentBackground = Color(0xFF173328);

  GameController get controller => world.controller;

  final Vector2 _focus = Vector2(1100, 1520);
  double _zoom = 0.85;

  @override
  Color backgroundColor() => developmentBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _configureCamera();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _configureCamera();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateCamera(dt);
  }

  /// Restores the level without restarting the application.
  void reset() {
    world.reset();
    _focus.setValues(1100, 1520);
    _configureCamera();
  }

  void _configureCamera() {
    camera.viewfinder.anchor = Anchor.center;
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, MayhemWorld.size.x, MayhemWorld.size.y),
      considerViewport: true,
    );
    final Vector2 view = camera.viewport.virtualSize;
    if (view.x <= 0 || view.y <= 0) {
      return;
    }
    _zoom = (view.x / 520).clamp(0.72, 1.45);
    camera.viewfinder.zoom = _zoom;
    camera.viewfinder.position = _focus.clone();
  }

  void _updateCamera(double dt) {
    final Vector2 view = camera.viewport.virtualSize;
    if (view.x <= 0 || view.y <= 0) {
      return;
    }
    final double targetZoom = (view.x / 520).clamp(0.72, 1.45);
    _zoom += (targetZoom - _zoom) * (dt * 3).clamp(0.0, 1.0);
    camera.viewfinder.zoom = _zoom;

    final Vector2 desired = _desiredFocus();
    final double t = (dt * 4.2).clamp(0.0, 1.0);
    _focus.x += (desired.x - _focus.x) * t;
    _focus.y += (desired.y - _focus.y) * t;
    camera.viewfinder.position = _focus.clone();
  }

  Vector2 _desiredFocus() {
    final selected = controller.selectedAnimal;
    if (selected == null) {
      return Vector2(1100, 1520);
    }
    final Vector2 focus = selected.position.clone();
    final target = controller.selectedTarget;
    if (target != null) {
      final Vector2 other = target.worldPosition;
      focus.setValues((focus.x + other.x) / 2, (focus.y + other.y) / 2);
    }
    // Keep the subject above the compact bottom HUD.
    focus.y += 70;
    return focus;
  }
}
