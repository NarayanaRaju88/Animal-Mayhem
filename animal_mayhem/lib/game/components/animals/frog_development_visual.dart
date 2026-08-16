import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric frog. Replace this child later without touching movement.
class FrogDevelopmentVisual extends PositionComponent {
  FrogDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFF4C9A4A);
  static const Color bellyColor = Color(0xFFB7D36A);
  static const Color outlineColor = Color(0xFF1F4A22);
  static const Color labelColor = Color(0xFFF4F7E8);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 4) * 0.045;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint bellyPaint = Paint()..color = bellyColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect body = RRect.fromLTRBR(
      6,
      10,
      size.x - 6,
      size.y - 6,
      const Radius.circular(16),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.62),
        width: size.x * 0.42,
        height: size.y * 0.28,
      ),
      bellyPaint,
    );

    canvas.drawCircle(Offset(14, 12), 7, bodyPaint);
    canvas.drawCircle(Offset(size.x - 14, 12), 7, bodyPaint);
    canvas.drawCircle(Offset(14, 12), 7, outlinePaint);
    canvas.drawCircle(Offset(size.x - 14, 12), 7, outlinePaint);

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
          ..addText('FROG');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 8));
    canvas.drawParagraph(paragraph, const Offset(4, 16));
  }
}
