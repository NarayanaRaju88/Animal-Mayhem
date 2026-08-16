import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric cat. Replace this child later without touching movement.
class CatDevelopmentVisual extends PositionComponent {
  CatDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFFC47A3A);
  static const Color earColor = Color(0xFF8D4E24);
  static const Color outlineColor = Color(0xFF3B2416);
  static const Color labelColor = Color(0xFFF7E7D4);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 3.4) * 0.04;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint earPaint = Paint()..color = earColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect body = RRect.fromLTRBR(
      4,
      12,
      size.x - 4,
      size.y - 4,
      const Radius.circular(10),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    final Path leftEar = Path()
      ..moveTo(6, 14)
      ..lineTo(12, 2)
      ..lineTo(16, 14)
      ..close();
    final Path rightEar = Path()
      ..moveTo(size.x - 16, 14)
      ..lineTo(size.x - 12, 2)
      ..lineTo(size.x - 6, 14)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);
    canvas.drawPath(leftEar, outlinePaint);
    canvas.drawPath(rightEar, outlinePaint);

    _drawLabel(canvas);
  }

  void _drawLabel(Canvas canvas) {
    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: labelColor, fontSize: 9))
          ..addText('CAT');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 4));
    canvas.drawParagraph(paragraph, const Offset(2, 16));
  }
}
