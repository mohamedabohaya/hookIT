import 'dart:async';

import 'package:flutter/material.dart';

import '../game/game_status.dart';
import '../game/hook_it_game.dart';

/// Always-on HUD: distance (or goal progress, in Level mode) + stage
/// top-left, coins (+best/level) top-right, and a brief "STAGE UP" banner
/// whenever the background stage changes.
class HudOverlay extends StatefulWidget {
  const HudOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  int? _lastStage;
  bool _showBanner = false;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _lastStage = widget.game.stage.value;
    widget.game.stage.addListener(_onStageChanged);
  }

  void _onStageChanged() {
    final stage = widget.game.stage.value;
    if (_lastStage != null && stage != _lastStage) {
      _bannerTimer?.cancel();
      setState(() => _showBanner = true);
      _bannerTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _showBanner = false);
      });
    }
    _lastStage = stage;
  }

  @override
  void dispose() {
    widget.game.stage.removeListener(_onStageChanged);
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<GameMode>(
                      valueListenable: game.mode,
                      builder: (context, mode, _) => ValueListenableBuilder<int>(
                        valueListenable: game.distanceMeters,
                        builder: (context, distance, _) => _Pill(
                          child: Text(
                            mode == GameMode.levels
                                ? '$distance / ${game.currentLevelTarget} m'
                                : '$distance m',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: game.stage,
                      builder: (context, stage, _) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Stage $stage',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder<GameMode>(
                      valueListenable: game.mode,
                      builder: (context, mode, _) => ValueListenableBuilder<int>(
                        valueListenable: game.coins,
                        builder: (context, coins, _) => _Pill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                mode == GameMode.coins
                                    ? '$coins / ${game.currentCoinTarget}'
                                    : '$coins',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<GameMode>(
                      valueListenable: game.mode,
                      builder: (context, mode, _) {
                        if (mode == GameMode.levels) {
                          return ValueListenableBuilder<int>(
                            valueListenable: game.currentLevel,
                            builder: (context, level, _) => Text(
                              'Level $level',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        if (mode == GameMode.coins) {
                          return ValueListenableBuilder<int>(
                            valueListenable: game.currentCoinLevel,
                            builder: (context, level, _) => Text(
                              'Challenge $level',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return ValueListenableBuilder<int>(
                          valueListenable: game.best,
                          builder: (context, best, _) => Text(
                            'Best: $best m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                  ],
                ),
                const SizedBox(height: 8),
                _BuffChipsRow(game: game),
              ],
            ),
          ),
        ),
        Positioned(
          top: 136,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: AnimatedOpacity(
                opacity: _showBanner ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: AnimatedSlide(
                  offset: _showBanner ? Offset.zero : const Offset(0, -0.3),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: ValueListenableBuilder<int>(
                    valueListenable: game.stage,
                    builder: (context, stage, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2430).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF7CFF6B),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'STAGE $stage',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Color(0xFF7CFF6B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 18),
                child: ValueListenableBuilder<double?>(
                  valueListenable: game.gapHintOffset,
                  builder: (context, offset, _) {
                    if (offset == null) return const SizedBox.shrink();
                    return _GapHintArrow(pointingDown: offset > 0);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouncing arrow near the right edge of the screen, pointing up or down
/// toward the next unlit wall gap's opening — appears purely from game
/// state (see [HookItGame.gapHintOffset]), so it can warn the player
/// before the wall is close enough to clearly read.
class _GapHintArrow extends StatefulWidget {
  const _GapHintArrow({required this.pointingDown});

  final bool pointingDown;

  @override
  State<_GapHintArrow> createState() => _GapHintArrowState();
}

class _GapHintArrowState extends State<_GapHintArrow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bob = (widget.pointingDown ? 1 : -1) * _controller.value * 8;
        return Transform.translate(
          offset: Offset(0, bob),
          child: Opacity(opacity: 0.55 + 0.45 * _controller.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2430).withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFC94A), width: 1.5),
        ),
        child: Icon(
          widget.pointingDown
              ? Icons.keyboard_double_arrow_down_rounded
              : Icons.keyboard_double_arrow_up_rounded,
          color: const Color(0xFFFFC94A),
          size: 26,
        ),
      ),
    );
  }
}

/// Compact countdown badges for the active [HookItGame.coinMultiplierTimeLeft]
/// / [HookItGame.speedBoostTimeLeft] buffs — hidden entirely when neither is
/// active.
class _BuffChipsRow extends StatelessWidget {
  const _BuffChipsRow({required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: game.coinMultiplierTimeLeft,
          builder: (context, t, _) => t > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _BuffChip(
                    label: '2× COINS',
                    seconds: t,
                    color: const Color(0xFF9B6BFF),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        ValueListenableBuilder<double>(
          valueListenable: game.speedBoostTimeLeft,
          builder: (context, t, _) => t > 0
              ? _BuffChip(
                  label: 'SPEED BOOST',
                  seconds: t,
                  color: const Color(0xFF2FE6FF),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BuffChip extends StatelessWidget {
  const _BuffChip({required this.label, required this.seconds, required this.color});

  final String label;
  final double seconds;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white70, width: 1),
      ),
      child: Text(
        '$label ${seconds.ceil()}s',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
