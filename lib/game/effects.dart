import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

final _random = Random();

/// A little burst of particles, reused when a thrust zone engages and for
/// coin pickups. Kept intentionally lightweight (small counts, short
/// lifespans) so the game stays visually clean under 60 FPS.
ParticleSystemComponent burst({
  required Vector2 position,
  required Color color,
  int count = 10,
  double speed = 140,
  double radius = 3,
  double lifespan = 0.45,
}) {
  return ParticleSystemComponent(
    position: position,
    priority: 30,
    particle: Particle.generate(
      count: count,
      lifespan: lifespan,
      generator: (i) {
        final angle = _random.nextDouble() * pi * 2;
        final mag = speed * (0.4 + _random.nextDouble() * 0.6);
        return AcceleratedParticle(
          speed: Vector2(cos(angle), sin(angle)) * mag,
          acceleration: Vector2(0, 260),
          child: CircleParticle(
            radius: radius * (0.6 + _random.nextDouble() * 0.6),
            paint: Paint()..color = color,
          ),
        );
      },
    ),
  );
}

