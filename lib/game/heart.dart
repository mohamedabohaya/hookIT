import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'despawnable.dart';
import 'hook_it_game.dart';

/// A rare collectible — grants a spare life, spendable later to continue
/// a run right where it ended instead of going to Game Over (see
/// [HookItGame.continueWithHeart]). Animated purely at render time, same
/// as [Coin]/[PowerUp] — collision uses the component's real, unmoving
/// [position].
class Heart extends PositionComponent with HasGameReference<HookItGame>, Despawnable {
  Heart({required Vector2 position, this.radius = 15}) : super(position: position, anchor: Anchor.center);

  final double radius;
  bool collected = false;
  double _time = Random().nextDouble() * 10;

  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _fillPaint = Paint()..color = const Color(0xFFFF5C7A);
  final Paint _shinePaint = Paint()..color = const Color(0xFFFFD3DC);
  final Paint _outlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFF7A1030);

  late final Path _heartPath = _buildHeartPath();

  Path _buildHeartPath() {
    final r = radius;
    return Path()
      ..moveTo(0, r * 0.95)
      ..cubicTo(-r * 1.35, r * 0.15, -r * 1.1, -r * 0.75, -r * 0.5, -r * 0.85)
      ..cubicTo(-r * 0.05, -r * 0.95, 0, -r * 0.55, 0, -r * 0.28)
      ..cubicTo(0, -r * 0.55, r * 0.05, -r * 0.95, r * 0.5, -r * 0.85)
      ..cubicTo(r * 1.1, -r * 0.75, r * 1.35, r * 0.15, 0, r * 0.95)
      ..close();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Same bob + pulse language as Coin/PowerUp, so it reads as part of
    // the same collectible family despite the different shape.
    final bob = sin(_time * 2.6) * 4;
    final pulse = 0.5 + 0.5 * sin(_time * 2.6);

    canvas.save();
    canvas.translate(0, bob);

    _glowPaint.color = const Color(0xFFFF5C7A).withValues(alpha: 0.2 + 0.12 * pulse);
    canvas.drawCircle(Offset.zero, radius + 7 + pulse * 3, _glowPaint);

    final scale = 0.92 + pulse * 0.08;
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(_heartPath, _fillPaint);
    canvas.drawPath(_heartPath, _outlinePaint);
    canvas.drawCircle(Offset(-radius * 0.35, -radius * 0.5), radius * 0.22, _shinePaint);
    canvas.restore();

    canvas.restore();
  }
}
