import 'dart:ui';

import '../../components/animals/animal_component.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes when [animal] is inside [zone].
class AnimalAtLocationObjective extends GameObjective {
  AnimalAtLocationObjective({
    required this.animal,
    required this.zone,
    this.description = 'Reach the goal',
  });

  final AnimalComponent animal;
  final Rect zone;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if (zone.contains(Offset(animal.position.x, animal.position.y))) {
      status = ObjectiveStatus.completed;
    }
  }
}
