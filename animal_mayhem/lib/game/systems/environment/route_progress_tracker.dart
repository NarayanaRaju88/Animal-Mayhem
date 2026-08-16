import '../../components/animals/animal_component.dart';
import '../interaction/resettable.dart';
import 'terrain_kind.dart';
import 'terrain_map.dart';

/// Records whether an animal used water or a jump during this attempt.
class RouteProgressTracker implements Resettable {
  RouteProgressTracker({required this.animal, required this.terrain});

  final AnimalComponent animal;
  final TerrainMap terrain;

  bool visitedWater = false;
  bool usedJump = false;

  void sample() {
    if (terrain.kindAt(animal.position) == TerrainKind.water) {
      visitedWater = true;
    }
    if (animal.isJumping) {
      usedJump = true;
    }
  }

  @override
  void resetState() {
    visitedWater = false;
    usedJump = false;
  }
}
