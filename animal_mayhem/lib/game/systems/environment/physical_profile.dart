/// Body size used for clearance checks. Species should set this once.
final class PhysicalProfile {
  const PhysicalProfile({required this.bodyWidth, required this.bodyHeight});

  factory PhysicalProfile.fromSize({
    required double width,
    required double height,
  }) {
    return PhysicalProfile(bodyWidth: width, bodyHeight: height);
  }

  final double bodyWidth;
  final double bodyHeight;

  double get collisionRadius {
    final double widest = bodyWidth > bodyHeight ? bodyWidth : bodyHeight;
    return widest / 2;
  }

  bool canFitClearance(double requiredClearance) =>
      bodyWidth <= requiredClearance;
}
