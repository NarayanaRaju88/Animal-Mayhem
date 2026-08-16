import 'dart:ui';

import 'package:flame/components.dart';

import '../../systems/environment/environment_link.dart';
import '../../systems/interaction/resettable.dart';
import 'obstacle_component.dart';

/// Obstacle that can open and stop blocking movement.
class Gate extends ObstacleComponent
    implements Resettable, EnvironmentResponder {
  Gate({
    required super.position,
    required super.size,
    this.followEnvironment = false,
  }) : super(jumpable: false);

  /// When true, the gate tracks the environment signal (open while active).
  /// When false, [open] and an active signal latch until reset (Stage 5 lever).
  final bool followEnvironment;

  bool isOpen = false;

  static const Color closedColor = Color(0xFF6B2E2E);
  static const Color openColor = Color(0x446B2E2E);

  @override
  bool containsWorldPoint(Vector2 point) {
    if (isOpen) {
      return false;
    }
    return super.containsWorldPoint(point);
  }

  void open() {
    isOpen = true;
  }

  @override
  void applyEnvironmentState(bool active) {
    if (followEnvironment) {
      isOpen = active;
      return;
    }
    if (active) {
      isOpen = true;
    }
  }

  @override
  void resetState() {
    isOpen = false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = isOpen ? openColor : closedColor,
    );
    canvas.drawRect(
      size.toRect().deflate(2),
      Paint()
        ..color = const Color(0xFF3A1515)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
