import 'package:flutter/material.dart';

import '../game/hook_it_game.dart';

/// One-time "Daily Challenge Complete!" banner shown on the Game Over /
/// Level Complete screens right after the challenge was cleared *this
/// run* — see [HookItGame.dailyChallengeJustCompleted].
class DailyChallengeBanner extends StatelessWidget {
  const DailyChallengeBanner({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.dailyChallengeJustCompleted,
      builder: (context, justCompleted, _) {
        if (!justCompleted) return const SizedBox.shrink();
        final reward = game.dailyChallenge.value?.reward ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF7CFF6B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF7CFF6B)),
          ),
          child: Text(
            'DAILY CHALLENGE COMPLETE! +$reward 🪙',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7CFF6B),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        );
      },
    );
  }
}
