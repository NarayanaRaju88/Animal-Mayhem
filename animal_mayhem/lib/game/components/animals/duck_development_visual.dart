import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric duck. Replace this child later without touching movement.
class DuckDevelopmentVisual extends PositionComponent {
  DuckDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFFD8C25A);
  static const Color wingColor = Color(0xFFB89B32);
  static const Color beakColor = Color(0xFFE07A2F);
  static const Color outlineColor = Color(0xFF4A3B12);
  static const Color labelColor = Color(0xFFF7F1D4);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 2.4) * 0.04;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint wingPaint = Paint()..color = wingColor;
    final Paint beakPaint = Paint()..color = beakColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect body = RRect.fromLTRBR(
      6,
      10,
      size.x - 16,
      size.y - 6,
      const Radius.circular(14),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.42, size.y * 0.58),
        width: 18,
        height: 10,
      ),
      wingPaint,
    );

    final Offset headCenter = Offset(size.x - 16, size.y / 2 - 2);
    canvas.drawCircle(headCenter, 11, bodyPaint);
    canvas.drawCircle(headCenter, 11, outlinePaint);

    final Path beak = Path()
      ..moveTo(size.x - 2, size.y / 2)
      ..lineTo(size.x - 14, size.y / 2 - 5)
      ..lineTo(size.x - 14, size.y / 2 + 5)
      ..close();
    canvas.drawPath(beak, beakPaint);
    canvas.drawPath(beak, outlinePaint);

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
          ..addText('DUCK');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 18));
    canvas.drawParagraph(paragraph, const Offset(4, 12));
  }
}
