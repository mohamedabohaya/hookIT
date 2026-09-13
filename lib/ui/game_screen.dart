import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/coin_challenges.dart';
import '../game/game_status.dart';
import '../game/hook_it_game.dart';
import 'countdown_overlay.dart';
import 'daily_streak_overlay.dart';
import 'game_over_overlay.dart';
import 'hud_overlay.dart';
import 'level_complete_overlay.dart';
import 'level_select_overlay.dart';
import 'start_overlay.dart';
import 'store_overlay.dart';

/// Hosts the Flame [HookItGame] plus its Flutter-side overlays (start,
/// level select, HUD, game-over, level-complete).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final HookItGame _game = HookItGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget<HookItGame>(
              game: _game,
              initialActiveOverlays: const ['start'],
              overlayBuilderMap: {
                'start': (context, game) => StartOverlay(game: game),
                'levelSelect': (context, game) => LevelSelectOverlay(
                      game: game,
                      unlockedNotifier: game.highestUnlockedLevel,
                      onSelect: game.startLevel,
                    ),
                'coinLevelSelect': (context, game) => LevelSelectOverlay(
                      game: game,
                      title: 'CHALLENGES',
                      targets: coinTargets,
                      unitSuffix: '🪙',
                      unlockedNotifier: game.highestUnlockedCoinLevel,
                      onSelect: game.startCoinChallenge,
                    ),
                'countdown': (context, game) => CountdownOverlay(game: game),
                'store': (context, game) => StoreOverlay(game: game),
                'dailyStreak': (context, game) => DailyStreakOverlay(game: game),
                'gameOver': (context, game) => GameOverOverlay(game: game),
                'levelComplete': (context, game) => LevelCompleteOverlay(game: game),
              },
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<GameStatus>(
              valueListenable: _game.status,
              builder: (context, status, _) {
                if (status != GameStatus.playing) {
                  return const SizedBox.shrink();
                }
                return HudOverlay(game: _game);
              },
            ),
          ),
        ],
      ),
    );
  }
}
