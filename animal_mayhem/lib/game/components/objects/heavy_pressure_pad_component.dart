import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/force_capability.dart';
import '../../systems/environment/occupancy_requirement.dart';
import 'pressure_pad_component.dart';

/// Pressure pad that only a heavy force profile can activate.
class HeavyPressurePadComponent extends PressurePadComponent {
  HeavyPressurePadComponent({required super.position, required super.size})
    : super(requirement: const WeightRequirement(WeightClass.heavy));

  static const Color heavyPlateColor = Color(0xFF1F1A16);
  static const Color heavyInactiveColor = Color(0xFF6A4A2A);
  static const Color heavyActiveColor = Color(0xFFB8860B);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10)),
      Paint()..color = heavyPlateColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().deflate(8),
        const Radius.circular(6),
      ),
      Paint()..color = isActive ? heavyActiveColor : heavyInactiveColor,
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.16,
      Paint()
        ..color = const Color(0x66F4E27A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
