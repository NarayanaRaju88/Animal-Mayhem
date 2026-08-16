import 'dart:ui';

import 'package:flame/components.dart';

/// Development marker for the current movement target.
class TargetMarker extends PositionComponent {
  TargetMarker({required Vector2 position})
    : super(
        position: position.clone(),
        size: Vector2.all(22),
        anchor: Anchor.center,
      );

  static const Color color = Color(0xFFE8D5A3);

  @override
  void render(Canvas canvas) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, 8, paint);
    canvas.drawLine(Offset(center.dx, 2), Offset(center.dx, size.y - 2), paint);
    canvas.drawLine(Offset(2, center.dy), Offset(size.x - 2, center.dy), paint);
  }
}
