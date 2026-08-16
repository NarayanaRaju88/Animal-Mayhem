import 'objective_status.dart';

/// A level goal that can later be swapped for other objective types.
abstract class GameObjective {
  ObjectiveStatus status = ObjectiveStatus.active;

  bool get isComplete => status == ObjectiveStatus.completed;

  String get description => 'Objective';

  void update();

  void reset() {
    status = ObjectiveStatus.active;
  }
}
