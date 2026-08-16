import 'dart:ui';

import 'package:flame/components.dart';

import 'terrain_kind.dart';

/// Looks up terrain at a world point.
class TerrainMap {
  TerrainMap({required this.worldBounds, required Rect waterBounds})
    : waterRegions = <Rect>[waterBounds],
      waterBounds = waterBounds;

  TerrainMap.regions({
    required this.worldBounds,
    required List<Rect> waterRegions,
  }) : waterRegions = List<Rect>.from(waterRegions),
       waterBounds = waterRegions.isEmpty ? Rect.zero : waterRegions.first;

  final Rect worldBounds;
  final Rect waterBounds;
  final List<Rect> waterRegions;

  TerrainKind kindAt(Vector2 point) {
    for (final Rect region in waterRegions) {
      if (_contains(region, point)) {
        return TerrainKind.water;
      }
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
