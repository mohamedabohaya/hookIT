import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart' show DragDownInfo, DragUpdateInfo, DragEndInfo;
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Color, ValueNotifier;

import '../services/day_key.dart';
import '../services/storage_service.dart';
import 'background.dart';
import 'coin.dart';
import 'coin_challenges.dart';
import 'constants.dart';
import 'daily_content.dart';
import 'despawnable.dart';
import 'effects.dart';
import 'game_status.dart';
import 'level_generator.dart';
import 'levels.dart';
import 'obstacle.dart';
import 'player.dart';
import 'power_up.dart';
import 'store_items.dart';

/// Top-level Flame game for Hook It.
///
/// Owns the world, camera, player and level generator, and exposes a small
/// set of [ValueNotifier]s that the Flutter-side HUD/overlays listen to —
/// keeping presentation (widgets) cleanly separate from simulation
/// (components). Supports three [GameMode]s: unrestricted [GameMode.endless]
/// flight, a fixed, unlockable sequence of [GameMode.levels] with target
/// distances (see [levelTargets]), and a similar [GameMode.coins] sequence
/// with target coin counts (see [coinTargets]).
class HookItGame extends FlameGame with PanDetector {
  HookItGame() : super(camera: CameraComponent.withFixedResolution(
          width: viewportWidth,
          height: viewportHeight,
          backdrop: Background(),
        ));

  final StorageService storage = StorageService();
  final Random _rng = Random();

  final ValueNotifier<GameStatus> status = ValueNotifier(GameStatus.start);
  final ValueNotifier<GameMode> mode = ValueNotifier(GameMode.endless);
  final ValueNotifier<int> distanceMeters = ValueNotifier(0);

  /// Coins collected so far *this run* — resets every [_beginRun].
  final ValueNotifier<int> coins = ValueNotifier(0);
  final ValueNotifier<int> best = ValueNotifier(0);

  /// Total coins ever collected, across every run — the player's
  /// persistent balance, shown on the start screen.
  final ValueNotifier<int> coinBalance = ValueNotifier(0);

  /// Visual progress marker during an endless run (drives the background
  /// palette + a "STAGE UP" banner every [metersPerLevel]). Unrelated to
  /// [GameMode.levels] — that's a separate, unlockable set of goals.
  final ValueNotifier<int> stage = ValueNotifier(1);

  /// 1-based index into [levelTargets]. Only meaningful in
  /// [GameMode.levels].
  final ValueNotifier<int> currentLevel = ValueNotifier(1);

  /// 1-based index of the highest level the player may play. Level 1 is
  /// always unlocked; clearing level N unlocks N+1.
  final ValueNotifier<int> highestUnlockedLevel = ValueNotifier(1);

  /// 1-based index into [coinTargets]. Only meaningful in
  /// [GameMode.coins].
  final ValueNotifier<int> currentCoinLevel = ValueNotifier(1);

  /// 1-based index of the highest Coin-challenge stage the player may
  /// play. Stage 1 is always unlocked; clearing stage N unlocks N+1.
  final ValueNotifier<int> highestUnlockedCoinLevel = ValueNotifier(1);

  /// Seconds remaining on the active coin-multiplier buff, 0 when
  /// inactive. See [PowerUpKind.coinMultiplier].
  final ValueNotifier<double> coinMultiplierTimeLeft = ValueNotifier(0);

  /// Seconds remaining on the active speed-boost buff, 0 when inactive.
  /// See [PowerUpKind.speedBoost].
  final ValueNotifier<double> speedBoostTimeLeft = ValueNotifier(0);

  bool get coinMultiplierActive => coinMultiplierTimeLeft.value > 0;
  bool get speedBoostActive => speedBoostTimeLeft.value > 0;

  /// The number currently shown by the pre-run countdown ("3, 2, 1"). Only
  /// meaningful while [status] is [GameStatus.countdown].
  final ValueNotifier<int> countdownValue = ValueNotifier(3);
  double _countdownTime = 0;

  /// `gapCenterY - player.y` for the nearest upcoming [WallObstacle] within
  /// [gapHintLookahead], or null when there's nothing to steer toward
  /// (whether because none is close enough yet, or the player is already
  /// lined up with it). Drives the HUD's up/down gap-direction hint —
  /// purely data-driven, so it can flag a gap before the wall itself is
  /// close enough to clearly see.
  final ValueNotifier<double?> gapHintOffset = ValueNotifier(null);

  /// Store item ids the player owns, and which one is currently equipped.
  /// 'classic' is always in both unlocked lists — it's free and is the
  /// default look for a player who never opens the Store.
  final ValueNotifier<List<String>> unlockedCharacterIds = ValueNotifier(['classic']);
  final ValueNotifier<String> selectedCharacterId = ValueNotifier('classic');
  final ValueNotifier<List<String>> unlockedMapIds = ValueNotifier(['classic']);
  final ValueNotifier<String> selectedMapId = ValueNotifier('classic');

  CharacterSkin get selectedCharacter => characterSkins.firstWhere(
        (c) => c.id == selectedCharacterId.value,
        orElse: () => characterSkins.first,
      );

  MapTheme get selectedMap => mapThemes.firstWhere(
        (m) => m.id == selectedMapId.value,
        orElse: () => mapThemes.first,
      );

  // --- Daily engagement systems ---------------------------------------
  //
  // Three independent daily hooks, all keyed off the device's local
  // calendar date (see day_key.dart): a login streak, a rotating
  // single-run challenge, and a free spin-the-wheel.

  /// Length of the streak as of the last successful claim (0 before ever
  /// claimed). See [pendingStreakDay] and [claimDailyStreak].
  final ValueNotifier<int> streakCount = ValueNotifier(0);
  String? _streakLastClaimDate;

  /// True once today's streak reward has been claimed.
  final ValueNotifier<bool> streakClaimedToday = ValueNotifier(true);

  /// The streak day (1-based) that claiming right now would award — one
  /// more than the last claim if that was yesterday, otherwise a reset to
  /// day 1.
  int get pendingStreakDay {
    final today = todayKey();
    if (_streakLastClaimDate == today) return streakCount.value;
    if (_streakLastClaimDate == dayBefore(today)) return streakCount.value + 1;
    return 1;
  }

  int get pendingStreakReward => streakRewardFor(pendingStreakDay);

  /// Today's single-run challenge, regenerated once per calendar day.
  final ValueNotifier<DailyChallenge?> dailyChallenge = ValueNotifier(null);
  final ValueNotifier<bool> dailyChallengeCompleted = ValueNotifier(false);

  /// True for the rest of the current run's end screen only, right after
  /// the challenge was completed *this run* — lets the Game Over / Level
  /// Complete overlays show a one-time banner instead of every time the
  /// (already-completed) challenge is looked at.
  final ValueNotifier<bool> dailyChallengeJustCompleted = ValueNotifier(false);
  String? _dailyChallengeDate;

  /// Whether the free daily spin hasn't been used yet today.
  final ValueNotifier<bool> spinAvailableToday = ValueNotifier(false);
  String? _spinLastDate;

  late final Player player;
  late final LevelGenerator levelGenerator;

  final Vector2 _cameraBase = Vector2(
    playerStartX + cameraLookAheadX,
    playerStartY + cameraVerticalOffset,
  );
  // The world Y the camera is vertically "anchored" to. Only moves once the
  // player strays outside the deadzone band around it, so small rise/dive
  // corrections (lining up with a gap, dodging a spike) don't drag the
  // whole world around — only a sustained climb or dive scrolls it.
  double _cameraFocusY = playerStartY;
  double _shakeTime = 0;
  double _shakeDuration = 1;
  double _shakeMagnitude = 0;

  double _runTime = 0;

  bool get isRunning => status.value == GameStatus.playing;

  /// The distance (in meters) that clears the current level. Only
  /// meaningful in [GameMode.levels].
  int get currentLevelTarget =>
      levelTargets[(currentLevel.value - 1).clamp(0, levelTargets.length - 1)];

  /// The number of coins that clears the current Coin-challenge stage.
  /// Only meaningful in [GameMode.coins].
  int get currentCoinTarget =>
      coinTargets[(currentCoinLevel.value - 1).clamp(0, coinTargets.length - 1)];

  /// Gravity ramps up over the first second of a run so a fresh spawn
  /// always gives the player a fair beat to get their bearings, instead
  /// of a possible instant death before they've reacted.
  double get gravityScale => (_runTime / 1.0).clamp(0.35, 1.0);

  /// 0 at the start of a run, 1 once [difficultyRampMeters] has been
  /// covered. Drives both the forward-speed ramp and the level
  /// generator's obstacle frequency/speed — the longer a run goes, the
  /// faster and busier it gets.
  double get difficulty =>
      (distanceMeters.value / difficultyRampMeters).clamp(0.0, 1.0);

  /// The auto-run speed floor, climbing steadily with distance so a long
  /// run keeps building pace instead of staying flat forever. Temporarily
  /// multiplied while a [PowerUpKind.speedBoost] is active — deliberately
  /// applied *after* the distance-based clamp, so a boost can push past
  /// the normal cap for its duration.
  double get currentForwardSpeed {
    final base = (minForwardSpeed + distanceMeters.value * forwardSpeedPerMeter)
        .clamp(minForwardSpeed, maxForwardSpeedCap);
    return speedBoostActive ? base * speedBoostFactor : base;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    player = Player();
    world.add(player);
    levelGenerator = LevelGenerator(this);
    camera.viewfinder.position = _cameraBase.clone();

    best.value = await storage.loadBestDistance();
    highestUnlockedLevel.value = await storage.loadHighestUnlockedLevel();
    highestUnlockedCoinLevel.value = await storage.loadHighestUnlockedCoinLevel();
    coinBalance.value = await storage.loadCoinBalance();

    unlockedCharacterIds.value = await storage.loadUnlockedCharacters();
    selectedCharacterId.value = await storage.loadSelectedCharacter();
    unlockedMapIds.value = await storage.loadUnlockedMaps();
    selectedMapId.value = await storage.loadSelectedMap();
    player.applySkin(selectedCharacter);

    streakCount.value = await storage.loadStreakCount();
    _streakLastClaimDate = await storage.loadStreakLastClaimDate();
    streakClaimedToday.value = _streakLastClaimDate == todayKey();
    if (!streakClaimedToday.value) {
      overlays.add('dailyStreak');
    }

    final rawChallenge = await storage.loadDailyChallengeRaw();
    if (rawChallenge != null) {
      final parts = rawChallenge.split('|');
      if (parts.length == 5) {
        _dailyChallengeDate = parts[0];
        final type = DailyChallengeType.values.firstWhere(
          (t) => t.name == parts[1],
          orElse: () => DailyChallengeType.distance,
        );
        final target = int.tryParse(parts[2]) ?? 0;
        final reward = int.tryParse(parts[3]) ?? 0;
        dailyChallenge.value = DailyChallenge(type: type, target: target, reward: reward);
        dailyChallengeCompleted.value = parts[4] == 'true';
      }
    }
    _ensureDailyChallenge();

    _spinLastDate = await storage.loadDailySpinLastDate();
    spinAvailableToday.value = _spinLastDate != todayKey();
  }

  /// Regenerates today's challenge if the calendar date has rolled over
  /// (or none was ever saved) — otherwise leaves the loaded one in place.
  void _ensureDailyChallenge() {
    final today = todayKey();
    if (_dailyChallengeDate == today && dailyChallenge.value != null) return;
    _dailyChallengeDate = today;
    dailyChallenge.value = generateDailyChallenge(today);
    dailyChallengeCompleted.value = false;
    _saveDailyChallenge();
  }

  void _saveDailyChallenge() {
    final c = dailyChallenge.value;
    if (c == null) return;
    storage.saveDailyChallengeRaw(
      '$_dailyChallengeDate|${c.type.name}|${c.target}|${c.reward}|${dailyChallengeCompleted.value}',
    );
  }

  /// Checks the current run's final tally against today's challenge —
  /// called once when a run ends (win or lose). A no-op if there's
  /// nothing pending or it's already been completed today.
  void _checkDailyChallenge() {
    final c = dailyChallenge.value;
    if (c == null || dailyChallengeCompleted.value) return;
    final met = c.type == DailyChallengeType.distance
        ? distanceMeters.value >= c.target
        : coins.value >= c.target;
    if (!met) return;

    dailyChallengeCompleted.value = true;
    dailyChallengeJustCompleted.value = true;
    coinBalance.value += c.reward;
    storage.saveCoinBalance(coinBalance.value);
    _saveDailyChallenge();
  }

  /// Grants today's pending streak reward and marks it claimed. A no-op
  /// if already claimed today.
  void claimDailyStreak() {
    if (streakClaimedToday.value) return;
    final day = pendingStreakDay;
    final reward = streakRewardFor(day);

    streakCount.value = day;
    _streakLastClaimDate = todayKey();
    streakClaimedToday.value = true;
    coinBalance.value += reward;

    storage.saveCoinBalance(coinBalance.value);
    storage.saveStreakCount(day);
    storage.saveStreakLastClaimDate(_streakLastClaimDate!);
    overlays.remove('dailyStreak');
  }

  /// Picks (but doesn't yet grant) today's free-spin result, so the UI
  /// can animate the wheel to the right segment before crediting it.
  int pickSpinRewardIndex() => _rng.nextInt(spinWheelValues.length);

  /// Grants the reward at [index] and marks today's free spin used. A
  /// no-op if it's already been used today.
  void claimSpinReward(int index) {
    if (!spinAvailableToday.value) return;
    coinBalance.value += spinWheelValues[index];
    storage.saveCoinBalance(coinBalance.value);
    _spinLastDate = todayKey();
    storage.saveDailySpinLastDate(_spinLastDate!);
    spinAvailableToday.value = false;
  }

  /// Shared reset logic for the start of any run, regardless of mode.
  void _beginRun() {
    for (final c in world.children.query<Despawnable>().toList()) {
      c.removeFromParent();
    }
    player.resetForNewRun();
    distanceMeters.value = 0;
    coins.value = 0;
    stage.value = 1;
    coinMultiplierTimeLeft.value = 0;
    speedBoostTimeLeft.value = 0;
    gapHintOffset.value = null;
    dailyChallengeJustCompleted.value = false;
    _shakeTime = 0;
    _cameraBase.setValues(
      playerStartX + cameraLookAheadX,
      playerStartY + cameraVerticalOffset,
    );
    _cameraFocusY = playerStartY;
    camera.viewfinder.position = _cameraBase.clone();

    levelGenerator.reset();
    _runTime = 0;

    _countdownTime = countdownSeconds;
    countdownValue.value = countdownSeconds.ceil();
    status.value = GameStatus.countdown;
    overlays.remove('start');
    overlays.remove('levelSelect');
    overlays.remove('coinLevelSelect');
    overlays.remove('store');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.add('countdown');
  }

  /// Starts (or restarts) an unrestricted endless run.
  void startEndless() {
    mode.value = GameMode.endless;
    _beginRun();
  }

  /// Starts (or retries) a specific Level-mode stage.
  void startLevel(int levelIndex) {
    mode.value = GameMode.levels;
    currentLevel.value = levelIndex.clamp(1, levelTargets.length);
    _beginRun();
  }

  void retryLevel() => startLevel(currentLevel.value);

  /// Starts (or retries) a specific Coin-challenge stage.
  void startCoinChallenge(int levelIndex) {
    mode.value = GameMode.coins;
    currentCoinLevel.value = levelIndex.clamp(1, coinTargets.length);
    _beginRun();
  }

  void retryCoinChallenge() => startCoinChallenge(currentCoinLevel.value);

  void showLevelSelect() {
    status.value = GameStatus.start;
    overlays.remove('start');
    overlays.remove('coinLevelSelect');
    overlays.remove('store');
    overlays.remove('countdown');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.add('levelSelect');
  }

  void showCoinLevelSelect() {
    status.value = GameStatus.start;
    overlays.remove('start');
    overlays.remove('levelSelect');
    overlays.remove('store');
    overlays.remove('countdown');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.add('coinLevelSelect');
  }

  void showStore() {
    status.value = GameStatus.start;
    overlays.remove('start');
    overlays.remove('levelSelect');
    overlays.remove('coinLevelSelect');
    overlays.remove('countdown');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.add('store');
  }

  void showStartScreen() {
    status.value = GameStatus.start;
    overlays.remove('levelSelect');
    overlays.remove('coinLevelSelect');
    overlays.remove('store');
    overlays.remove('countdown');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.add('start');
  }

  /// Buys [skin] if not already owned and the balance covers its price.
  /// Returns whether it's owned afterward (true if it already was).
  bool purchaseCharacter(CharacterSkin skin) {
    if (unlockedCharacterIds.value.contains(skin.id)) return true;
    if (coinBalance.value < skin.price) return false;

    coinBalance.value -= skin.price;
    storage.saveCoinBalance(coinBalance.value);

    final updated = [...unlockedCharacterIds.value, skin.id];
    unlockedCharacterIds.value = updated;
    storage.saveUnlockedCharacters(updated);
    return true;
  }

  /// Equips [id] — must already be owned.
  void selectCharacter(String id) {
    if (!unlockedCharacterIds.value.contains(id)) return;
    selectedCharacterId.value = id;
    storage.saveSelectedCharacter(id);
    player.applySkin(selectedCharacter);
  }

  /// Buys [map] if not already owned and the balance covers its price.
  /// Returns whether it's owned afterward (true if it already was).
  bool purchaseMap(MapTheme map) {
    if (unlockedMapIds.value.contains(map.id)) return true;
    if (coinBalance.value < map.price) return false;

    coinBalance.value -= map.price;
    storage.saveCoinBalance(coinBalance.value);

    final updated = [...unlockedMapIds.value, map.id];
    unlockedMapIds.value = updated;
    storage.saveUnlockedMaps(updated);
    return true;
  }

  /// Equips [id] — must already be owned.
  void selectMap(String id) {
    if (!unlockedMapIds.value.contains(id)) return;
    selectedMapId.value = id;
    storage.saveSelectedMap(id);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Camera follow + shake decay keep running after death too, so an
    // impact's shake plays out over the frozen death frame instead of
    // being cut off instantly.
    _updateCameraFollow(dt);

    if (status.value == GameStatus.countdown) {
      _updateCountdown(dt);
      return;
    }

    if (!isRunning) return;

    _runTime += dt;
    levelGenerator.update();
    _checkObstacleCollisions();
    _checkCoinPickups();
    _checkPowerUpPickups();
    _tickBuffs(dt);
    _updateGapHint();
    _updateDistance();
    _cleanupBehindPlayer();

    if (!isRunning) return; // a check above may have already ended the run

    if (player.position.y > deathY || player.position.y < topBoundY) {
      _endRun(shake: false);
    }
  }

  /// Ticks the pre-run "3, 2, 1" countdown down and flips to
  /// [GameStatus.playing] once it elapses. The world sits frozen the whole
  /// time — [Player.update] bails out early while [isRunning] is false.
  void _updateCountdown(double dt) {
    _countdownTime -= dt;
    final next = _countdownTime.ceil();
    if (next != countdownValue.value && next >= 1) {
      countdownValue.value = next;
    }
    if (_countdownTime <= 0) {
      overlays.remove('countdown');
      status.value = GameStatus.playing;
    }
  }

  void _updateCameraFollow(double dt) {
    // Horizontal always auto-scrolls with the player.
    final targetX = player.position.x + cameraLookAheadX;

    // Vertical only re-anchors once the player leaves the deadzone band.
    final upperEdge = _cameraFocusY - verticalCameraDeadzone;
    final lowerEdge = _cameraFocusY + verticalCameraDeadzone;
    if (player.position.y < upperEdge) {
      _cameraFocusY = player.position.y + verticalCameraDeadzone;
    } else if (player.position.y > lowerEdge) {
      _cameraFocusY = player.position.y - verticalCameraDeadzone;
    }
    final targetY = _cameraFocusY + cameraVerticalOffset;

    final target = Vector2(targetX, targetY);
    final t = 1 - exp(-cameraFollowSpeed * dt);
    _cameraBase.setFrom(_cameraBase + (target - _cameraBase) * t);

    var shakeX = 0.0;
    var shakeY = 0.0;
    if (_shakeTime > 0) {
      _shakeTime = max(0, _shakeTime - dt);
      final power = _shakeMagnitude * (_shakeTime / _shakeDuration);
      shakeX = (_rng.nextDouble() - 0.5) * 2 * power;
      shakeY = (_rng.nextDouble() - 0.5) * 2 * power;
    }
    camera.viewfinder.position = Vector2(
      _cameraBase.x + shakeX,
      _cameraBase.y + shakeY,
    );
  }

  void triggerShake({double magnitude = 10, double duration = 0.25}) {
    _shakeMagnitude = magnitude;
    _shakeDuration = duration;
    _shakeTime = duration;
  }

  void _checkObstacleCollisions() {
    for (final obstacle in world.children.query<Obstacle>()) {
      if (obstacle.hits(player)) {
        _endRun(shake: true);
        return;
      }
    }
  }

  void _checkCoinPickups() {
    for (final coin in world.children.query<Coin>().toList()) {
      if (coin.collected) continue;
      final dist = (coin.position - player.position).length;
      if (dist < playerRadius + coin.radius + 4) {
        coin.collected = true;
        final gain = coinMultiplierActive ? coinMultiplierFactor : 1;
        coins.value += gain;
        coinBalance.value += gain;
        storage.saveCoinBalance(coinBalance.value);
        world.add(
          burst(
            position: coin.position.clone(),
            color: const Color(0xFFFFD23F),
            count: 8,
            speed: 90,
            radius: 2.5,
            lifespan: 0.35,
          ),
        );
        coin.removeFromParent();

        if (mode.value == GameMode.coins && coins.value >= currentCoinTarget) {
          _completeLevel();
          return;
        }
      }
    }
  }

  void _checkPowerUpPickups() {
    for (final powerUp in world.children.query<PowerUp>().toList()) {
      if (powerUp.collected) continue;
      final dist = (powerUp.position - player.position).length;
      if (dist < playerRadius + powerUp.radius + 4) {
        powerUp.collected = true;
        switch (powerUp.kind) {
          case PowerUpKind.coinMultiplier:
            coinMultiplierTimeLeft.value = coinMultiplierDuration;
          case PowerUpKind.speedBoost:
            speedBoostTimeLeft.value = speedBoostDuration;
        }
        world.add(
          burst(
            position: powerUp.position.clone(),
            color: powerUp.kind == PowerUpKind.coinMultiplier
                ? const Color(0xFF9B6BFF)
                : const Color(0xFF2FE6FF),
            count: 14,
            speed: 150,
            radius: 3,
            lifespan: 0.5,
          ),
        );
        powerUp.removeFromParent();
      }
    }
  }

  void _tickBuffs(double dt) {
    if (coinMultiplierTimeLeft.value > 0) {
      coinMultiplierTimeLeft.value = max(0, coinMultiplierTimeLeft.value - dt);
    }
    if (speedBoostTimeLeft.value > 0) {
      speedBoostTimeLeft.value = max(0, speedBoostTimeLeft.value - dt);
    }
  }

  /// Finds the nearest not-yet-passed [WallObstacle] within
  /// [gapHintLookahead] and reports how far above/below its gap center the
  /// player currently is, so the HUD can point them the right way before
  /// the wall is close enough to clearly see.
  void _updateGapHint() {
    WallObstacle? nearest;
    var nearestDx = double.infinity;
    for (final wall in world.children.query<WallObstacle>()) {
      final dx = wall.position.x - player.position.x;
      if (dx > -wall.wallWidth / 2 && dx < nearestDx) {
        nearestDx = dx;
        nearest = wall;
      }
    }

    if (nearest == null || nearestDx > gapHintLookahead) {
      gapHintOffset.value = null;
      return;
    }

    final offset = (nearest.gapY + nearest.gapHeight / 2) - player.position.y;
    gapHintOffset.value = offset.abs() < gapHintAlignedMargin ? null : offset;
  }

  void _updateDistance() {
    final metersNow = ((player.position.x - playerStartX) / pixelsPerMeter)
        .floor();
    if (metersNow > distanceMeters.value) {
      distanceMeters.value = metersNow;

      final newStage = (metersNow / metersPerLevel).floor() + 1;
      if (newStage != stage.value) {
        stage.value = newStage;
        world.add(
          burst(
            position: player.position.clone(),
            color: const Color(0xFF7CFF6B),
            count: 18,
            speed: 180,
            radius: 3.5,
            lifespan: 0.6,
          ),
        );
      }

      if (mode.value == GameMode.levels && metersNow >= currentLevelTarget) {
        _completeLevel();
      }
    }
  }

  void _cleanupBehindPlayer() {
    final cutoff = player.position.x - despawnMarginBehindPlayer;
    for (final c in world.children.query<Despawnable>().toList()) {
      if (c.despawnX < cutoff) {
        c.removeFromParent();
      }
    }
  }

  void _endRun({required bool shake}) {
    if (!isRunning) return;
    player.dead = true;
    player.thrustingUp = false;
    player.thrustingDown = false;
    status.value = GameStatus.gameOver;

    if (mode.value == GameMode.endless && distanceMeters.value > best.value) {
      best.value = distanceMeters.value;
      storage.saveBestDistance(best.value);
    }

    _checkDailyChallenge();

    if (shake) {
      triggerShake(magnitude: 16, duration: 0.35);
    }

    overlays.add('gameOver');
  }

  void _completeLevel() {
    if (!isRunning) return;
    player.dead = true;
    player.thrustingUp = false;
    player.thrustingDown = false;
    status.value = GameStatus.levelComplete;
    _checkDailyChallenge();

    if (mode.value == GameMode.coins) {
      final nextUnlock = (currentCoinLevel.value + 1).clamp(1, coinTargets.length);
      if (nextUnlock > highestUnlockedCoinLevel.value) {
        highestUnlockedCoinLevel.value = nextUnlock;
        storage.saveHighestUnlockedCoinLevel(nextUnlock);
      }
    } else {
      final nextUnlock = (currentLevel.value + 1).clamp(1, levelTargets.length);
      if (nextUnlock > highestUnlockedLevel.value) {
        highestUnlockedLevel.value = nextUnlock;
        storage.saveHighestUnlockedLevel(nextUnlock);
      }
    }

    world.add(
      burst(
        position: player.position.clone(),
        color: const Color(0xFFFFD23F),
        count: 24,
        speed: 220,
        radius: 4,
        lifespan: 0.7,
      ),
    );

    overlays.add('levelComplete');
  }

  // --- Input --------------------------------------------------------------
  //
  // No aiming, no targets: holding the bottom half of the screen pulls the
  // player up, holding the top half pulls them down.

  void _setThrustFromTouch(Vector2 widgetPos) {
    if (!isRunning) return;

    final wantsUp = widgetPos.y > canvasSize.y / 2;
    final wantsDown = !wantsUp;

    if (wantsUp && !player.thrustingUp) {
      world.add(
        burst(
          position: player.position.clone(),
          color: const Color(0xFF7CFF6B),
          count: 8,
          speed: 100,
          radius: 2.5,
          lifespan: 0.3,
        ),
      );
    } else if (wantsDown && !player.thrustingDown) {
      world.add(
        burst(
          position: player.position.clone(),
          color: const Color(0xFF7CFF6B),
          count: 8,
          speed: 100,
          radius: 2.5,
          lifespan: 0.3,
        ),
      );
    }

    player.thrustingUp = wantsUp;
    player.thrustingDown = wantsDown;
  }

  void _clearThrust() {
    player.thrustingUp = false;
    player.thrustingDown = false;
  }

  @override
  void onPanDown(DragDownInfo info) {
    _setThrustFromTouch(info.eventPosition.widget);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _setThrustFromTouch(info.eventPosition.widget);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _clearThrust();
  }

  @override
  void onPanCancel() {
    _clearThrust();
  }
}
