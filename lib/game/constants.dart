/// Tunable constants for Hook It.
///
/// All world-space values are expressed in the fixed-resolution viewport
/// defined by [viewportWidth] x [viewportHeight], so gameplay feel is
/// consistent across every device regardless of physical screen size.
library;

// --- Viewport -------------------------------------------------------------

// A tall, narrow aspect (close to a modern phone's) so there's minimal
// letterboxing on real devices.
const double viewportWidth = 450;
const double viewportHeight = 975;

// --- Player -----------------------------------------------------------

const double playerRadius = 20;
const double playerStartX = 140;
const double playerStartY = 460;

const double gravity = 1500;
const double minForwardSpeed = 190;
const double forwardAccel = 260;
const double maxFallSpeed = 950;
const double maxSpeed = 1400;

/// The forward auto-run speed climbs from [minForwardSpeed] up to this cap
/// as distance increases, so a long run keeps building pace.
const double maxForwardSpeedCap = 430;

/// How many world-px of forward speed are added per meter travelled.
/// Tuned so the cap is reached around [difficultyRampMeters], matching the
/// obstacle ramp so speed and challenge escalate together.
const double forwardSpeedPerMeter = 0.12;

/// If the player dives this far below, or climbs this far above, the
/// start height, the run ends — falling too low is fatal, and flying too
/// high to dodge everything isn't a viable strategy either.
const double deathY = 1100;
const double topBoundY = -730;

// --- Touch-zone flight control ------------------------------------------
//
// Holding the bottom half of the screen pulls the player up; holding the
// top half pulls them down. No aiming, no targets — just two zones.

const double thrustUpAccel = 1900;
const double thrustDownAccel = 2200;
const double maxRiseSpeed = 620;
const double maxDiveSpeed = 1100;

/// Rather than snapping straight to the accelerated value, rise/dive
/// velocity eases toward its target at this rate — smooths out both the
/// start of a hold and letting go, and avoids a jarring flip if a finger
/// drags straight from one zone to the other.
const double thrustEaseRate = 8.5;

// --- Camera -------------------------------------------------------------

const double cameraLookAheadX = 150;
const double cameraVerticalOffset = -100;
const double cameraFollowSpeed = 7;

/// How far the player can rise/dive from the camera's current vertical
/// anchor before the camera reacts at all. Keeps small corrections (lining
/// up with a gap, dodging a spike) from dragging the whole world around —
/// only a sustained climb or dive actually scrolls the view.
const double verticalCameraDeadzone = 250;

// --- World / scoring ----------------------------------------------------

const double pixelsPerMeter = 16;
const double despawnMarginBehindPlayer = 520;
const double spawnAheadDistance = 950;

// --- Level generation -----------------------------------------------------

const double minChunkWidth = 360;
const double maxChunkWidth = 620;

/// Vertical bounds the path/hazards are kept within, tuned for the
/// 450x975 viewport. Also used to pick a safe respawn height when
/// continuing a run with a heart (see [HookItGame.continueWithHeart]).
const double pathMinY = 195;
const double pathMaxY = 683;

/// Meters per "level" — crossing a multiple of this shows a LEVEL UP
/// banner and nudges the background palette, so a long run visibly
/// progresses through distinct stages rather than staying flat.
const double metersPerLevel = 400;

/// Distance (in meters) over which obstacle frequency/speed ramps from its
/// easiest to its hardest setting.
const double difficultyRampMeters = 2000;

// --- Countdown ----------------------------------------------------------

/// How long the pre-run "3, 2, 1" countdown lasts, in seconds. The world
/// (and any obstacles already spawned ahead) sits frozen and visible for
/// this long before gameplay actually starts.
const double countdownSeconds = 3.0;

// --- Gap hint -------------------------------------------------------------

/// How far ahead (in world px) the next wall's gap is picked up for the
/// HUD direction hint — comfortably inside [spawnAheadDistance], so the
/// hint can appear before the wall itself is clearly visible on screen.
const double gapHintLookahead = 650;

/// The hint hides once the player is within this many px (vertically) of
/// the gap's center — close enough that the gap itself is now the clearer
/// guide.
const double gapHintAlignedMargin = 26;

// --- Power-ups --------------------------------------------------------

/// Chance, per generated chunk (past the easy opening), that a power-up
/// spawns in it. Kept rare relative to coins/obstacles.
const double powerUpChance = 0.08;

/// How long a coin-multiplier buff lasts once collected.
const double coinMultiplierDuration = 8.0;

/// Each coin collected while the multiplier is active counts as this many.
const int coinMultiplierFactor = 2;

/// How long a speed-boost buff lasts once collected.
const double speedBoostDuration = 4.0;

/// Forward-speed multiplier while a speed boost is active.
const double speedBoostFactor = 1.6;

// --- Hearts ---------------------------------------------------------------

/// Chance, per generated chunk (past the easy opening), that a heart
/// spawns in it. Kept rarer than power-ups — a spare life is worth more
/// than a temporary buff.
const double heartChance = 0.035;

/// Coin price for a single heart in the Store.
const int heartPrice = 100;

/// Coin price for a 5-heart bundle — a modest discount over buying one
/// at a time.
const int heartBundlePrice = 450;
const int heartBundleCount = 5;

/// How many world-px around the player are cleared of obstacles when
/// continuing with a heart — otherwise whatever just killed them would
/// still be sitting right there.
const double continueSafeZoneRadius = 420;

/// How long the player is immune to obstacles/boundary death right after
/// continuing with a heart, giving them a beat to get their bearings.
const double continueInvulnerabilityDuration = 2.0;
