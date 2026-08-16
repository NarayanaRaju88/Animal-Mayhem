import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/terrain_kind.dart';
import '../../systems/environment/terrain_map.dart';
import '../../systems/interaction/resettable.dart';
import 'obstacle_component.dart';

/// Block that a heavy, pushing animal can slide. Others treat it as a wall.
class PushableComponent extends ObstacleComponent implements Resettable {
  PushableComponent({required super.position, required super.size})
    : spawn = position.clone(),
      super(jumpable: false);

  final Vector2 spawn;
  TerrainMap? terrain;
  Rect worldBounds = Rect.zero;
  List<ObstacleComponent> blockers = <ObstacleComponent>[];
  final Vector2 _lastDelta = Vector2.zero();

  static const Color fillColor = Color(0xFF7A5A3A);
  static const Color outlineColor = Color(0xFF2B1A10);

  Vector2 get worldCenter => position + size / 2;

  bool tryPush(Vector2 delta) {
    if (delta.length2 == 0) {
      return false;
    }
    final Vector2 previous = position.clone();
    position += delta;
    if (!_placementValid()) {
      position.setFrom(previous);
      _lastDelta.setZero();
      return false;
    }
    _lastDelta.setFrom(delta);
    return true;
  }

  void undoLastPush() {
    position -= _lastDelta;
    _lastDelta.setZero();
  }

  @override
  void resetState() {
    position.setFrom(spawn);
    _lastDelta.setZero();
  }

  bool _placementValid() {
    final List<Vector2> samples = <Vector2>[
      worldCenter,
      position.clone(),
      position + Vector2(size.x, 0),
      position + Vector2(0, size.y),
      position + size,
    ];
    for (final Vector2 sample in samples) {
      if (sample.x < worldBounds.left ||
          sample.x > worldBounds.right ||
          sample.y < worldBounds.top ||
          sample.y > worldBounds.bottom) {
        return false;
      }
      final TerrainMap? map = terrain;
      if (map != null && map.kindAt(sample) == TerrainKind.water) {
        return false;
      }
      for (final ObstacleComponent blocker in blockers) {
        if (identical(blocker, this)) {
          continue;
        }
        if (blocker.containsWorldPoint(sample)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = fillColor);
    canvas.drawRect(
      size.toRect().deflate(3),
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
