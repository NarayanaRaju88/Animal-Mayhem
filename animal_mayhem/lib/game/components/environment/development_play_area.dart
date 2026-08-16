import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Development ground: grid, bounds, and tap-to-target input.
class DevelopmentPlayArea extends PositionComponent with TapCallbacks {
  DevelopmentPlayArea({required Vector2 worldSize, required this.onWorldTap})
    : super(size: worldSize.clone(), position: Vector2.zero());

  final void Function(Vector2 worldPosition) onWorldTap;

  static const Color fillColor = Color(0xFF3E5A46);
  static const Color gridColor = Color(0xFF334A3C);
  static const Color borderColor = Color(0xFFD7C4A3);

  static const double gridStep = 80;

  @override
  void onTapDown(TapDownEvent event) {
    onWorldTap(event.localPosition);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (double x = 0; x <= size.x; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = 0; y <= size.y; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }

    canvas.drawRect(
      size.toRect().deflate(2),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
