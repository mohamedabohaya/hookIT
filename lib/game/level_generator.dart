import 'dart:math';

import 'package:flame/components.dart';

import 'coin.dart';
import 'constants.dart';
import 'hook_it_game.dart';
import 'obstacle.dart';
import 'power_up.dart';

/// Generates an endless stream of coins and obstacles ahead of the player,
/// and prunes them once they fall behind. The player has no aim to line
/// up — just a hold-bottom-to-rise / hold-top-to-dive control — so each
/// chunk is built around a single target height that coins trace and
/// obstacles test, rather than a chain of hook points.
///
/// Difficulty (obstacle frequency, hazard speed, and how tight the gaps
/// are) ramps with [HookItGame.difficulty], so a long run keeps getting
/// busier instead of staying flat.
class LevelGenerator {
  LevelGenerator(this.game);

  final HookItGame game;
  final Random _rng = Random();

  double _nextSpawnX = 0;
  double _lastY = playerStartY;
  int _chunkIndex = 0;

  // Vertical bounds the path/hazards are kept within, tuned for the
  // 450x975 viewport.
  static const double _minY = 195;
  static const double _maxY = 683;

  void reset() {
    _nextSpawnX = playerStartX + 260;
    _lastY = playerStartY;
    _chunkIndex = 0;
    // Pre-fill so the world isn't empty the instant the run starts.
    while (_nextSpawnX < playerStartX + spawnAheadDistance) {
      _generateChunk();
    }
  }

  void update() {
    while (_nextSpawnX < game.player.position.x + spawnAheadDistance) {
      _generateChunk();
    }
  }

  void _generateChunk() {
    _chunkIndex++;
    final easyStart = _chunkIndex <= 2;
    final difficulty = game.difficulty;

    // Chunks get a little tighter at higher difficulty, for a faster pace.
    final width = (minChunkWidth + _rng.nextDouble() * (maxChunkWidth - minChunkWidth)) *
        (1 - difficulty * 0.15);
    final startX = _nextSpawnX;
    final endX = startX + width;
    final newY = easyStart
        ? _lastY
        : (_lastY + (_rng.nextDouble() - 0.5) * 300).clamp(_minY, _maxY);

    _spawnCoinArc(startX, _lastY, endX, newY, 4);

    if (!easyStart) {
      final obstacleChance = 0.25 + difficulty * 0.5;
      if (_rng.nextDouble() < obstacleChance) {
        _spawnObstacle(startX, endX, _lastY, newY, difficulty);
      }
      _maybeSpawnPowerUp(startX, _lastY, endX, newY);
    }

    _lastY = newY;
    _nextSpawnX = endX;
  }

  /// Rarely drops a coin-multiplier or speed-boost power-up along the same
  /// arc the coins trace, offset to the midpoint so it never lands exactly
  /// on top of one.
  void _maybeSpawnPowerUp(double startX, double startY, double endX, double endY) {
    if (_rng.nextDouble() > powerUpChance) return;
    const t = 0.5;
    final x = startX + (endX - startX) * t;
    final y = startY + (endY - startY) * t - sin(t * pi) * 55;
    final kind = _rng.nextBool() ? PowerUpKind.coinMultiplier : PowerUpKind.speedBoost;
    game.world.add(PowerUp(position: Vector2(x, y), kind: kind));
  }

  void _spawnCoinArc(double startX, double startY, double endX, double endY, int count) {
    for (var i = 1; i <= count; i++) {
      final t = i / (count + 1);
      final x = startX + (endX - startX) * t;
      // Sag the arc a bit so coins trace a natural-looking path.
      final y = startY + (endY - startY) * t - sin(t * pi) * 55;
      game.world.add(Coin(position: Vector2(x, y)));
    }
  }

  void _spawnObstacle(
    double startX,
    double endX,
    double startY,
    double endY,
    double difficulty,
  ) {
    final midX = (startX + endX) / 2;
    final pathY = (startY + endY) / 2;

    // A couple of tighter/faster patterns only show up once the run has
    // built up some difficulty, so the level visibly gets harder over
    // time rather than just repeating the same few shapes.
    final patterns = [
      _Pattern.spike,
      _Pattern.wallGap,
      _Pattern.moving,
      if (difficulty > 0.35) _Pattern.narrowGap,
      if (difficulty > 0.5) _Pattern.spikePair,
    ];
    final pattern = patterns[_rng.nextInt(patterns.length)];

    switch (pattern) {
      case _Pattern.spike:
        // Sits just off the coin path — the player has to nudge up or
        // down to avoid it.
        final side = _rng.nextBool() ? 1 : -1;
        final spikeY = (pathY + side * 90).clamp(_minY, _maxY);
        game.world.add(SpikeObstacle(position: Vector2(midX, spikeY)));

      case _Pattern.wallGap:
        final gapHeight = 260.0;
        final gapY = (pathY - gapHeight / 2).clamp(_minY - 60, _maxY - gapHeight + 60);
        game.world.add(
          WallObstacle(position: Vector2(midX, 0), gapY: gapY, gapHeight: gapHeight),
        );

      case _Pattern.narrowGap:
        // A tighter thread-the-needle gap for later, harder stretches.
        final gapHeight = 195.0;
        final gapY = (pathY - gapHeight / 2).clamp(_minY - 60, _maxY - gapHeight + 60);
        game.world.add(
          WallObstacle(position: Vector2(midX, 0), gapY: gapY, gapHeight: gapHeight),
        );

      case _Pattern.spikePair:
        // Spikes above and below the path — thread cleanly through the
        // middle rather than just nudging past one side.
        final gap = 170.0;
        game.world.add(SpikeObstacle(position: Vector2(midX, (pathY - gap / 2).clamp(_minY, _maxY))));
        game.world.add(SpikeObstacle(position: Vector2(midX, (pathY + gap / 2).clamp(_minY, _maxY))));

      case _Pattern.moving:
        game.world.add(
          MovingObstacle(
            position: Vector2(midX, pathY),
            travelRange: 130 + _rng.nextDouble() * 90,
            speed: 1.4 + difficulty * 1.3,
          ),
        );
    }
  }
}

enum _Pattern { spike, wallGap, narrowGap, spikePair, moving }
