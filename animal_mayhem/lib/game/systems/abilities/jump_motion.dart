import 'package:flame/components.dart';

/// Time-based parabolic jump from [start] to [end].
class JumpMotion {
  JumpMotion({
    required Vector2 start,
    required Vector2 end,
    required this.height,
    required this.duration,
  }) : start = start.clone(),
       end = end.clone();

  final Vector2 start;
  final Vector2 end;
  final double height;
  final double duration;

  double elapsed = 0;

  double get progress =>
      duration <= 0 ? 1 : (elapsed / duration).clamp(0.0, 1.0);

  bool get isComplete => elapsed >= duration;

  Vector2 get groundPosition => start + (end - start) * progress;

  /// World position including the upward arc (y increases downward).
  Vector2 get position {
    final double t = progress;
    final Vector2 ground = groundPosition;
    final double arc = 4 * height * t * (1 - t);
    return Vector2(ground.x, ground.y - arc);
  }

  void advance(double dt) {
    elapsed += dt;
  }
}
