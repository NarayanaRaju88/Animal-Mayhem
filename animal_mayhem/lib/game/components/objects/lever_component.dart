import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../systems/interaction/interactable.dart';
import '../../systems/interaction/resettable.dart';

/// Development lever. Activating it notifies [onActivated].
class LeverComponent extends PositionComponent
    with TapCallbacks
    implements Interactable, Resettable {
  LeverComponent({
    required Vector2 position,
    this.onActivated,
    this.onTapped,
    this.interactionRange = 70,
  }) : super(
         position: position.clone(),
         size: Vector2(36, 52),
         anchor: Anchor.center,
         priority: 4,
       );

  void Function()? onActivated;
  void Function(LeverComponent lever)? onTapped;

  @override
  final double interactionRange;

  bool isActive = false;

  @override
  Vector2 get worldPosition => absoluteCenter;

  @override
  bool get canInteract => true;

  @override
  String get label => 'Lever';

  @override
  void interact() {
    if (isActive) {
      return;
    }
    isActive = true;
    onActivated?.call();
  }

  @override
  void resetState() {
    isActive = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    final Paint base = Paint()..color = const Color(0xFF4A4036);
    canvas.drawRRect(
      RRect.fromLTRBR(
        6,
        size.y - 16,
        size.x - 6,
        size.y,
        const Radius.circular(4),
      ),
      base,
    );
    final Paint stick = Paint()
      ..color = isActive ? const Color(0xFF3D8A4A) : const Color(0xFFB23A3A)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final Offset pivot = Offset(size.x / 2, size.y - 14);
    final Offset tip = isActive ? Offset(size.x - 6, 8) : const Offset(8, 8);
    canvas.drawLine(pivot, tip, stick);
  }
}
