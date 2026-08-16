import 'dart:ui';

import 'package:flame/components.dart';

/// Development label for a route corridor.
class RouteLabelComponent extends PositionComponent {
  RouteLabelComponent({
    required Vector2 position,
    required this.text,
    required this.color,
  }) : super(position: position.clone(), size: Vector2(140, 28), priority: 3);

  final String text;
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      Paint()..color = color,
    );
    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: Color(0xFFF4F0E6), fontSize: 12))
          ..addText(text);
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x));
    canvas.drawParagraph(paragraph, const Offset(0, 6));
  }
}
