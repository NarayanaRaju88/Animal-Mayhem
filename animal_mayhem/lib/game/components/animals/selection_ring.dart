import 'dart:ui';

import 'package:flame/components.dart';

/// Highlight for the currently selected animal.
class SelectionRing extends PositionComponent {
  SelectionRing({required Vector2 ownerSize})
    : super(
        size: ownerSize + Vector2.all(18),
        anchor: Anchor.center,
        position: ownerSize / 2,
        priority: 20,
      );

  static const Color color = Color(0xFFF3E3B0);

  bool isActive = false;

  @override
  void render(Canvas canvas) {
    if (!isActive) {
      return;
    }
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 - 2, paint);
  }
}
