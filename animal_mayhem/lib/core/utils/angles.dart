import 'dart:math' as math;

/// Shortest-path interpolation between two angles in radians.
double lerpAngle(double from, double to, double t) {
  final double clampedT = t.clamp(0.0, 1.0);
  var delta = (to - from) % (2 * math.pi);
  if (delta > math.pi) {
    delta -= 2 * math.pi;
  } else if (delta < -math.pi) {
    delta += 2 * math.pi;
  }
  return from + delta * clampedT;
}
