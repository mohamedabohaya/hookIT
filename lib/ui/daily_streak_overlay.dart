import 'package:flutter/material.dart';

import '../game/hook_it_game.dart';

/// Blocking "come back tomorrow" reward popup — shown automatically once
/// per calendar day (see [HookItGame.streakClaimedToday]) on top of
/// whatever else is on screen. Claiming is the only way out.
class DailyStreakOverlay extends StatelessWidget {
  const DailyStreakOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    final day = game.pendingStreakDay;
    final reward = game.pendingStreakReward;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2430),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD23F), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DAILY REWARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Day $day streak',
              style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _StreakRow(day: day),
            const SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+$reward',
                  style: const TextStyle(
                    color: Color(0xFFFFD23F),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('🪙', style: TextStyle(fontSize: 26)),
                ),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: game.claimDailyStreak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD23F),
                  foregroundColor: const Color(0xFF3A2E1E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 6,
                ),
                child: const Text(
                  'CLAIM',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    final dayInCycle = ((day - 1) % 7) + 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final isToday = dayNum == dayInCycle;
        final isPast = dayNum < dayInCycle;
        final color = isToday
            ? const Color(0xFFFFD23F)
            : isPast
                ? const Color(0xFF7CFF6B)
                : Colors.white24;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            alignment: Alignment.center,
            child: isPast
                ? const Icon(Icons.check, size: 16, color: Color(0xFF1E2430))
                : Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isToday ? const Color(0xFF1E2430) : Colors.white54,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
