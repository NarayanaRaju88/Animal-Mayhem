import 'dart:ui';

import 'package:flame/components.dart';

/// Solid or jumpable blocker for walking.
class ObstacleComponent extends PositionComponent {
  ObstacleComponent({
    required Vector2 position,
    required Vector2 size,
    required this.jumpable,
  }) : super(position: position.clone(), size: size.clone());

  final bool jumpable;

  Rect get worldRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool containsWorldPoint(Vector2 point) {
    return worldRect.contains(Offset(point.x, point.y));
  }
}

/// Barrier that cannot be jumped.
class NormalBarrier extends ObstacleComponent {
  NormalBarrier({required super.position, required super.size})
    : super(jumpable: false);

  static const Color fillColor = Color(0xFF5C4033);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 8),
      Paint()..color = const Color(0xFF7A5A48),
    );
    canvas.drawRect(
      size.toRect().deflate(2),
      Paint()
        ..color = const Color(0xFF2B1A14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}

/// Barrier that blocks walking but can be jumped over.
class JumpableBarrier extends ObstacleComponent {
  JumpableBarrier({required super.position, required super.size})
    : super(jumpable: true);

  static const Color fillColor = Color(0xFF8A6A3B);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    final Paint stripe = Paint()
      ..color = const Color(0xFFD7C48A)
      ..strokeWidth = 3;
    for (double x = 8; x < size.x; x += 18) {
      canvas.drawLine(Offset(x, 4), Offset(x - 10, size.y - 4), stripe);
    }
  }
}
