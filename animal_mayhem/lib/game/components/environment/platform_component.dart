import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/height_level.dart';

/// Simple elevated floor. Visual only; walls still block walking.
class PlatformComponent extends PositionComponent {
  PlatformComponent({
    required Vector2 position,
    required Vector2 size,
    this.level = HeightLevel.upper,
  }) : super(position: position.clone(), size: size.clone(), priority: 1);

  final HeightLevel level;

  static const Color fillColor = Color(0xFF4A5A48);
  static const Color edgeColor = Color(0xFFD7C48A);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    canvas.drawRect(
      size.toRect().deflate(3),
      Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 10, size.x, 10),
      Paint()..color = const Color(0xFF2E3A2E),
    );
  }
}
