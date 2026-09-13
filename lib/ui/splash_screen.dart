import 'dart:math';

import 'package:flutter/material.dart';

import 'game_screen.dart';

/// The very first thing a player sees: the hero ball swoops in, "HOOK IT"
/// pops in with a bouncy reveal, then the tagline settles in — all timed
/// to land right as the background finishes shifting from night into the
/// game's signature teal, foreshadowing the in-game day/night palette
/// shift. Auto-advances to [GameScreen]; tapping skips straight there.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _idle;

  late final Animation<double> _ballFlight;
  late final Animation<double> _burst;
  late final Animation<double> _titlePop;
  late final Animation<double> _titleFade;
  late final Animation<double> _tagline;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _ballFlight = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );
    _burst = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.42, 0.62, curve: Curves.easeOut),
    );
    _titlePop = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.8, curve: Curves.elasticOut),
    );
    _titleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
    );
    _tagline = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.62, 0.9, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 2400), _goToGame);
  }

  void _goToGame() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120E2E),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToGame,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return AnimatedBuilder(
              animation: Listenable.merge([_intro, _idle]),
              builder: (context, _) => Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(size),
                  CustomPaint(
                    size: size,
                    painter: _HillPainter(),
                  ),
                  _buildBurst(size),
                  _buildBall(size),
                  _buildTitleBlock(size),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackground(Size size) {
    final t = _intro.value.clamp(0.0, 1.0);
    final top = Color.lerp(const Color(0xFF120E2E), const Color(0xFF2E7D6B), t)!;
    final bottom = Color.lerp(const Color(0xFF3A2E5C), const Color(0xFF1B4B6B), t)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
    );
  }

  Offset _ballPosition(Size size) {
    final start = Offset(size.width * 0.15, size.height * 1.1);
    final control = Offset(size.width * 0.22, size.height * -0.08);
    final end = Offset(size.width * 0.5 - 26, size.height * 0.30);
    final t = _ballFlight.value;
    final oneMinusT = 1 - t;
    return Offset(
      oneMinusT * oneMinusT * start.dx +
          2 * oneMinusT * t * control.dx +
          t * t * end.dx,
      oneMinusT * oneMinusT * start.dy +
          2 * oneMinusT * t * control.dy +
          t * t * end.dy,
    );
  }

  Widget _buildBurst(Size size) {
    if (_burst.value <= 0) return const SizedBox.shrink();
    final center = _ballPosition(size) + const Offset(26, 26);
    final progress = _burst.value;
    final children = <Widget>[];
    const count = 10;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * pi * 2;
      final radius = 12 + progress * 36;
      final pos = center + Offset(cos(angle), sin(angle)) * radius;
      children.add(
        Positioned(
          left: pos.dx - 3,
          top: pos.dy - 3,
          child: Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF7CFF6B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget _buildBall(Size size) {
    final landedFactor = Interval(0.55, 0.75, curve: Curves.easeOut)
        .transform(_intro.value.clamp(0.0, 1.0));
    final bob = (sin(_idle.value * pi) - 0.5) * 6 * landedFactor;
    final pos = _ballPosition(size) + Offset(0, bob);
    final tRaw = _ballFlight.value.clamp(0.0, 1.0);
    final angle = -0.5 * (1 - tRaw);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.35, -0.4),
              radius: 1.1,
              colors: [Color(0xFFFFF0B0), Color(0xFFFFD23F), Color(0xFFF2A81C)],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(color: const Color(0xFF3A2E1E), width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Align(
            alignment: const Alignment(-0.1, -0.4),
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: const Alignment(0.3, 0.3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF20242C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBlock(Size size) {
    final scale = _titlePop.value.clamp(0.0, 1.35);
    final titleOpacity = _titleFade.value.clamp(0.0, 1.0);
    final tagOpacity = _tagline.value.clamp(0.0, 1.0);
    final tagSlide = (1 - _tagline.value.clamp(0.0, 1.0)) * 14;

    return Align(
      alignment: const Alignment(0, 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: titleOpacity,
            child: Transform.scale(
              scale: scale,
              child: const Text(
                'HOOK IT',
                style: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Opacity(
            opacity: tagOpacity,
            child: Transform.translate(
              offset: Offset(0, tagSlide),
              child: const Text(
                'RISE  •  DIVE  •  SURVIVE',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: Color(0xFFFFD23F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static decorative hill silhouettes at the bottom, matching the in-game
/// background's art style so the splash feels like part of the same
/// world rather than a bolted-on loading screen.
class _HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _hill(canvas, size, baseFrac: 0.78, amplitude: 26, color: const Color(0x338FD3C7));
    _hill(canvas, size, baseFrac: 0.85, amplitude: 20, color: const Color(0x445AB894));
  }

  void _hill(
    Canvas canvas,
    Size size, {
    required double baseFrac,
    required double amplitude,
    required Color color,
  }) {
    final paint = Paint()..color = color;
    final baseY = size.height * baseFrac;
    final path = Path()..moveTo(0, size.height);
    const steps = 10;
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = baseY - amplitude * (0.5 + 0.5 * sin(i * 0.9));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
