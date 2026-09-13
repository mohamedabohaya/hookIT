import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'despawnable.dart';
import 'hook_it_game.dart';
import 'player.dart';

double _clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

/// Returns true if a circle at [center] with [radius] overlaps the
/// axis-aligned rectangle described by [rectPos] (top-left) and [rectSize].
bool circleHitsRect(
  Vector2 center,
  double radius,
  Vector2 rectPos,
  Vector2 rectSize,
) {
  final closestX = _clampD(center.x, rectPos.x, rectPos.x + rectSize.x);
  final closestY = _clampD(center.y, rectPos.y, rectPos.y + rectSize.y);
  final dx = center.x - closestX;
  final dy = center.y - closestY;
  return (dx * dx + dy * dy) < radius * radius;
}

/// Base type for all hazards. Obstacles never move the player themselves —
/// they just report whether the player currently overlaps them; the game
/// decides what happens on a hit (game over).
abstract class Obstacle extends PositionComponent
    with HasGameReference<HookItGame>, Despawnable {
  Obstacle({required super.position, required super.size, super.anchor});

  bool hits(Player player);
}

/// A cluster of upward-facing spikes. Approximated as a rectangle for hit
/// testing, since a precise triangle test would be overkill for the MVP.
class SpikeObstacle extends Obstacle {
  SpikeObstacle({required Vector2 position, this.spikeCount = 4})
    : super(position: position, size: Vector2(spikeCount * 22.0, 34));

  final int spikeCount;
  late final Paint _fillPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF7A5C), Color(0xFFC72A2A)],
    ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFF6E1010);
  final Paint _highlightPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = const Color(0x99FFD9CC);

  // The spike geometry never changes once spawned, so build it once
  // instead of allocating fresh Paths every frame.
  late final Path _path = _buildPath();
  late final List<Offset> _highlightStarts = List.generate(
    spikeCount,
    (i) => Offset(i * (size.x / spikeCount) + (size.x / spikeCount) / 2, 0),
  );
  late final List<Offset> _highlightEnds = List.generate(
    spikeCount,
    (i) => Offset(
      i * (size.x / spikeCount) + (size.x / spikeCount) * 0.32,
      size.y * 0.55,
    ),
  );

  Path _buildPath() {
    final w = size.x / spikeCount;
    final path = Path();
    for (var i = 0; i < spikeCount; i++) {
      path
        ..moveTo(i * w, size.y)
        ..lineTo(i * w + w / 2, 0)
        ..lineTo(i * w + w, size.y)
        ..close();
    }
    return path;
  }

  @override
  bool hits(Player player) {
    // Shrink the hitbox a little relative to the visual so near-misses feel
    // fair.
    final hitPos = Vector2(position.x + 4, position.y + 10);
    final hitSize = Vector2(size.x - 8, size.y - 10);
    return circleHitsRect(player.position, playerRadius * 0.85, hitPos, hitSize);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _fillPaint);
    canvas.drawPath(_path, _outlinePaint);
    for (var i = 0; i < spikeCount; i++) {
      canvas.drawLine(_highlightStarts[i], _highlightEnds[i], _highlightPaint);
    }
  }
}

/// A wall spanning the full obstacle height with a gap the player must
/// thread through by climbing or diving to the right height.
class WallObstacle extends Obstacle {
  WallObstacle({
    required Vector2 position,
    required this.gapY,
    required this.gapHeight,
    this.wallWidth = 34,
    this.totalHeight = 8000,
  }) : super(position: position, size: Vector2(wallWidth, totalHeight));

  final double gapY;
  final double gapHeight;
  final double wallWidth;
  final double totalHeight;

  double _time = 0;

  late final Paint _paint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [Color(0xFF5B84BF), Color(0xFF3E5C87), Color(0xFF2D4568)],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, wallWidth, totalHeight));
  final Paint _edgePaint = Paint()..color = const Color(0xFFFFC94A);

  // The gap opening's marker — a soft pulsing glow plus two chevrons
  // pointing in from the edges — so the opening always reads clearly
  // against the wall, no matter the background palette behind it.
  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _chevronPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFFFC94A);
  late final Path _downChevron = _buildChevron(pointingDown: true);
  late final Path _upChevron = _buildChevron(pointingDown: false);

  static Path _buildChevron({required bool pointingDown}) {
    const halfWidth = 11.0;
    const height = 9.0;
    final tipY = pointingDown ? height : -height;
    return Path()
      ..moveTo(-halfWidth, 0)
      ..lineTo(0, tipY)
      ..lineTo(halfWidth, 0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  bool hits(Player player) {
    final topHeight = gapY;
    final bottomStart = gapY + gapHeight;
    final topHit = topHeight > 0 &&
        circleHitsRect(
          player.position,
          playerRadius * 0.9,
          Vector2(position.x, position.y - totalHeight / 2),
          Vector2(wallWidth, topHeight + totalHeight / 2),
        );
    final bottomHit = circleHitsRect(
      player.position,
      playerRadius * 0.9,
      Vector2(position.x, position.y + bottomStart),
      Vector2(wallWidth, totalHeight),
    );
    return topHit || bottomHit;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, -totalHeight / 2, wallWidth, gapY + totalHeight / 2),
      _paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, gapY + gapHeight, wallWidth, totalHeight),
      _paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, gapY - 4, wallWidth, 4),
      _edgePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, gapY + gapHeight, wallWidth, 4),
      _edgePaint,
    );

    // Pulsing marker inside the opening itself — makes it unmistakable
    // even at a glance, rather than relying on the thin edge highlights.
    final pulse = 0.5 + 0.5 * sin(_time * 4);
    final bob = sin(_time * 4) * 3;

    _glowPaint.color = const Color(0xFFFFC94A).withValues(alpha: 0.08 + 0.07 * pulse);
    canvas.drawRect(Rect.fromLTWH(0, gapY, wallWidth, gapHeight), _glowPaint);

    final chevronAlpha = (0.5 + 0.5 * pulse).clamp(0.0, 1.0);
    _chevronPaint.color = const Color(0xFFFFC94A).withValues(alpha: chevronAlpha);

    canvas.save();
    canvas.translate(wallWidth / 2, gapY + 18 + bob);
    canvas.drawPath(_downChevron, _chevronPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(wallWidth / 2, gapY + gapHeight - 18 - bob);
    canvas.drawPath(_upChevron, _chevronPaint);
    canvas.restore();
  }
}

/// A spinning saw that oscillates vertically — the only obstacle with
/// motion, giving the player something to time their climb/dive around.
class MovingObstacle extends Obstacle {
  MovingObstacle({
    required Vector2 position,
    this.travelRange = 160,
    this.speed = 1.6,
    this.sawRadius = 20,
  }) : _baseY = position.y,
       _phase = Random().nextDouble() * pi * 2,
       super(
         position: position,
         size: Vector2.all(sawRadius * 2),
         anchor: Anchor.center,
       );

  final double travelRange;
  final double speed;
  final double sawRadius;
  final double _baseY;
  final double _phase;
  double _time = 0;
  double _spin = 0;

  late final Paint _paint = Paint()
    ..shader = RadialGradient(
      colors: const [Color(0xFFD7DCE2), Color(0xFF9AA1AC), Color(0xFF6C737C)],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: sawRadius));
  final Paint _toothPaint = Paint()..color = const Color(0xFF5C636E);
  final Paint _centerPaint = Paint()..color = const Color(0xFF3A3F45);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Spins faster the faster it's oscillating, so it visibly speeds up
    // as difficulty ramps.
    _spin += dt * (4 + speed * 2);
    position.y = _baseY + sin(_time * speed + _phase) * travelRange;
  }

  @override
  bool hits(Player player) {
    return (player.position - position).length < playerRadius * 0.85 + sawRadius * 0.8;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(_spin);
    const center = Offset.zero;
    const teeth = 8;
    final path = Path();
    for (var i = 0; i < teeth; i++) {
      final a0 = i / teeth * pi * 2;
      final a1 = (i + 0.5) / teeth * pi * 2;
      path.lineTo(
        center.dx + cos(a0) * sawRadius,
        center.dy + sin(a0) * sawRadius,
      );
      path.lineTo(
        center.dx + cos(a1) * (sawRadius + 6),
        center.dy + sin(a1) * (sawRadius + 6),
      );
    }
    path.close();
    canvas.drawPath(path, _toothPaint);
    canvas.drawCircle(center, sawRadius * 0.7, _paint);
    canvas.drawCircle(center, sawRadius * 0.22, _centerPaint);
    canvas.restore();
  }
}
