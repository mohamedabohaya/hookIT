import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'despawnable.dart';
import 'hook_it_game.dart';

/// A simple collectible. Removes itself once the player flies through it.
///
/// Animated purely at render time (a gentle bob plus a spin) so it reads
/// as alive rather than a static dot — collision still uses the coin's
/// real, unmoving [position].
class Coin extends PositionComponent
    with HasGameReference<HookItGame>, Despawnable {
  Coin({required Vector2 position, this.radius = 10})
    : super(position: position, anchor: Anchor.center);

  final double radius;
  bool collected = false;
  double _time = Random().nextDouble() * 10;

  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _fillPaint = Paint()..color = const Color(0xFFFFD23F);
  final Paint _shinePaint = Paint()..color = const Color(0xFFFFF3C4);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = const Color(0xFFB8860B);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // A slow bob so the coin visibly moves in place, plus a spin — makes
    // it read as alive rather than a static dot the player just passes.
    final bob = sin(_time * 2.4) * 4;
    final pulse = 0.5 + 0.5 * sin(_time * 2.4);
    final squash = cos(_time * 3.2).abs().clamp(0.15, 1.0);

    canvas.save();
    canvas.translate(0, bob);

    _glowPaint.color = const Color(
      0xFFFFD23F,
    ).withValues(alpha: 0.16 + 0.1 * pulse);
    canvas.drawCircle(Offset.zero, radius + 5 + pulse * 2, _glowPaint);

    canvas.save();
    canvas.scale(squash, 1);
    canvas.drawCircle(Offset.zero, radius, _fillPaint);
    canvas.drawCircle(Offset.zero, radius, _outlinePaint);
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.3,
      _shinePaint,
    );
    canvas.restore();

    canvas.restore();
  }
}
