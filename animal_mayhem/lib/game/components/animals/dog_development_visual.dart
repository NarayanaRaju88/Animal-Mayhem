import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric dog. Replace this child later without touching movement.
class DogDevelopmentVisual extends PositionComponent {
  DogDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFFC47A3A);
  static const Color earColor = Color(0xFF8A4B1F);
  static const Color markerColor = Color(0xFFF4E6D4);
  static const Color outlineColor = Color(0xFF3B2416);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 3) * 0.035;
    scale.setValues(1, 1 + bob);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint earPaint = Paint()..color = earColor;
    final Paint markerPaint = Paint()..color = markerColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final RRect body = RRect.fromLTRBR(
      4,
      8,
      size.x - 18,
      size.y - 6,
      const Radius.circular(10),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    final Offset headCenter = Offset(size.x - 16, size.y / 2);
    canvas.drawCircle(headCenter, 12, bodyPaint);
    canvas.drawCircle(headCenter, 12, outlinePaint);

    final Path ear = Path()
      ..moveTo(size.x - 24, 6)
      ..lineTo(size.x - 14, 14)
      ..lineTo(size.x - 28, 16)
      ..close();
    canvas.drawPath(ear, earPaint);

    final Path nose = Path()
      ..moveTo(size.x - 2, size.y / 2)
      ..lineTo(size.x - 12, size.y / 2 - 6)
      ..lineTo(size.x - 12, size.y / 2 + 6)
      ..close();
    canvas.drawPath(nose, markerPaint);
    canvas.drawPath(nose, outlinePaint);

    _drawLabel(canvas);
  }

  void _drawLabel(Canvas canvas) {
    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: markerColor, fontSize: 10))
          ..addText('DOG');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x - 20));
    canvas.drawParagraph(paragraph, const Offset(4, 12));
  }
}
