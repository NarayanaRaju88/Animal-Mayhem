import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../components/animals/animal_component.dart';
import '../../systems/abilities/climb_capability.dart';
import '../../systems/interaction/resettable.dart';

/// Vertical route that animals with climb capability can travel.
class ClimbableSurfaceComponent extends PositionComponent
    with TapCallbacks
    implements Resettable {
  ClimbableSurfaceComponent({
    required Vector2 position,
    required Vector2 size,
    this.climbRange = 80,
    this.initiallyEnabled = true,
    this.requirement = const ClimbRequirement(),
    Vector2? bottomPosition,
    Vector2? topPosition,
    this.onTapped,
  }) : isEnabled = initiallyEnabled,
       _bottomOverride = bottomPosition?.clone(),
       _topOverride = topPosition?.clone(),
       super(position: position.clone(), size: size.clone(), priority: 3);

  final double climbRange;
  final bool initiallyEnabled;
  final ClimbRequirement requirement;
  final Vector2? _bottomOverride;
  final Vector2? _topOverride;
  bool isEnabled;
  void Function(ClimbableSurfaceComponent surface)? onTapped;

  String get label => 'Climbable';

  Vector2 get bottom =>
      _bottomOverride?.clone() ??
      Vector2(position.x + size.x / 2, position.y + size.y);

  Vector2 get top =>
      _topOverride?.clone() ?? Vector2(position.x + size.x / 2, position.y);

  Vector2 get worldPosition => bottom;

  bool allows(AnimalComponent animal) =>
      requirement.isSatisfiedBy(hasClimbAbility: animal.hasClimbAbility);

  bool canBeUsedBy(AnimalComponent animal) => isEnabled && allows(animal);

  @override
  void resetState() {
    isEnabled = initiallyEnabled;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = isEnabled ? const Color(0xFF6B4E31) : const Color(0xFF3A332C),
    );
    final Paint rung = Paint()
      ..color = const Color(0xFFD7C48A)
      ..strokeWidth = 3;
    for (double y = 12; y < size.y; y += 22) {
      canvas.drawLine(Offset(6, y), Offset(size.x - 6, y), rung);
    }
    final Paragraph paragraph = (ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    )..addText('CLIMB')).build()..layout(ParagraphConstraints(width: size.x));
    canvas.drawParagraph(paragraph, Offset(0, size.y / 2 - 6));
  }
}
