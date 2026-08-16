import '../../components/animals/animal_component.dart';
import 'game_objective.dart';
import 'objective_status.dart';

/// Completes when two animals are within [distance].
class BringAnimalsTogetherObjective extends GameObjective {
  BringAnimalsTogetherObjective({
    required this.first,
    required this.second,
    required this.distance,
    this.description = 'Bring the animals together',
  });

  final AnimalComponent first;
  final AnimalComponent second;
  final double distance;

  @override
  final String description;

  @override
  void update() {
    if (status == ObjectiveStatus.completed) {
      return;
    }
    if ((first.position - second.position).length <= distance) {
      status = ObjectiveStatus.completed;
    }
  }
}
