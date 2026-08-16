import 'package:flame/components.dart';

import '../../components/animals/animal_component.dart';
import 'follow_target.dart';

/// A target that tracks another animal's live position.
final class AnimalTarget implements FollowTarget {
  AnimalTarget(this.animal);

  final AnimalComponent animal;

  @override
  Vector2 get worldPosition => animal.position;
}
