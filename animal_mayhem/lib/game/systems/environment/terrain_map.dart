import 'dart:ui';

import 'package:flame/components.dart';

import 'terrain_kind.dart';

/// Looks up terrain at a world point. Stage 3 uses one water rectangle.
class TerrainMap {
  TerrainMap({required this.worldBounds, required this.waterBounds});

  final Rect worldBounds;
  final Rect waterBounds;

  TerrainKind kindAt(Vector2 point) {
    if (_contains(waterBounds, point)) {
      return TerrainKind.water;
    }
    return TerrainKind.land;
  }

  bool _contains(Rect rect, Vector2 point) {
    return point.x >= rect.left &&
        point.x <= rect.right &&
        point.y >= rect.top &&
        point.y <= rect.bottom;
  }
}
