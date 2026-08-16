import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/environment_link.dart';
import '../../systems/interaction/resettable.dart';

/// Temporary crossing. Disabled it is ignored; enabled it is walkable land.
class BridgeComponent extends PositionComponent
    implements Resettable, EnvironmentResponder {
  BridgeComponent({required Vector2 position, required Vector2 size})
    : super(position: position.clone(), size: size.clone(), priority: 2);

  bool isEnabled = false;

  static const Color disabledColor = Color(0x665C4033);
  static const Color enabledColor = Color(0xFF8B5A2B);
  static const Color plankColor = Color(0xFFD7C48A);

  Rect get worldRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool containsWorldPoint(Vector2 point) {
    return worldRect.contains(Offset(point.x, point.y));
  }

  @override
  void applyEnvironmentState(bool active) {
    isEnabled = active;
  }

  @override
  void resetState() {
    isEnabled = false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = isEnabled ? enabledColor : disabledColor,
    );
    if (!isEnabled) {
      return;
    }
    final Paint plank = Paint()
      ..color = plankColor
      ..strokeWidth = 3;
    for (double y = 10; y < size.y; y += 18) {
      canvas.drawLine(Offset(8, y), Offset(size.x - 8, y), plank);
    }
  }
}
