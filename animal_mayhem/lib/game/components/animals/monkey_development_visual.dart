import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric monkey. Replace this child later without touching movement.
class MonkeyDevelopmentVisual extends PositionComponent {
  MonkeyDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFF8D5A2B);
  static const Color faceColor = Color(0xFFE2C08D);
  static const Color outlineColor = Color(0xFF3B2416);
  static const Color labelColor = Color(0xFFF7E7D4);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 3.8) * 0.05;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint facePaint = Paint()..color = faceColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path tail = Path()
      ..moveTo(size.x - 6, size.y * 0.55)
      ..quadraticBezierTo(size.x + 10, size.y * 0.2, size.x - 4, 4);
    canvas.drawPath(
      tail,
      Paint()
        ..color = bodyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final RRect body = RRect.fromLTRBR(
      6,
      10,
      size.x - 8,
      size.y - 4,
      const Radius.circular(12),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    canvas.drawOval(Rect.fromLTWH(10, 8, size.x - 22, 16), facePaint);

    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: labelColor, fontSize: 8))
          ..addText('MONKEY');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 4));
    canvas.drawParagraph(paragraph, const Offset(2, 18));
  }
}
