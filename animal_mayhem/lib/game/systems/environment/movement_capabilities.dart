import 'terrain_kind.dart';

/// Which terrain an animal may occupy.
final class MovementCapabilities {
  const MovementCapabilities({required this.allowedTerrain});

  static const MovementCapabilities landOnly = MovementCapabilities(
    allowedTerrain: <TerrainKind>{TerrainKind.land},
  );

  static const MovementCapabilities landAndWater = MovementCapabilities(
    allowedTerrain: <TerrainKind>{TerrainKind.land, TerrainKind.water},
  );

  final Set<TerrainKind> allowedTerrain;

  bool canTraverse(TerrainKind terrain) => allowedTerrain.contains(terrain);
}
