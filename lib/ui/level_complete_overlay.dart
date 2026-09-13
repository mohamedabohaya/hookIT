import 'package:flutter/material.dart';

import '../game/coin_challenges.dart';
import '../game/game_status.dart';
import '../game/hook_it_game.dart';
import '../game/levels.dart';
import 'daily_challenge_banner.dart';

/// Shown when a Level-mode or Coin-challenge stage is cleared. The goal
/// label, accent color, and next/back actions all depend on which
/// progression mode ([GameMode.levels] vs [GameMode.coins]) is active.
class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameMode>(
      valueListenable: game.mode,
      builder: (context, mode, _) {
        final isCoins = mode == GameMode.coins;
        final accent = isCoins ? const Color(0xFFFF9F43) : const Color(0xFF7CFF6B);
        return Container(
          alignment: Alignment.center,
          color: Colors.black54,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2430),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent, width: 1.5),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: isCoins ? game.currentCoinLevel : game.currentLevel,
              builder: (context, level, _) {
                final stageCount = isCoins ? coinLevelCount : levelCount;
                final isLastLevel = level >= stageCount;
                final noun = isCoins ? 'CHALLENGE' : 'LEVEL';
                final allClearedLabel = isCoins ? 'ALL CHALLENGES CLEARED!' : 'ALL LEVELS CLEARED!';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLastLevel ? allClearedLabel : '$noun $level COMPLETE!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: accent,
                        letterSpacing: 1,
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
                    const SizedBox(height: 28),
                    if (!isLastLevel)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => isCoins
                                ? game.startCoinChallenge(level + 1)
                                : game.startLevel(level + 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: const Color(0xFF3A2E1E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 6,
                            ),
                            child: Text(
                              isCoins ? 'NEXT CHALLENGE' : 'NEXT LEVEL',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isCoins ? game.showCoinLevelSelect : game.showLevelSelect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          isCoins ? 'CHALLENGES' : 'LEVELS',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
