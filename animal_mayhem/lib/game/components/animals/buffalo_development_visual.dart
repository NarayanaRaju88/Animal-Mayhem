import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric buffalo. Replace this child later without touching movement.
class BuffaloDevelopmentVisual extends PositionComponent {
  BuffaloDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFF4A3424);
  static const Color hornColor = Color(0xFFD9C7A2);
  static const Color outlineColor = Color(0xFF1C120C);
  static const Color labelColor = Color(0xFFF4E6D4);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 2.2) * 0.02;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint hornPaint = Paint()..color = hornColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect body = RRect.fromLTRBR(
      8,
      10,
      size.x - 8,
      size.y - 4,
      const Radius.circular(14),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    canvas.drawLine(const Offset(16, 14), const Offset(6, 2), hornPaint);
    canvas.drawLine(Offset(size.x - 16, 14), Offset(size.x - 6, 2), hornPaint);

    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: labelColor, fontSize: 10))
          ..addText('BUFFALO');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 8));
    canvas.drawParagraph(paragraph, const Offset(4, 22));
  }
}
