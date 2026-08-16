/// Mass band used by pads and pushables. Ordered light → heavy.
enum WeightClass { light, medium, heavy }

/// Reusable strength/weight, not a species check.
final class ForceCapability {
  const ForceCapability({required this.weightClass, this.canPush = false});

  static const ForceCapability light = ForceCapability(
    weightClass: WeightClass.light,
  );

  static const ForceCapability medium = ForceCapability(
    weightClass: WeightClass.medium,
  );

  static const ForceCapability heavy = ForceCapability(
    weightClass: WeightClass.heavy,
    canPush: true,
  );

  final WeightClass weightClass;
  final bool canPush;

  bool get canActivateHeavyPad => weightClass == WeightClass.heavy;

  bool get canPushHeavy => canPush && weightClass == WeightClass.heavy;
}
