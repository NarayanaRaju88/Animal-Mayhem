import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../systems/environment/environment_link.dart';
import '../../systems/environment/route_state.dart';
import '../../systems/interaction/interactable.dart';
import '../../systems/interaction/resettable.dart';

/// Reversible two-route switch. [isActive] is true while Route A is selected.
class RouteSwitchComponent extends PositionComponent
    with TapCallbacks
    implements Interactable, Resettable, EnvironmentTrigger {
  RouteSwitchComponent({
    required Vector2 position,
    this.onTapped,
    this.interactionRange = 70,
  }) : super(
         position: position.clone(),
         size: Vector2(48, 48),
         anchor: Anchor.center,
         priority: 4,
       );

  void Function(RouteSwitchComponent routeSwitch)? onTapped;

  @override
  final double interactionRange;

  RouteId route = RouteId.a;

  @override
  bool get isActive => route == RouteId.a;

  @override
  Vector2 get worldPosition => absoluteCenter;

  @override
  bool get canInteract => true;

  @override
  String get label => 'Route Switch';

  @override
  void interact() {
    route = route == RouteId.a ? RouteId.b : RouteId.a;
  }

  @override
  void resetState() {
    route = RouteId.a;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      Paint()..color = const Color(0xFF3A3F4A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().deflate(4),
        const Radius.circular(6),
      ),
      Paint()
        ..color = route == RouteId.a
            ? const Color(0xFF2F6F8A)
            : const Color(0xFF8A6A3B),
    );
    final ParagraphBuilder builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          )
          ..pushStyle(TextStyle(color: Color(0xFFF4F0E6), fontSize: 14))
          ..addText(route == RouteId.a ? 'A' : 'B');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: size.x));
    canvas.drawParagraph(paragraph, const Offset(0, 14));
  }
}
