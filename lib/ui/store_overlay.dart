import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game/constants.dart';
import '../game/daily_content.dart';
import '../game/hook_it_game.dart';
import '../game/store_items.dart';

/// The Store screen — spend the coin balance on ball skins and world
/// "maps". Reachable from the start screen; purchases and equips persist
/// immediately via [HookItGame].
class StoreOverlay extends StatefulWidget {
  const StoreOverlay({super.key, required this.game});

  final HookItGame game;

  @override
  State<StoreOverlay> createState() => _StoreOverlayState();
}

class _StoreOverlayState extends State<StoreOverlay> {
  int _tab = 0; // 0 = characters, 1 = maps, 2 = spin, 3 = hearts

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120B29), Color(0xFF1B1440), Color(0xFF241154)],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: -60, left: -50, child: _Glow(color: Color(0xFF7C4DFF), size: 240)),
          const Positioned(bottom: -90, right: -70, child: _Glow(color: Color(0xFFFFD23F), size: 280)),
          const Positioned(top: 220, right: -80, child: _Glow(color: Color(0xFF2FE6FF), size: 200)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: game.showStartScreen,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        iconSize: 26,
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.storefront_rounded, color: Color(0xFFFFD23F), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'STORE',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<int>(
                        valueListenable: game.coinBalance,
                        builder: (context, balance, _) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD23F).withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '$balance',
                                style: const TextStyle(
                                  fontSize: 16,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'SKINS',
                          icon: Icons.face_retouching_natural_rounded,
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TabButton(
                          label: 'MAPS',
                          icon: Icons.public_rounded,
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: game.spinAvailableToday,
                          builder: (context, available, _) => _TabButton(
                            label: 'SPIN',
                            icon: Icons.casino_rounded,
                            selected: _tab == 2,
                            showDot: available,
                            onTap: () => setState(() => _tab = 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TabButton(
                          label: 'HEARTS',
                          icon: Icons.favorite_rounded,
                          selected: _tab == 3,
                          onTap: () => setState(() => _tab = 3),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    0 => _CharacterGrid(game: game),
                    1 => _MapGrid(game: game),
                    2 => _SpinTab(game: game),
                    _ => _HeartsTab(game: game),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft ambient glow blob — cheap decoration (a plain radial gradient, no
/// blur filter) used to give the Store's background some depth.
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.showDot = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? const Color(0xFF3A2E1E) : Colors.white70;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD23F) : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [BoxShadow(color: const Color(0xFFFFD23F).withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: fg),
                  ),
                ],
              ),
              if (showDot)
                Positioned(
                  top: -6,
                  right: 18,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(color: Color(0xFFFF5C5C), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterGrid extends StatelessWidget {
  const _CharacterGrid({required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        game.unlockedCharacterIds,
        game.selectedCharacterId,
        game.coinBalance,
      ]),
      builder: (context, _) {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: characterSkins.length,
          itemBuilder: (context, index) {
            final skin = characterSkins[index];
            final owned = game.unlockedCharacterIds.value.contains(skin.id);
            final equipped = game.selectedCharacterId.value == skin.id;
            return _StoreTile(
              name: skin.name,
              price: skin.price,
              owned: owned,
              equipped: equipped,
              canAfford: game.coinBalance.value >= skin.price,
              preview: _CharacterPreview(skin: skin),
              onTap: () => _handleTap(context, skin, owned, equipped),
            );
          },
        );
      },
    );
  }

  void _handleTap(BuildContext context, CharacterSkin skin, bool owned, bool equipped) {
    if (equipped) return;
    if (owned) {
      game.selectCharacter(skin.id);
      return;
    }
    if (game.coinBalance.value < skin.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins'), duration: Duration(seconds: 2)),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => _PurchaseDialog(
        name: skin.name,
        price: skin.price,
        onConfirm: () {
          game.purchaseCharacter(skin);
          game.selectCharacter(skin.id);
        },
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  const _MapGrid({required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        game.unlockedMapIds,
        game.selectedMapId,
        game.coinBalance,
      ]),
      builder: (context, _) {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: mapThemes.length,
          itemBuilder: (context, index) {
            final map = mapThemes[index];
            final owned = game.unlockedMapIds.value.contains(map.id);
            final equipped = game.selectedMapId.value == map.id;
            return _StoreTile(
              name: map.name,
              price: map.price,
              owned: owned,
              equipped: equipped,
              canAfford: game.coinBalance.value >= map.price,
              preview: _MapPreview(map: map),
              onTap: () => _handleTap(context, map, owned, equipped),
            );
          },
        );
      },
    );
  }

  void _handleTap(BuildContext context, MapTheme map, bool owned, bool equipped) {
    if (equipped) return;
    if (owned) {
      game.selectMap(map.id);
      return;
    }
    if (game.coinBalance.value < map.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins'), duration: Duration(seconds: 2)),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => _PurchaseDialog(
        name: map.name,
        price: map.price,
        onConfirm: () {
          game.purchaseMap(map);
          game.selectMap(map.id);
        },
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.name,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.preview,
    required this.onTap,
  });

  final String name;
  final int price;
  final bool owned;
  final bool equipped;
  final bool canAfford;
  final Widget preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = equipped
        ? const Color(0xFF7CFF6B).withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.08);
    final borderColor = equipped
        ? const Color(0xFF7CFF6B)
        : owned
            ? Colors.white38
            : (canAfford ? const Color(0xFFFFD23F) : Colors.white24);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              preview,
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              if (equipped)
                const Text(
                  'EQUIPPED',
                  style: TextStyle(
                    color: Color(0xFF7CFF6B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                )
              else if (owned)
                const Text(
                  'TAP TO EQUIP',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$price',
                      style: TextStyle(
                        color: canAfford ? const Color(0xFFFFD23F) : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterPreview extends StatelessWidget {
  const _CharacterPreview({required this.skin});

  final CharacterSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.1,
          colors: skin.bodyColors,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: skin.outlineColor, width: 2),
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(shape: BoxShape.circle, color: skin.bellyColor),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.map});

  final MapTheme map;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: map.previewColors,
        ),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
    );
  }
}

class _PurchaseDialog extends StatelessWidget {
  const _PurchaseDialog({required this.name, required this.price, required this.onConfirm});

  final String name;
  final int price;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2430),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Buy $name?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('$price coins', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('BUY', style: TextStyle(color: Color(0xFFFFD23F), fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

/// Free once-a-day spin-the-wheel. Landing segment is decided up front by
/// [HookItGame.pickSpinRewardIndex] — the animation just spins to it, so
/// there's no risk of the visual and the actual payout disagreeing.
class _SpinTab extends StatefulWidget {
  const _SpinTab({required this.game});

  final HookItGame game;

  @override
  State<_SpinTab> createState() => _SpinTabState();
}

class _SpinTabState extends State<_SpinTab> with TickerProviderStateMixin {
  late final AnimationController _spinController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  /// Idle "breathing" glow/scale behind the wheel, and the pulse on the
  /// SPIN button — purely decorative, always running.
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  Animation<double>? _spinAnimation;
  int? _resultIndex;
  bool _spinning = false;
  bool _revealed = false;

  Timer? _countdownTimer;
  Duration _timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (!widget.game.spinAvailableToday.value) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    if (mounted) setState(() => _timeUntilReset = nextMidnight.difference(now));
  }

  void _spin() {
    final game = widget.game;
    if (!game.spinAvailableToday.value || _spinning) return;

    final index = game.pickSpinRewardIndex();
    final segAngle = 2 * pi / spinWheelValues.length;
    final targetCenter = index * segAngle + segAngle / 2;
    const spins = 6;
    final targetAngle = spins * 2 * pi - targetCenter;

    _spinAnimation = Tween<double>(begin: 0, end: targetAngle)
        .animate(CurvedAnimation(parent: _spinController, curve: Curves.easeOutQuart));
    setState(() {
      _spinning = true;
      _resultIndex = index;
      _revealed = false;
    });
    _spinController.forward(from: 0).whenComplete(() {
      game.claimSpinReward(index);
      if (mounted) {
        setState(() {
          _spinning = false;
          _revealed = true;
        });
        _startCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD23F), Color(0xFFFF9F43)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFFD23F).withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 1),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino_rounded, color: Color(0xFF3A2E1E), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'FREE DAILY SPIN',
                    style: TextStyle(
                      color: Color(0xFF3A2E1E),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = _pulseController.value;
                return Container(
                  width: 250,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD23F).withValues(alpha: 0.22 + 0.14 * glow),
                        blurRadius: 34 + 18 * glow,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: _spinning ? 1.0 : 1.0 + 0.012 * glow,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => CustomPaint(
                        size: const Size(240, 240),
                        painter: _WheelPainter(values: spinWheelValues, twinkle: _pulseController.value),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _spinAnimation ?? const AlwaysStoppedAnimation(0.0),
                      builder: (context, child) => Transform.rotate(
                        angle: _spinAnimation?.value ?? 0,
                        child: child,
                      ),
                      child: CustomPaint(
                        size: const Size(220, 220),
                        painter: const _WheelSlicesPainter(values: spinWheelValues),
                      ),
                    ),
                    // Fixed hub — drawn on top, doesn't rotate with the wheel.
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFE9A8), Color(0xFFFFC94A)],
                        ),
                        border: Border.all(color: const Color(0xFF3A2E1E), width: 2.5),
                        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🪙', style: TextStyle(fontSize: 22)),
                    ),
                    const Positioned(
                      top: -4,
                      child: CustomPaint(size: Size(30, 26), painter: _PointerPainter()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 78,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: _buildActionArea(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (_revealed && _resultIndex != null) {
      return _WinCard(key: const ValueKey('win'), amount: spinWheelValues[_resultIndex!]);
    }
    return ValueListenableBuilder<bool>(
      key: const ValueKey('action'),
      valueListenable: widget.game.spinAvailableToday,
      builder: (context, available, _) {
        if (!available) {
          return _CountdownPill(remaining: _timeUntilReset);
        }
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glow = _spinning ? 0.0 : _pulseController.value;
            return Transform.scale(scale: 1.0 + 0.03 * glow, child: child);
          },
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: !_spinning ? _spin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD23F),
                foregroundColor: const Color(0xFF3A2E1E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 8,
                shadowColor: const Color(0xFFFFD23F).withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
                'SPIN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Countdown shown once today's spin is used — "come back tomorrow" backed
/// by a live ticking clock, so the reset feels concrete rather than vague.
class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    final clock = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'NEXT SPIN IN',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 2),
          Text(
            clock,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouncy "AWESOME! +N 🪙" reveal shown right after a spin lands.
class _WinCard extends StatefulWidget {
  const _WinCard({super.key, required this.amount});

  final int amount;

  @override
  State<_WinCard> createState() => _WinCardState();
}

class _WinCardState extends State<_WinCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7CFF6B), Color(0xFF3FCE7A)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: const Color(0xFF7CFF6B).withValues(alpha: 0.4), blurRadius: 22, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AWESOME!',
              style: TextStyle(color: Color(0xFF123321), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${widget.amount}',
                  style: const TextStyle(color: Color(0xFF123321), fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 6),
                const Text('🪙', style: TextStyle(fontSize: 22)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the static ring behind the wheel — a gold rim plus a circle of
/// alternating "marquee lights", their brightness tied to [twinkle] so
/// they twinkle in and out with the idle breathing animation.
class _WheelPainter extends CustomPainter {
  const _WheelPainter({required this.values, required this.twinkle});

  final List<int> values;
  final double twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFFFC94A);
    canvas.drawCircle(center, outerRadius - 3, rimPaint);

    const studCount = 20;
    for (var i = 0; i < studCount; i++) {
      final angle = (2 * pi / studCount) * i;
      final lit = i.isEven ? twinkle : (1 - twinkle);
      final pos = center + Offset(cos(angle), sin(angle)) * (outerRadius - 3);
      final studPaint = Paint()
        ..color = Color.lerp(const Color(0xFF7A5A12), const Color(0xFFFFF3C4), lit)!;
      canvas.drawCircle(pos, 3.4, studPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => oldDelegate.twinkle != twinkle;
}

/// Draws the actual colored, labeled slices — kept separate from
/// [_WheelPainter] so only this layer needs to rotate during a spin.
class _WheelSlicesPainter extends CustomPainter {
  const _WheelSlicesPainter({required this.values});

  final List<int> values;

  static const _colors = [
    Color(0xFFFFD23F),
    Color(0xFF7CFF6B),
    Color(0xFF2FE6FF),
    Color(0xFF9B6BFF),
    Color(0xFFFF9F43),
    Color(0xFFFF5C5C),
    Color(0xFF29B6F6),
    Color(0xFFAB47BC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segAngle = 2 * pi / values.length;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final slicePaint = Paint()..style = PaintingStyle.fill;
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF1E2430);

    for (var i = 0; i < values.length; i++) {
      slicePaint.color = _colors[i % _colors.length];
      final startAngle = -pi / 2 + i * segAngle;
      canvas.drawArc(rect, startAngle, segAngle, true, slicePaint);
      canvas.drawArc(rect, startAngle, segAngle, true, dividerPaint);
    }

    // A single shared glossy highlight (rather than per-slice) — cheap and
    // reads as a glass dome over the whole wheel.
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.5),
        radius: 0.9,
        colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, shinePaint);

    for (var i = 0; i < values.length; i++) {
      final startAngle = -pi / 2 + i * segAngle;
      final labelAngle = startAngle + segAngle / 2;
      final labelPos = center + Offset(cos(labelAngle), sin(labelAngle)) * radius * 0.65;
      final tp = TextPainter(
        text: TextSpan(
          text: '${values[i]}',
          style: const TextStyle(color: Color(0xFF1E2430), fontSize: 15, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(center, radius, dividerPaint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _WheelSlicesPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE9A8), Color(0xFFFFC94A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF3A2E1E);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}

/// Buy spare lives with coins. Unlike character/map unlocks, hearts are a
/// consumable — both offers here are repeatable rather than one-time.
class _HeartsTab extends StatelessWidget {
  const _HeartsTab({required this.game});

  final HookItGame game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8FA3), Color(0xFFFF5C7A)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF5C7A).withValues(alpha: 0.4), blurRadius: 22, spreadRadius: 1),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('❤️', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<int>(
            valueListenable: game.heartBalance,
            builder: (context, hearts, _) => Text(
              'You have $hearts ${hearts == 1 ? "heart" : "hearts"}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Spend a heart to continue a run right where you lost it, instead of starting over.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: _HeartBuyTile(
                    label: '1',
                    price: heartPrice,
                    onTap: () => _buy(context, 1, heartPrice),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _HeartBuyTile(
                    label: '$heartBundleCount',
                    price: heartBundlePrice,
                    highlight: true,
                    onTap: () => _buy(context, heartBundleCount, heartBundlePrice),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context, int count, int price) {
    if (game.coinBalance.value < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins'), duration: Duration(seconds: 2)),
      );
      return;
    }
    game.purchaseHearts(count: count, price: price);
  }
}

class _HeartBuyTile extends StatelessWidget {
  const _HeartBuyTile({
    required this.label,
    required this.price,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final int price;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? const Color(0xFFFF5C7A).withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: highlight ? const Color(0xFFFF5C7A) : Colors.white24, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label ❤️',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '$price',
                    style: const TextStyle(color: Color(0xFFFFD23F), fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
