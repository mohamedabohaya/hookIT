/// The fixed sequence of Level-mode stages. Index 0 is Level 1. Each entry
/// is the distance (in meters) the player must reach to clear that level
/// and unlock the next one.
///
/// Targets grow faster than [difficultyRampMeters] so later levels are
/// played almost entirely at max obstacle difficulty — the level list
/// itself is the difficulty curve, no separate per-level tuning needed.
const List<int> levelTargets = [
  250,
  500,
  800,
  1150,
  1550,
  2000,
  2500,
  3100,
  3800,
  4600,
];

int get levelCount => levelTargets.length;
