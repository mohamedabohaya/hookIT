import 'package:flutter/material.dart';

import '../game/coin_challenges.dart';
import '../game/daily_content.dart';
import '../game/hook_it_game.dart';
import '../game/levels.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC2E7D6B), Color(0xCC1B4B6B)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HOOK IT',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hold bottom to rise • Hold top to dive',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                _ModeButton(
                  label: 'ENDLESS',
                  subtitle: 'Fly as far as you can',
                  icon: Icons.all_inclusive_rounded,
                  color: const Color(0xFFFFD23F),
                  onTap: game.startEndless,
                ),
                const SizedBox(height: 16),
                _ModeButton(
                  label: 'LEVELS',
                  subtitle: 'Clear a stage to unlock the next',
                  icon: Icons.flag_rounded,
                  color: const Color(0xFF7CFF6B),
                  onTap: game.showLevelSelect,
                ),
                const SizedBox(height: 16),
                _ModeButton(
                  label: 'COIN RUSH',
                  subtitle: 'Collect the target to clear a stage',
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFFFF9F43),
                  onTap: game.showCoinLevelSelect,
                ),
                const SizedBox(height: 28),
                ValueListenableBuilder<int>(
                  valueListenable: game.best,
                  builder: (context, best, _) => Text(
                    'Best: $best m',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<int>(
                  valueListenable: game.highestUnlockedLevel,
                  builder: (context, unlocked, _) {
                    final cleared = (unlocked - 1).clamp(0, levelCount);
                    return Text(
                      'Levels cleared: $cleared / $levelCount',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                ValueListenableBuilder<int>(
                  valueListenable: game.highestUnlockedCoinLevel,
                  builder: (context, unlocked, _) {
                    final cleared = (unlocked - 1).clamp(0, coinLevelCount);
                    return Text(
                      'Coin challenges cleared: $cleared / $coinLevelCount',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _DailyChallengeCard(game: game),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Material(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: game.showStore,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: game.spinAvailableToday,
                          builder: (context, available, _) {
                            if (!available) return const SizedBox.shrink();
                            return Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5C5C),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1B4B6B), width: 2),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder<int>(
                      valueListenable: game.heartBalance,
                      builder: (context, hearts, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('❤️', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(
                              '$hearts',
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
                    const SizedBox(width: 10),
                    ValueListenableBuilder<int>(
                      valueListenable: game.coinBalance,
                      builder: (context, balance, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '$balance',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DailyChallenge?>(
      valueListenable: game.dailyChallenge,
      builder: (context, challenge, _) {
        if (challenge == null) return const SizedBox.shrink();
        return ValueListenableBuilder<bool>(
          valueListenable: game.dailyChallengeCompleted,
          builder: (context, completed, _) {
            final accent = completed ? const Color(0xFF7CFF6B) : const Color(0xFFFFD23F);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    completed ? Icons.check_circle_rounded : Icons.bolt_rounded,
                    color: accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${challenge.description} • +${challenge.reward} 🪙',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: completed ? accent : Colors.white,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF3A2E1E),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A2E1E).withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
