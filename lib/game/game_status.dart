/// Where the current run is at. [countdown] is the brief "3, 2, 1" beat
/// right after picking a mode/level, before the world actually starts
/// moving. [levelComplete] only ever happens in [GameMode.levels] or
/// [GameMode.coins] — reaching the stage's target (distance, or coins
/// collected) ends the run as a win rather than a [gameOver].
enum GameStatus { start, countdown, playing, gameOver, levelComplete }

/// [endless] is unrestricted — just fly as far as possible. [levels] plays
/// through a fixed, unlockable sequence of target distances. [coins] plays
/// through a similar sequence, but the goal is collecting a target number
/// of coins during the run instead of covering a distance.
enum GameMode { endless, levels, coins }
