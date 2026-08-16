import 'dart:ui';

import 'package:flame/components.dart';

/// Development water band. Detection lives in [TerrainMap], not this visual.
class WaterRegion extends PositionComponent {
  WaterRegion({required Rect bounds})
    : super(
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(bounds.width, bounds.height),
      );

  static const Color fillColor = Color(0xFF2F6F8A);
  static const Color lineColor = Color(0xFF4E93AB);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    final Paint wavePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2;
    for (double y = 18; y < size.y; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), wavePaint);
    }
  }
}
