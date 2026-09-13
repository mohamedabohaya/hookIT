import 'dart:math';

/// Escalating coin rewards for a 7-day login streak; day 8 loops back to
/// day 1's reward, and so on.
const List<int> dailyStreakRewards = [20, 30, 40, 60, 80, 100, 150];

/// The coin reward for streak day [streakDay] (1-based).
int streakRewardFor(int streakDay) =>
    dailyStreakRewards[(streakDay - 1) % dailyStreakRewards.length];

/// What a [DailyChallenge] measures — always evaluated against a single
/// run's final tally, not cumulative across runs.
enum DailyChallengeType { distance, coins }

class DailyChallenge {
  const DailyChallenge({required this.type, required this.target, required this.reward});

  final DailyChallengeType type;
  final int target;
  final int reward;

  String get description => type == DailyChallengeType.distance
      ? 'Reach $target m in one run'
      : 'Collect $target coins in one run';
}

/// Deterministically picks a challenge for [dateKey] (a [todayKey]-shaped
/// string) — stable across reloads within the same day, but varies day to
/// day without needing its own persisted random seed.
DailyChallenge generateDailyChallenge(String dateKey) {
  final rng = Random(_stableHash(dateKey));
  final type = rng.nextBool() ? DailyChallengeType.distance : DailyChallengeType.coins;
  if (type == DailyChallengeType.distance) {
    final target = 200 + rng.nextInt(9) * 100; // 200..1000, step 100
    return DailyChallenge(type: type, target: target, reward: 30 + (target ~/ 100) * 4);
  }
  final target = 20 + rng.nextInt(9) * 10; // 20..100, step 10
  return DailyChallenge(type: type, target: target, reward: 30 + (target ~/ 10) * 4);
}

/// Coin values around the free daily spin wheel. Values are duplicated to
/// bias the odds toward the common ones without needing separate weights
/// — each entry is an equally-likely, equally-sized slice.
const List<int> spinWheelValues = [20, 50, 30, 100, 20, 75, 40, 200];

/// A small, deterministic string hash (content-based, not identity-based
/// like [String.hashCode] risks being) — so the same date always seeds
/// the same challenge.
int _stableHash(String s) {
  var hash = 0;
  for (final unit in s.codeUnits) {
    hash = 0x1fffffff & (hash + unit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= (hash >> 6);
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= (hash >> 11);
  hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  return hash;
}
