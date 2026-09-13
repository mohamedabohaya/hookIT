import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'despawnable.dart';
import 'hook_it_game.dart';

/// What a [PowerUp] grants once collected. Both are temporary — they wear
/// off on their own timer (see [HookItGame.coinMultiplierTimeLeft] /
/// [HookItGame.speedBoostTimeLeft]) rather than lasting the rest of the run.
enum PowerUpKind {
  /// Every coin collected while active counts double, toward both the
  /// run's coin count and the persistent balance.
  coinMultiplier,

  /// Forward speed — and so distance/score — is boosted while active.
  speedBoost,
}

/// A rarer collectible than [Coin] that grants a temporary buff instead of
/// score. Visually distinct per [kind] (a purple "2×" badge vs. a cyan
/// lightning bolt) so the player can tell at a glance what they're flying
/// toward. Animated purely at render time, same as [Coin] — collision uses
/// the component's real, unmoving [position].
class PowerUp extends PositionComponent
    with HasGameReference<HookItGame>, Despawnable {
  PowerUp({required Vector2 position, required this.kind, this.radius = 15})
    : super(position: position, anchor: Anchor.center);

  final PowerUpKind kind;
  final double radius;
  bool collected = false;
  double _time = Random().nextDouble() * 10;

  late final Color _color = kind == PowerUpKind.coinMultiplier
      ? const Color(0xFF9B6BFF)
      : const Color(0xFF2FE6FF);

  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _fillPaint = Paint()..color = _color;
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFF201233);
  final Paint _boltPaint = Paint()..color = Colors.white;

  // Built once — the shape/label never changes after spawn.
  late final Path _boltPath = _buildBoltPath();
  late final TextPainter _labelPainter = TextPainter(
    text: const TextSpan(
      text: '2×',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  Path _buildBoltPath() {
    final r = radius;
    return Path()
      ..moveTo(r * 0.15, -r * 0.75)
      ..lineTo(-r * 0.45, r * 0.05)
      ..lineTo(-r * 0.05, r * 0.05)
      ..lineTo(-r * 0.2, r * 0.75)
      ..lineTo(r * 0.5, -r * 0.1)
      ..lineTo(r * 0.05, -r * 0.1)
      ..close();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // A slow bob + pulsing glow, matching Coin's animation language so it
    // reads as part of the same collectible family.
    final bob = sin(_time * 2.4) * 4;
    final pulse = 0.5 + 0.5 * sin(_time * 2.4);

    canvas.save();
    canvas.translate(0, bob);

    _glowPaint.color = _color.withValues(alpha: 0.22 + 0.12 * pulse);
    canvas.drawCircle(Offset.zero, radius + 6 + pulse * 3, _glowPaint);

    canvas.drawCircle(Offset.zero, radius, _fillPaint);
    canvas.drawCircle(Offset.zero, radius, _outlinePaint);

    if (kind == PowerUpKind.coinMultiplier) {
      _labelPainter.paint(
        canvas,
        Offset(-_labelPainter.width / 2, -_labelPainter.height / 2),
      );
    } else {
      canvas.drawPath(_boltPath, _boltPaint);
    }

    canvas.restore();
  }
}
