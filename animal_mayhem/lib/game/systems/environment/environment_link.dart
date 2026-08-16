/// Source of a boolean environment condition (pad, switch, later doors).
abstract interface class EnvironmentTrigger {
  bool get isActive;
}

/// Object that follows a trigger (bridge, gate, later doors).
abstract interface class EnvironmentResponder {
  void applyEnvironmentState(bool active);
}

/// Connects a trigger to a responder without species-specific wiring.
final class EnvironmentLink {
  EnvironmentLink({required this.trigger, required this.responder});

  final EnvironmentTrigger trigger;
  final EnvironmentResponder responder;
  bool? _last;

  void sync({bool force = false}) {
    final bool active = trigger.isActive;
    if (!force && _last == active) {
      return;
    }
    _last = active;
    responder.applyEnvironmentState(active);
  }
}

/// Standalone named boolean used by tests and future switches.
final class EnvironmentSignal implements EnvironmentTrigger {
  EnvironmentSignal({this.id = '', this.initial = false}) : _active = initial;

  final String id;
  final bool initial;
  bool _active;

  @override
  bool get isActive => _active;

  void setActive(bool value) {
    _active = value;
  }

  void reset() {
    _active = initial;
  }
}
