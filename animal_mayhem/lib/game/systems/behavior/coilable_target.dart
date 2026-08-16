import 'package:flame/components.dart';

import '../../components/objects/coil_anchor_component.dart';
import 'follow_target.dart';

/// Command target wrapping a coil anchor.
final class CoilableTarget implements FollowTarget {
  CoilableTarget(this.anchor);

  final CoilAnchorComponent anchor;

  @override
  Vector2 get worldPosition => anchor.worldPosition;
}
