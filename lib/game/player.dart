import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'hook_it_game.dart';
import 'store_items.dart';

/// The player-controlled hero: position, velocity, gravity and forward
/// momentum live here. Vertical movement is driven entirely by which
/// screen zone is currently held — [thrustingUp] and [thrustingDown] are
/// set by [HookItGame] from touch input each frame.
class Player extends PositionComponent with HasGameReference<HookItGame> {
  Player()
    : super(
        position: Vector2(playerStartX, playerStartY),
        size: Vector2.all(playerRadius * 2),
        anchor: Anchor.center,
      ) {
    applySkin(characterSkins.first);
  }

  final Vector2 velocity = Vector2(minForwardSpeed, 0);

  bool thrustingUp = false;
  bool thrustingDown = false;

  /// 0 when idle, ramps to 1 while thrusting up, -1 while thrusting down —
  /// purely cosmetic, used to blend the player's tilt/stretch smoothly.
  double thrustBlend = 0;

  double visualAngle = 0;
  bool dead = false;

  final List<Vector2> _trail = [];
  double _trailTimer = 0;

  CharacterSkin _skin = characterSkins.first;
  late Paint _bodyPaint;
  late Paint _bellyPaint;
  late Paint _outlinePaint;
  late Color _trailColor;

  // A flat translucent circle rather than a blurred one — blur mask
  // filters are noticeably more expensive to rasterize every frame for
  // what little they added here.
  final Paint _shadowPaint = Paint()..color = const Color(0x22000000);
  final Paint _eyePaint = Paint()..color = Colors.white;
  final Paint _pupilPaint = Paint()..color = const Color(0xFF20242C);
  final Paint _speedLinePaint = Paint()..strokeWidth = 2;
  final Paint _trailPaint = Paint()..style = PaintingStyle.fill;

  /// Swaps the ball's look to [skin] — called once on load with the
  /// player's saved choice, and again immediately if they change it in the
  /// Store mid-session.
  void applySkin(CharacterSkin skin) {
    _skin = skin;
    _bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.1,
        colors: _skin.bodyColors,
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: playerRadius));
    _bellyPaint = Paint()..color = _skin.bellyColor;
    _outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _skin.outlineColor;
    _trailColor = _skin.bodyColors[1];
  }

  void resetForNewRun() {
    position.setValues(playerStartX, playerStartY);
    velocity.setValues(minForwardSpeed, 0);
    thrustingUp = false;
    thrustingDown = false;
    thrustBlend = 0;
    dead = false;
    visualAngle = 0;
    _trail.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Frozen both after death and during the pre-run countdown — the
    // player sits idle in view while "3, 2, 1" counts down.
    if (dead || !game.isRunning) return;

    // Rise/dive ease toward their target speed (rather than accelerating
    // linearly into a hard cap), so starting a hold, letting go, or
    // dragging straight from one zone to the other all feel like one
    // smooth curve instead of a snap.
    final easeT = 1 - exp(-thrustEaseRate * dt);
    if (thrustingUp) {
      velocity.y += (-maxRiseSpeed - velocity.y) * easeT;
      thrustBlend += (1 - thrustBlend) * easeT;
    } else if (thrustingDown) {
      velocity.y += (maxDiveSpeed - velocity.y) * easeT;
      thrustBlend += (-1 - thrustBlend) * easeT;
    } else {
      velocity.y += gravity * game.gravityScale * dt;
      if (velocity.y > maxFallSpeed) {
        velocity.y = maxFallSpeed;
      }
      thrustBlend += (0 - thrustBlend) * easeT;
    }

    // Eases both up (ramping into a fresh distance-based cap, or a speed
    // boost kicking in) and down (a speed boost wearing off) — the target
    // isn't monotonic once power-ups are in play.
    final forwardTarget = game.currentForwardSpeed;
    if (velocity.x < forwardTarget) {
      velocity.x = min(forwardTarget, velocity.x + forwardAccel * dt);
    } else if (velocity.x > forwardTarget) {
      velocity.x = max(forwardTarget, velocity.x - forwardAccel * dt);
    }

    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    final targetAngle = velocity.length > 12
        ? atan2(velocity.y, velocity.x)
        : visualAngle;
    var delta = targetAngle - visualAngle;
    while (delta > pi) {
      delta -= 2 * pi;
    }
    while (delta < -pi) {
      delta += 2 * pi;
    }
    visualAngle += delta * min(1, dt * 10);

    _trailTimer -= dt;
    if (_trailTimer <= 0) {
      _trailTimer = 0.02;
      _trail.add(position.clone());
      if (_trail.length > 14) {
        _trail.removeAt(0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Speed lines when moving fast (drawn behind the body, in local space).
    final speed = velocity.length;
    if (speed > 620) {
      final dir = velocity.normalized();
      _speedLinePaint.color = Colors.white.withValues(
        alpha: (0.15 + (speed - 620) / 2000).clamp(0.0, 0.45),
      );
      for (var i = 0; i < 3; i++) {
        final offset = Offset(
          -dir.x * (18.0 + i * 10) + playerRadius,
          -dir.y * (18.0 + i * 10) + playerRadius - 6 + i * 6.0,
        );
        canvas.drawLine(
          offset,
          offset - Offset(dir.x, dir.y) * 16,
          _speedLinePaint,
        );
      }
    }

    canvas.save();
    canvas.translate(playerRadius, playerRadius);
    canvas.rotate(visualAngle);

    // Soft contact shadow, offset opposite the current thrust so the body
    // reads as lifting off it while rising/diving.
    canvas.drawCircle(
      Offset(0, playerRadius * 0.35 - thrustBlend * 6),
      playerRadius * 0.85,
      _shadowPaint,
    );

    // A gentle stretch along the thrust axis — squashes wide when idle,
    // stretches tall under a strong rise/dive — sells the smooth easing
    // in the underlying motion rather than looking rigid.
    final stretch = thrustBlend.abs() * 0.16;
    canvas.save();
    canvas.scale(1 - stretch, 1 + stretch);

    canvas.drawCircle(Offset.zero, playerRadius, _bodyPaint);
    canvas.drawCircle(Offset.zero, playerRadius, _outlinePaint);
    canvas.drawCircle(
      Offset(playerRadius * 0.15, playerRadius * 0.25),
      playerRadius * 0.6,
      _bellyPaint,
    );
    canvas.restore();

    // Eyes counter-rotate a bit for a friendly "googly eye" feel.
    canvas.save();
    canvas.rotate(-visualAngle * 0.6);
    const eyeOffset = Offset(6, -6);
    canvas.drawCircle(eyeOffset, 6, _eyePaint);
    canvas.drawCircle(eyeOffset + const Offset(1.5, 1), 3, _pupilPaint);
    canvas.restore();

    canvas.restore();

    // Fading trail.
    for (var i = 0; i < _trail.length; i++) {
      final t = i / _trail.length;
      final p =
          _trail[i] - position + Vector2(playerRadius, playerRadius);
      _trailPaint.color = _trailColor.withValues(alpha: t * 0.25);
      canvas.drawCircle(p.toOffset(), playerRadius * 0.5 * t, _trailPaint);
    }
  }
}
