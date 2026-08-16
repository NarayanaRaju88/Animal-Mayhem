/// Why a commanded action cannot run. Used to map player-facing feedback.
enum AttemptFailure {
  none,
  missingCapability,
  busy,
  incompatible,
  outOfRange,
  pathBlocked,
}
