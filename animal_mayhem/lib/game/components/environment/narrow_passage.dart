import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/physical_profile.dart';

/// Corridor that only animals whose profile fits [requiredClearance] may enter.
class NarrowPassage extends PositionComponent {
  NarrowPassage({
    required Vector2 position,
    required Vector2 size,
    required this.requiredClearance,
  }) : super(position: position.clone(), size: size.clone(), priority: 1);

  final double requiredClearance;

  static const Color fillColor = Color(0xFF2A332C);

  Rect get worldRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool containsWorldPoint(Vector2 point) {
    return worldRect.contains(Offset(point.x, point.y));
  }

  bool allows(PhysicalProfile profile) {
    return profile.canFitClearance(requiredClearance);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
  }
}
