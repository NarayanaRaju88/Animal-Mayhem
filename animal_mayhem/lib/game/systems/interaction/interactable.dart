import 'package:flame/components.dart';

/// Something an animal can use INTERACT on.
abstract interface class Interactable {
  Vector2 get worldPosition;

  double get interactionRange;

  bool get canInteract;

  String get label;

  void interact();
}
