import 'package:flutter/material.dart';

import '../game/hook_it_game.dart';

/// Big "3, 2, 1" shown after picking a mode/level, before gameplay actually
/// starts — the world (and any obstacles already spawned ahead) sits
/// frozen and visible behind it, giving the player a beat to get ready.
class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: game.countdownValue,
          builder: (context, value, _) {
            return TweenAnimationBuilder<double>(
              key: ValueKey(value),
              tween: Tween(begin: 0.4, end: 1.0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Opacity(
                opacity: scale.clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 130,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 6)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
