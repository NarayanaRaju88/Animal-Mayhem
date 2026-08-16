import 'dart:ui';

import 'package:flame/components.dart';

import '../../components/animals/animal_component.dart';
import '../../systems/environment/environment_link.dart';
import '../../systems/environment/occupancy_requirement.dart';
import '../../systems/interaction/resettable.dart';

/// Occupancy plate that becomes active while a matching animal stands on it.
class PressurePadComponent extends PositionComponent
    implements Resettable, EnvironmentTrigger {
  PressurePadComponent({
    required Vector2 position,
    required Vector2 size,
    required this.requirement,
  }) : super(position: position.clone(), size: size.clone(), priority: 2);

  final OccupancyRequirement requirement;
  List<AnimalComponent> animals = <AnimalComponent>[];

  bool _active = false;

  @override
  bool get isActive => _active;

  static const Color inactiveColor = Color(0xFF5A5348);
  static const Color activeColor = Color(0xFF3D8A4A);
  static const Color plateColor = Color(0xFF2E2A24);

  Rect get worldRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  bool containsWorldPoint(Vector2 point) {
    return worldRect.contains(Offset(point.x, point.y));
  }

  void refresh() {
    _active = animals.any(
      (AnimalComponent animal) =>
          requirement.isSatisfiedBy(animal) &&
          containsWorldPoint(animal.position),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    refresh();
  }

  @override
  void resetState() {
    _active = false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10)),
      Paint()..color = plateColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().deflate(8),
        const Radius.circular(6),
      ),
      Paint()..color = _active ? activeColor : inactiveColor,
    );
  }
}
