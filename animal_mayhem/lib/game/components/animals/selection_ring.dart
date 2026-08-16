import 'dart:ui';

import 'package:flame/components.dart';

/// Highlight for the currently selected animal.
class SelectionRing extends PositionComponent {
  SelectionRing({required Vector2 ownerSize})
    : _ownerSize = ownerSize.clone(),
      super(
        size: ownerSize + Vector2.all(18),
        anchor: Anchor.center,
        position: ownerSize / 2,
        priority: 20,
      );

  final Vector2 _ownerSize;

  static const Color color = Color(0xFFF6E7A8);
  static const Color glow = Color(0x66F6E7A8);

  bool isActive = false;

  @override
  void update(double dt) {
    super.update(dt);
    final Component? owner = parent;
    if (owner is! PositionComponent) {
      return;
    }
    Vector2 visual = _ownerSize;
    for (final Component child in owner.children) {
      if (child is PositionComponent &&
          child.size.x * child.size.y > visual.x * visual.y) {
        visual = child.size;
      }
    }
    size.setValues(visual.x + 36, visual.y + 36);
    position.setFrom(_ownerSize / 2);
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) {
      return;
    }
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2 - 2,
      Paint()
        ..color = glow
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      size.x / 2 - 4,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
