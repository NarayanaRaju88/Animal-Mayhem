import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../components/animals/animal_component.dart';
import '../../systems/abilities/coil_capability.dart';
import '../../systems/environment/environment_link.dart';
import '../../systems/interaction/resettable.dart';

/// Anchor that a coil-capable animal can hold, keeping a linked mechanism active.
class CoilAnchorComponent extends PositionComponent
    with TapCallbacks
    implements Resettable, EnvironmentTrigger {
  CoilAnchorComponent({
    required Vector2 position,
    required Vector2 size,
    this.coilRange = 80,
    this.initiallyEnabled = true,
    this.requirement = const CoilRequirement(),
    this.onTapped,
  }) : isEnabled = initiallyEnabled,
       super(position: position.clone(), size: size.clone(), priority: 3);

  final double coilRange;
  final bool initiallyEnabled;
  final CoilRequirement requirement;
  bool isEnabled;
  bool isCoiled = false;
  void Function(CoilAnchorComponent anchor)? onTapped;

  String get label => isCoiled ? 'Held' : 'Coil';

  Vector2 get worldPosition =>
      Vector2(position.x + size.x / 2, position.y + size.y / 2);

  @override
  bool get isActive => isCoiled;

  bool allows(AnimalComponent animal) =>
      requirement.isSatisfiedBy(hasCoilAbility: animal.hasCoilAbility);

  bool canBeUsedBy(AnimalComponent animal) => isEnabled && allows(animal);

  /// Holds the anchor. Returns false if the animal cannot coil here.
  bool hold(AnimalComponent animal) {
    if (!canBeUsedBy(animal)) {
      return false;
    }
    isCoiled = true;
    return true;
  }

  @override
  void resetState() {
    isEnabled = initiallyEnabled;
    isCoiled = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapped?.call(this);
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()
        ..color = isCoiled ? const Color(0xFF2F6B3A) : const Color(0xFF3A4A38),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 4,
      Paint()
        ..color = isCoiled ? const Color(0xFF7BC47A) : const Color(0xFF8FA37A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    if (isCoiled) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 4,
        Paint()..color = const Color(0xFFD7C48A),
      );
    }
    final Paint coil = Paint()
      ..color = const Color(0xFFD7C48A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.18, coil);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.28, coil);
  }
}
