/// Logical height band in the 2D world. Not a 3D coordinate.
enum HeightLevel {
  lower,
  upper;

  /// Animals at or above this world Y (smaller Y is north/up) are on the
  /// elevated platform. Tuned to the Stage 9 development layout.
  static const double upperMaxY = 180;

  static HeightLevel fromY(double y) =>
      y <= upperMaxY ? HeightLevel.upper : HeightLevel.lower;
}
