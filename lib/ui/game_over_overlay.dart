import 'package:flutter/material.dart';

import '../game/game_status.dart';
import '../game/hook_it_game.dart';
import 'daily_challenge_banner.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2430),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            DailyChallengeBanner(game: game),
            ValueListenableBuilder<int>(
              valueListenable: game.distanceMeters,
              builder: (context, distance, _) => Text(
                '$distance m',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD23F),
                ),
              ),
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<int>(
              valueListenable: game.coins,
              builder: (context, coins, _) => Text(
                '$coins Coins',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder<int>(
              valueListenable: game.coinBalance,
              builder: (context, balance, _) => Text(
                'Total: $balance 🪙',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<GameMode>(
              valueListenable: game.mode,
              builder: (context, mode, _) {
                if (mode == GameMode.levels) {
                  return ValueListenableBuilder<int>(
                    valueListenable: game.currentLevel,
                    builder: (context, level, _) => Column(
                      children: [
                        Text(
                          'LEVEL $level GOAL',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.currentLevelTarget} m',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (mode == GameMode.coins) {
                  return ValueListenableBuilder<int>(
                    valueListenable: game.currentCoinLevel,
                    builder: (context, level, _) => Column(
                      children: [
                        Text(
                          'CHALLENGE $level GOAL',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.currentCoinTarget} 🪙',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListenableBuilder(
                  listenable: Listenable.merge([game.distanceMeters, game.best]),
                  builder: (context, _) {
                    final isNewBest = game.distanceMeters.value >= game.best.value &&
                        game.distanceMeters.value > 0;
                    return Column(
                      children: [
                        Text(
                          isNewBest ? 'NEW BEST!' : 'BEST',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isNewBest ? const Color(0xFF7CFF6B) : Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.best.value} m',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),
            ValueListenableBuilder<GameMode>(
              valueListenable: game.mode,
              builder: (context, mode, _) {
                if (mode == GameMode.levels) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: game.retryLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD23F),
                            foregroundColor: const Color(0xFF3A2E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'RETRY',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: game.showLevelSelect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'LEVELS',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (mode == GameMode.coins) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: game.retryCoinChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9F43),
                            foregroundColor: const Color(0xFF3A2E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'RETRY',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: game.showCoinLevelSelect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'CHALLENGES',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: game.startEndless,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD23F),
                          foregroundColor: const Color(0xFF3A2E1E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'TRY AGAIN',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: game.showStartScreen,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'MENU',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
