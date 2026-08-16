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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 16),
      Paint()..color = const Color(0x664E93AB),
    );
    final Paint wavePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (double y = 18; y < size.y; y += 28) {
      final Path wave = Path()..moveTo(0, y);
      for (double x = 0; x <= size.x; x += 24) {
        wave.quadraticBezierTo(x + 12, y - 6, x + 24, y);
      }
      canvas.drawPath(wave, wavePaint);
    }
  }
}
