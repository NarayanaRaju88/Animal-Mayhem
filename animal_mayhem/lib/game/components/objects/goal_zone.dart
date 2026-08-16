import 'dart:ui';

import 'package:flame/components.dart';

/// Goal region marked as an exit.
class GoalZone extends PositionComponent {
  GoalZone({required Rect bounds})
    : super(
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(bounds.width, bounds.height),
        priority: 2,
      );

  static const Color fillColor = Color(0x3348A56A);
  static const Color markColor = Color(0xFFE24B4B);

  Rect get worldRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool containsWorldPoint(Vector2 point) {
    return worldRect.contains(Offset(point.x, point.y));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(12)),
      Paint()..color = fillColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().deflate(6),
        const Radius.circular(10),
      ),
      Paint()
        ..color = const Color(0x88F4E27A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final Path flag = Path()
      ..moveTo(size.x / 2, 12)
      ..lineTo(size.x / 2, size.y - 10)
      ..moveTo(size.x / 2, 12)
      ..lineTo(size.x / 2 + 28, 24)
      ..lineTo(size.x / 2, 36);
    canvas.drawPath(
      flag,
      Paint()
        ..color = markColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }
}
