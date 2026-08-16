import 'package:flame/components.dart';

import '../../components/environment/climbable_surface_component.dart';
import 'follow_target.dart';

/// Command target wrapping a climbable surface.
final class ClimbableTarget implements FollowTarget {
  ClimbableTarget(this.surface);

  final ClimbableSurfaceComponent surface;

  @override
  Vector2 get worldPosition => surface.worldPosition;
}
