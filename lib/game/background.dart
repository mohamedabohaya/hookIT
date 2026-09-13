import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, LinearGradient;

import 'constants.dart';
import 'hook_it_game.dart';

/// A cheap, asset-free parallax backdrop: a sky gradient plus a few layers
/// of procedurally drawn hill silhouettes and clouds that scroll at
/// different speeds relative to the camera. Lives in [CameraComponent.
/// backdrop], so it renders in fixed screen space and we do the parallax
/// math ourselves from the camera's x position.
///
/// The color palette drifts smoothly from one theme to the next every
/// [metersPerLevel], cycling through the player's currently selected
/// [HookItGame.selectedMap] — a single-palette map just renders as a
/// static color, since lerping a palette with itself is a no-op. Paints
/// are reused across frames (colors just get mutated) to keep this cheap
/// to render every tick.
class Background extends Component with HasGameReference<HookItGame> {
  final Paint _skyPaint = Paint();
  final Paint _cloudPaint = Paint();
  final Paint _farPaint = Paint();
  final Paint _midPaint = Paint();
  final Paint _nearPaint = Paint();

  @override
  void render(Canvas canvas) {
    final cameraX = game.camera.viewfinder.position.x;
    final palettes = game.selectedMap.palettes;
    final levelFloat = game.distanceMeters.value / metersPerLevel;
    final index = levelFloat.floor();
    final t = levelFloat - index;
    final a = palettes[index % palettes.length];
    final b = palettes[(index + 1) % palettes.length];

    _skyPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(a.skyTop, b.skyTop, t)!,
        Color.lerp(a.skyBottom, b.skyBottom, t)!,
      ],
    ).createShader(const Rect.fromLTWH(0, 0, viewportWidth, viewportHeight));
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, viewportWidth, viewportHeight),
      _skyPaint,
    );

    _cloudPaint.color = Color.lerp(a.cloud, b.cloud, t)!;
    _drawClouds(canvas, cameraX);

    _farPaint.color = Color.lerp(a.far, b.far, t)!;
    _drawHillLayer(canvas, cameraX, factor: 0.25, baseY: 683, paint: _farPaint, amplitude: 85, wavelength: 340);
    _midPaint.color = Color.lerp(a.mid, b.mid, t)!;
    _drawHillLayer(canvas, cameraX, factor: 0.45, baseY: 780, paint: _midPaint, amplitude: 73, wavelength: 260);
    _nearPaint.color = Color.lerp(a.near, b.near, t)!;
    _drawHillLayer(canvas, cameraX, factor: 0.7, baseY: 878, paint: _nearPaint, amplitude: 61, wavelength: 220);
  }

  void _drawClouds(Canvas canvas, double cameraX) {
    const factor = 0.12;
    const spacing = 260.0;
    final offset = (cameraX * factor) % spacing;
    for (var i = -1; i < (viewportWidth / spacing).ceil() + 1; i++) {
      final x = i * spacing - offset;
      final y = 90 + 40 * sin(i * 1.7);
      canvas.drawCircle(Offset(x, y), 26, _cloudPaint);
      canvas.drawCircle(Offset(x + 26, y + 8), 20, _cloudPaint);
      canvas.drawCircle(Offset(x - 24, y + 10), 18, _cloudPaint);
    }
  }

  void _drawHillLayer(
    Canvas canvas,
    double cameraX,
    {
    required double factor,
    required double baseY,
    required Paint paint,
    required double amplitude,
    required double wavelength,
  }) {
    final offset = cameraX * factor;
    final path = Path()..moveTo(0, viewportHeight);
    // Coarse enough steps to stay cheap to rebuild every frame — these are
    // big, gently-curved shapes, so it stays visually smooth regardless.
    const steps = 14;
    for (var i = 0; i <= steps; i++) {
      final x = viewportWidth * i / steps;
      final worldX = x + offset;
      final y = baseY - amplitude * (0.5 + 0.5 * sin(worldX / wavelength));
      path.lineTo(x, y);
    }
    path.lineTo(viewportWidth, viewportHeight);
    path.close();
    canvas.drawPath(path, paint);
  }
}
