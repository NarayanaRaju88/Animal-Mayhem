import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Temporary geometric snake. Replace this child later without touching movement.
class SnakeDevelopmentVisual extends PositionComponent {
  SnakeDevelopmentVisual({required Vector2 size})
    : super(size: size.clone(), anchor: Anchor.topLeft);

  static const Color bodyColor = Color(0xFF3F7A4A);
  static const Color bellyColor = Color(0xFFC5D48A);
  static const Color outlineColor = Color(0xFF1E3320);
  static const Color labelColor = Color(0xFFF7E7D4);

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final double bob = math.sin(_elapsed * 4.2) * 0.05;
    scale.setValues(1 + bob, 1);
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path body = Path()
      ..moveTo(4, size.y * 0.7)
      ..quadraticBezierTo(size.x * 0.25, 2, size.x * 0.5, size.y * 0.55)
      ..quadraticBezierTo(size.x * 0.75, size.y - 2, size.x - 4, size.y * 0.35);
    canvas.drawPath(
      body,
      bodyPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.y * 0.45
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      body,
      outlinePaint
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(size.x - 6, size.y * 0.32),
      5,
      Paint()..color = bellyColor,
    );

    final Paragraph paragraph =
        (ParagraphBuilder(
                ParagraphStyle(
                  textAlign: TextAlign.center,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              )
              ..pushStyle(TextStyle(color: labelColor, fontSize: 8))
              ..addText('SNAKE'))
            .build()
          ..layout(ParagraphConstraints(width: size.x));
    canvas.drawParagraph(paragraph, Offset(0, size.y * 0.35));
  }
}
