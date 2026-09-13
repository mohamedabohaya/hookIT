import 'package:flutter/material.dart';

import '../game/hook_it_game.dart';
import '../game/levels.dart';

/// Grid of unlockable stages for a progression mode (Level-mode's target
/// distances, or Coin-challenge's target coin counts). Locked stages
/// (beyond [unlockedNotifier]'s current value) are shown dimmed with a
/// lock icon; tapping an unlocked one starts that stage directly.
class LevelSelectOverlay extends StatelessWidget {
  const LevelSelectOverlay({
    super.key,
    required this.game,
    this.title = 'LEVELS',
    this.targets = levelTargets,
    this.unitSuffix = 'm',
    required this.unlockedNotifier,
    required this.onSelect,
  });

  final HookItGame game;
  final String title;
  final List<int> targets;
  final String unitSuffix;
  final ValueNotifier<int> unlockedNotifier;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEE1B4B6B), Color(0xEE12314A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: game.showStartScreen,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: unlockedNotifier,
                builder: (context, unlocked, _) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: targets.length,
                    itemBuilder: (context, index) {
                      final levelIndex = index + 1;
                      final unlockedTile = levelIndex <= unlocked;
                      final cleared = levelIndex < unlocked;
                      return _LevelTile(
                        levelIndex: levelIndex,
                        target: targets[index],
                        unitSuffix: unitSuffix,
                        unlocked: unlockedTile,
                        cleared: cleared,
                        onTap: unlockedTile ? () => onSelect(levelIndex) : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.levelIndex,
    required this.target,
    required this.unitSuffix,
    required this.unlocked,
    required this.cleared,
    required this.onTap,
  });

  final int levelIndex;
  final int target;
  final String unitSuffix;
  final bool unlocked;
  final bool cleared;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = cleared
        ? const Color(0xFF7CFF6B)
        : unlocked
            ? const Color(0xFFFFD23F)
            : Colors.white.withValues(alpha: 0.12);
    final foreground = unlocked ? const Color(0xFF3A2E1E) : Colors.white54;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cleared)
              const Icon(Icons.check_circle, color: Color(0xFF3A2E1E), size: 20)
            else if (!unlocked)
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 20),
            const SizedBox(height: 2),
            Text(
              '$levelIndex',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
            Text(
              '$target $unitSuffix',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground.withValues(alpha: unlocked ? 0.75 : 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
