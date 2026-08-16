import 'package:flame/components.dart';

/// Deterministic linear travel along a climbable surface.
class ClimbMotion {
  ClimbMotion({
    required Vector2 start,
    required Vector2 end,
    required this.duration,
  }) : start = start.clone(),
       end = end.clone();

  final Vector2 start;
  final Vector2 end;
  final double duration;
  double elapsed = 0;

  double get progress =>
      duration <= 0 ? 1 : (elapsed / duration).clamp(0.0, 1.0);

  bool get isComplete => elapsed >= duration;

  Vector2 get position => start + (end - start) * progress;

  void advance(double dt) {
    elapsed += dt;
  }
}
