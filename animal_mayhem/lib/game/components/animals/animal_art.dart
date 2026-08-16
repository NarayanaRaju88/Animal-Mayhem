import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'animal_component.dart';
import 'animal_state.dart';

/// Species-specific in-world art. Collision size stays on [AnimalComponent].
enum AnimalArtKind { dog, duck, frog, cat, buffalo, monkey, snake }

/// Larger, recognizable animal drawing that follows existing [AnimalState].
class RealisticAnimalVisual extends PositionComponent {
  RealisticAnimalVisual({required this.kind, required Vector2 bodySize})
    : super(
        size: _visualSize(kind, bodySize),
        position: bodySize / 2,
        anchor: Anchor.center,
        priority: 6,
      );

  static Vector2 _visualSize(AnimalArtKind kind, Vector2 body) {
    switch (kind) {
      case AnimalArtKind.cat:
        return Vector2(body.x * 4.2, body.y * 4.4);
      case AnimalArtKind.monkey:
        return Vector2(body.x * 3.6, body.y * 3.8);
      case AnimalArtKind.snake:
        return Vector2(body.x * 3.4, body.y * 5.2);
      case AnimalArtKind.buffalo:
        return Vector2(body.x * 2.15, body.y * 2.3);
      case AnimalArtKind.dog:
        return Vector2(body.x * 2.6, body.y * 2.8);
      case AnimalArtKind.duck:
        return Vector2(body.x * 2.7, body.y * 2.9);
      case AnimalArtKind.frog:
        return Vector2(body.x * 2.7, body.y * 2.8);
    }
  }

  final AnimalArtKind kind;
  double _elapsed = 0;

  AnimalComponent? get _animal {
    final Component? owner = parent;
    return owner is AnimalComponent ? owner : null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final AnimalComponent? animal = _animal;
    final bool selected = animal?.isSelected ?? false;
    final bool moving =
        animal?.state == AnimalState.moving ||
        animal?.state == AnimalState.following ||
        animal?.state == AnimalState.swimming ||
        animal?.state == AnimalState.climbing;
    final double breath = math.sin(_elapsed * (moving ? 10 : 2.6)) * 0.03;
    final double selectedBoost = selected ? 0.12 : 0;
    scale.setValues(1 + selectedBoost, 1 + selectedBoost + breath);
  }

  @override
  void render(Canvas canvas) {
    final AnimalComponent? animal = _animal;
    final bool moving =
        animal?.state == AnimalState.moving ||
        animal?.state == AnimalState.following ||
        animal?.state == AnimalState.swimming ||
        animal?.state == AnimalState.climbing;
    final bool acting =
        animal?.state == AnimalState.jumping ||
        animal?.state == AnimalState.climbing ||
        (animal?.hasCompletedCoil ?? false);
    final double gait = moving ? math.sin(_elapsed * 10) : 0;
    AnimalArt.paint(
      canvas,
      size.toSize(),
      kind: kind,
      gait: gait,
      acting: acting,
      selected: animal?.isSelected ?? false,
    );
  }
}

/// Project-owned semi-realistic animal drawings (not photos, not emoji).
abstract final class AnimalArt {
  static void paint(
    Canvas canvas,
    Size size, {
    required AnimalArtKind kind,
    double gait = 0,
    bool acting = false,
    bool selected = false,
  }) {
    switch (kind) {
      case AnimalArtKind.cat:
        _cat(canvas, size, gait);
      case AnimalArtKind.dog:
        _dog(canvas, size, gait);
      case AnimalArtKind.duck:
        _duck(canvas, size, gait);
      case AnimalArtKind.frog:
        _frog(canvas, size, gait, acting);
      case AnimalArtKind.buffalo:
        _buffalo(canvas, size, gait);
      case AnimalArtKind.monkey:
        _monkey(canvas, size, gait, acting);
      case AnimalArtKind.snake:
        _snake(canvas, size, gait, acting);
    }
    if (selected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
        Paint()
          ..color = const Color(0x55F6E7A8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  static AnimalArtKind kindForSpecies(String speciesName) {
    switch (speciesName) {
      case 'Cat':
        return AnimalArtKind.cat;
      case 'Dog':
        return AnimalArtKind.dog;
      case 'Duck':
        return AnimalArtKind.duck;
      case 'Frog':
        return AnimalArtKind.frog;
      case 'Buffalo':
        return AnimalArtKind.buffalo;
      case 'Monkey':
        return AnimalArtKind.monkey;
      case 'Snake':
        return AnimalArtKind.snake;
      default:
        return AnimalArtKind.dog;
    }
  }

  static Paint _fill(Color color) => Paint()
    ..color = color
    ..isAntiAlias = true;

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  static void _shadow(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.92),
        width: size.width * 0.62,
        height: size.height * 0.12,
      ),
      _fill(const Color(0x66000000)),
    );
  }

  static void _cat(Canvas canvas, Size size, double gait) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double leg = gait * h * 0.06;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.58, h * 0.38),
      _fill(const Color(0xFFD9853A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.48, h * 0.18, w * 0.42, h * 0.42),
      _fill(const Color(0xFFE39A4A)),
    );
    final Path earL = Path()
      ..moveTo(w * 0.52, h * 0.32)
      ..lineTo(w * 0.56, h * 0.08)
      ..lineTo(w * 0.66, h * 0.28)
      ..close();
    final Path earR = Path()
      ..moveTo(w * 0.72, h * 0.28)
      ..lineTo(w * 0.86, h * 0.06)
      ..lineTo(w * 0.88, h * 0.32)
      ..close();
    canvas.drawPath(earL, _fill(const Color(0xFFB45A22)));
    canvas.drawPath(earR, _fill(const Color(0xFFB45A22)));
    canvas.drawPath(earL, _fill(const Color(0x66F3B7A0)));
    canvas.drawOval(
      Rect.fromLTWH(w * 0.58, h * 0.28, w * 0.28, h * 0.22),
      _fill(const Color(0xFFE8B07A)),
    );
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.36),
      w * 0.035,
      _fill(const Color(0xFF2EE6A0)),
    );
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.36),
      w * 0.035,
      _fill(const Color(0xFF2EE6A0)),
    );
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.36),
      w * 0.014,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.36),
      w * 0.014,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.44),
      w * 0.02,
      _fill(const Color(0xFFE07A9A)),
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.44),
      Offset(w * 0.48, h * 0.42),
      _stroke(const Color(0xFF3B2416), 1.2),
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.46),
      Offset(w * 0.48, h * 0.48),
      _stroke(const Color(0xFF3B2416), 1.2),
    );
    canvas.drawLine(
      Offset(w * 0.88, h * 0.44),
      Offset(w * 0.98, h * 0.42),
      _stroke(const Color(0xFF3B2416), 1.2),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.34, h * 0.48, w * 0.22, h * 0.18),
      _fill(const Color(0xFFF2D7B6)),
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.50),
      Offset(w * 0.62, h * 0.48),
      _stroke(const Color(0xFF8A4318), 2.4),
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.58),
      Offset(w * 0.58, h * 0.56),
      _stroke(const Color(0xFF8A4318), 2),
    );
    final Path tail = Path()
      ..moveTo(w * 0.20, h * 0.52)
      ..quadraticBezierTo(w * 0.02, h * 0.20, w * 0.16, h * 0.12);
    canvas.drawPath(tail, _stroke(const Color(0xFFD9853A), h * 0.08));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.28, h * 0.72 + leg, w * 0.08, h * 0.16),
      _fill(const Color(0xFFB45A22)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.40, h * 0.72 - leg, w * 0.08, h * 0.16),
      _fill(const Color(0xFFB45A22)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.54, h * 0.72 + leg, w * 0.08, h * 0.16),
      _fill(const Color(0xFFB45A22)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.64, h * 0.72 - leg, w * 0.08, h * 0.16),
      _fill(const Color(0xFFB45A22)),
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.50),
      Offset(w * 0.62, h * 0.48),
      _stroke(const Color(0xFF8A4318), 2),
    );
  }

  static void _dog(Canvas canvas, Size size, double gait) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double leg = gait * h * 0.07;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.14, h * 0.40, w * 0.62, h * 0.38),
      _fill(const Color(0xFFC4A36A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.52, h * 0.22, w * 0.40, h * 0.38),
      _fill(const Color(0xFFD2B48C)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.74, h * 0.34, w * 0.22, h * 0.16),
      _fill(const Color(0xFFB08958)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.54, h * 0.18, w * 0.14, h * 0.22),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.36),
      w * 0.03,
      _fill(const Color(0xFF1A1A1A)),
    );
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.36),
      w * 0.03,
      _fill(const Color(0xFF1A1A1A)),
    );
    canvas.drawCircle(
      Offset(w * 0.92, h * 0.42),
      w * 0.025,
      _fill(const Color(0xFF2B1A12)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.24, h * 0.72 + leg, w * 0.09, h * 0.16),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.72 - leg, w * 0.09, h * 0.16),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.52, h * 0.72 + leg, w * 0.09, h * 0.16),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.62, h * 0.72 - leg, w * 0.09, h * 0.16),
      _fill(const Color(0xFF8B5A2B)),
    );
    final Path tail = Path()
      ..moveTo(w * 0.16, h * 0.48)
      ..quadraticBezierTo(w * 0.02, h * 0.28, w * 0.12, h * 0.18);
    canvas.drawPath(tail, _stroke(const Color(0xFFC4A36A), h * 0.07));
  }

  static void _duck(Canvas canvas, Size size, double gait) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.16, h * 0.42, w * 0.58, h * 0.36),
      _fill(const Color(0xFFF4F1E8)),
    );
    canvas.drawCircle(
      Offset(w * 0.70, h * 0.36),
      w * 0.18,
      _fill(const Color(0xFFF4F1E8)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.78, h * 0.34, w * 0.20, h * 0.10),
      _fill(const Color(0xFFE6A817)),
    );
    canvas.drawCircle(
      Offset(w * 0.74, h * 0.32),
      w * 0.03,
      _fill(const Color(0xFF1A1A1A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.38, w * 0.22, h * 0.16),
      _fill(const Color(0xFFE6A817)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.36, h * 0.72 + gait * 4, w * 0.16, h * 0.10),
      _fill(const Color(0xFFE6A817)),
    );
  }

  static void _frog(Canvas canvas, Size size, double gait, bool acting) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double hop = acting ? -h * 0.08 : gait * h * 0.04;
    canvas.save();
    canvas.translate(0, hop);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.16, h * 0.40, w * 0.68, h * 0.38),
      _fill(const Color(0xFF4FA85A)),
    );
    canvas.drawCircle(
      Offset(w * 0.34, h * 0.34),
      w * 0.12,
      _fill(const Color(0xFF4FA85A)),
    );
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.34),
      w * 0.12,
      _fill(const Color(0xFF4FA85A)),
    );
    canvas.drawCircle(
      Offset(w * 0.34, h * 0.34),
      w * 0.06,
      _fill(const Color(0xFFF5F0C8)),
    );
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.34),
      w * 0.06,
      _fill(const Color(0xFFF5F0C8)),
    );
    canvas.drawCircle(
      Offset(w * 0.34, h * 0.34),
      w * 0.03,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.34),
      w * 0.03,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.34, h * 0.52, w * 0.32, h * 0.14),
      _fill(const Color(0xFFD5E48A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.08, h * 0.62, w * 0.22, h * 0.16),
      _fill(const Color(0xFF3D8A46)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.70, h * 0.62, w * 0.22, h * 0.16),
      _fill(const Color(0xFF3D8A46)),
    );
    canvas.restore();
  }

  static void _buffalo(Canvas canvas, Size size, double gait) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double leg = gait * h * 0.05;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.10, h * 0.36, w * 0.72, h * 0.42),
      _fill(const Color(0xFF4A2E1A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.34, h * 0.28),
      _fill(const Color(0xFF3A2416)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.62, h * 0.24, w * 0.32, h * 0.32),
      _fill(const Color(0xFF5A3A22)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.66, h * 0.28)
        ..quadraticBezierTo(w * 0.58, h * 0.02, w * 0.50, h * 0.22),
      _stroke(const Color(0xFFE6D3B0), 5),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.88, h * 0.28)
        ..quadraticBezierTo(w * 0.96, h * 0.02, w * 1.02, h * 0.22),
      _stroke(const Color(0xFFE6D3B0), 5),
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.36),
      w * 0.03,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.86, h * 0.40, w * 0.12, h * 0.08),
      _fill(const Color(0xFF2A1810)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.72 + leg, w * 0.10, h * 0.18),
      _fill(const Color(0xFF2E1C12)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.72 - leg, w * 0.10, h * 0.18),
      _fill(const Color(0xFF2E1C12)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.54, h * 0.72 + leg, w * 0.10, h * 0.18),
      _fill(const Color(0xFF2E1C12)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.66, h * 0.72 - leg, w * 0.10, h * 0.18),
      _fill(const Color(0xFF2E1C12)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.44, w * 0.20, h * 0.16),
      _fill(const Color(0xFF6A4A30)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.18, h * 0.12),
      _fill(const Color(0xFF2A1810)),
    );
  }

  static void _monkey(Canvas canvas, Size size, double gait, bool acting) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double climb = acting ? -h * 0.04 : 0;
    canvas.save();
    canvas.translate(0, climb);
    final Path tail = Path()
      ..moveTo(w * 0.18, h * 0.55)
      ..quadraticBezierTo(w * -0.02, h * 0.18, w * 0.22, h * 0.10);
    canvas.drawPath(tail, _stroke(const Color(0xFF7A4A24), h * 0.07));
    canvas.drawOval(
      Rect.fromLTWH(w * 0.28, h * 0.40, w * 0.40, h * 0.42),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.30),
      w * 0.20,
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.32, h * 0.14, w * 0.12, h * 0.16),
      _fill(const Color(0xFF6A3E1C)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.58, h * 0.14, w * 0.12, h * 0.16),
      _fill(const Color(0xFF6A3E1C)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.38, h * 0.22, w * 0.28, h * 0.22),
      _fill(const Color(0xFFE8C99A)),
    );
    canvas.drawCircle(
      Offset(w * 0.46, h * 0.30),
      w * 0.03,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawCircle(
      Offset(w * 0.58, h * 0.30),
      w * 0.03,
      _fill(const Color(0xFF111111)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.46, h * 0.36, w * 0.12, h * 0.06),
      _fill(const Color(0xFF5A3020)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.12, h * 0.48 + gait * 3, w * 0.22, h * 0.10),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.66, h * 0.48 - gait * 3, w * 0.22, h * 0.10),
      _fill(const Color(0xFF8B5A2B)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.32, h * 0.74, w * 0.12, h * 0.14),
      _fill(const Color(0xFF6A3E1C)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.52, h * 0.74, w * 0.12, h * 0.14),
      _fill(const Color(0xFF6A3E1C)),
    );
    canvas.restore();
  }

  static void _snake(Canvas canvas, Size size, double gait, bool acting) {
    _shadow(canvas, size);
    final double w = size.width;
    final double h = size.height;
    final double wave = gait * h * 0.12;
    final Path body = Path()
      ..moveTo(w * 0.06, h * 0.62)
      ..quadraticBezierTo(w * 0.22, h * 0.18 + wave, w * 0.42, h * 0.58)
      ..quadraticBezierTo(w * 0.62, h * 0.92 - wave, w * 0.82, h * 0.42)
      ..quadraticBezierTo(w * 0.92, h * 0.18, w * 0.96, h * 0.32);
    canvas.drawPath(
      body,
      Paint()
        ..color = acting ? const Color(0xFF2F7A3A) : const Color(0xFF3F8A4A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.28
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFFC8D96A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.94, h * 0.30),
      h * 0.16,
      _fill(const Color(0xFF4A9A52)),
    );
    canvas.drawCircle(
      Offset(w * 0.92, h * 0.26),
      w * 0.025,
      _fill(const Color(0xFFE8E070)),
    );
    canvas.drawCircle(
      Offset(w * 0.97, h * 0.28),
      w * 0.018,
      _fill(const Color(0xFFE24B4B)),
    );
    final Path tongue = Path()
      ..moveTo(w * 0.99, h * 0.32)
      ..lineTo(w * 1.08, h * 0.28)
      ..moveTo(w * 0.99, h * 0.32)
      ..lineTo(w * 1.08, h * 0.36);
    canvas.drawPath(tongue, _stroke(const Color(0xFFE24B4B), 2));
    if (acting) {
      canvas.drawCircle(
        Offset(w * 0.50, h * 0.52),
        h * 0.28,
        _stroke(const Color(0xFFC8D96A), 3),
      );
    }
  }
}
