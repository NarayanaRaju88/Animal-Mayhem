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
    final String caption = level == HeightLevel.upper ? 'UPPER' : 'LOWER';
    final Paragraph paragraph =
        (ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.left,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )..addText(caption)).build()
          ..layout(ParagraphConstraints(width: size.x - 12));
    canvas.drawParagraph(paragraph, const Offset(8, 8));
  }
}
