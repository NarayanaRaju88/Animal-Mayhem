import 'package:flame/components.dart';

import '../../systems/interaction/interactable.dart';
import 'follow_target.dart';

/// Follow/command target wrapping an [Interactable].
final class InteractableTarget implements FollowTarget {
  InteractableTarget(this.object);

  final Interactable object;

  @override
  Vector2 get worldPosition => object.worldPosition;
}
