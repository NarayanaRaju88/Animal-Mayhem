import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Ground plane: grass, path, and tap-to-target input.
class DevelopmentPlayArea extends PositionComponent with TapCallbacks {
  DevelopmentPlayArea({required Vector2 worldSize, required this.onWorldTap})
    : super(size: worldSize.clone(), position: Vector2.zero());

  final void Function(Vector2 worldPosition) onWorldTap;

  static const Color fillColor = Color(0xFF3E5A46);
  static const Color darkGrass = Color(0xFF2F4A38);
  static const Color pathColor = Color(0xFF6A5A40);
  static const Color borderColor = Color(0xFFD7C4A3);

  @override
  void onTapDown(TapDownEvent event) {
    onWorldTap(event.localPosition);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y * 0.22),
      Paint()..color = darkGrass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.18,
          size.y * 0.42,
          size.x * 0.64,
          size.y * 0.38,
        ),
        const Radius.circular(80),
      ),
      Paint()..color = pathColor.withValues(alpha: 0.35),
    );
    final Paint tuft = Paint()..color = const Color(0x3322AA44);
    for (int i = 0; i < 18; i++) {
      final double x = (i * 97) % size.x;
      final double y = (i * 163) % size.y;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 48, height: 18),
        tuft,
      );
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
