import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Safe landing marker in water. Gameplay treats it as a jump target.
class LilyPadComponent extends PositionComponent with TapCallbacks {
  LilyPadComponent({
    required Vector2 position,
    this.onTapped,
    double radius = 34,
  }) : super(
         position: position.clone(),
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
         priority: 4,
       );

  void Function(Vector2 worldPosition)? onTapped;

  static const Color fillColor = Color(0xFF3F8F4A);
  static const Color rimColor = Color(0xFF2E6A36);

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(absoluteCenter);
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, size.x / 2, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      size.x / 2 - 3,
      Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
