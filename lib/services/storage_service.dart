import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around [SharedPreferences] for persisting the player's best
/// distance and level-mode progress. Intentionally minimal for the MVP:
/// no accounts, no backend.
class StorageService {
  static const _bestDistanceKey = 'hook_it_best_distance_m';
  static const _highestUnlockedLevelKey = 'hook_it_highest_unlocked_level';
  static const _highestUnlockedCoinLevelKey = 'hook_it_highest_unlocked_coin_level';
  static const _coinBalanceKey = 'hook_it_coin_balance';
  static const _unlockedCharactersKey = 'hook_it_unlocked_characters';
  static const _selectedCharacterKey = 'hook_it_selected_character';
  static const _unlockedMapsKey = 'hook_it_unlocked_maps';
  static const _selectedMapKey = 'hook_it_selected_map';
  static const _streakCountKey = 'hook_it_streak_count';
  static const _streakLastClaimKey = 'hook_it_streak_last_claim';
  static const _dailyChallengeKey = 'hook_it_daily_challenge';
  static const _dailySpinLastDateKey = 'hook_it_daily_spin_last_date';
  static const _heartBalanceKey = 'hook_it_heart_balance';

  Future<int> loadBestDistance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestDistanceKey) ?? 0;
  }

  Future<void> saveBestDistance(int meters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestDistanceKey, meters);
  }

  /// 1-based index of the highest level the player is allowed to play.
  /// Level 1 is always unlocked.
  Future<int> loadHighestUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highestUnlockedLevelKey) ?? 1;
  }

  Future<void> saveHighestUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highestUnlockedLevelKey, level);
  }

  /// 1-based index of the highest Coin-challenge stage the player is
  /// allowed to play. Stage 1 is always unlocked.
  Future<int> loadHighestUnlockedCoinLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highestUnlockedCoinLevelKey) ?? 1;
  }

  Future<void> saveHighestUnlockedCoinLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highestUnlockedCoinLevelKey, level);
  }

  /// Total coins ever collected, across every run in every mode — the
  /// player's persistent balance.
  Future<int> loadCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinBalanceKey) ?? 0;
  }

  Future<void> saveCoinBalance(int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinBalanceKey, total);
  }

  /// Store item ids the player has purchased (or unlocked for free), for
  /// characters and maps respectively. 'classic' is always included even
  /// if never saved, since it's the free default.
  Future<List<String>> loadUnlockedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedCharactersKey) ?? const ['classic'];
  }

  Future<void> saveUnlockedCharacters(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedCharactersKey, ids);
  }

  Future<String> loadSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCharacterKey) ?? 'classic';
  }

  Future<void> saveSelectedCharacter(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCharacterKey, id);
  }

  Future<List<String>> loadUnlockedMaps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedMapsKey) ?? const ['classic'];
  }

  Future<void> saveUnlockedMaps(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedMapsKey, ids);
  }

  Future<String> loadSelectedMap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedMapKey) ?? 'classic';
  }

  Future<void> saveSelectedMap(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedMapKey, id);
  }

  /// Length of the login streak as of the last successful claim.
  Future<int> loadStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  Future<void> saveStreakCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakCountKey, count);
  }

  /// The [todayKey]-shaped date the streak reward was last claimed, or
  /// null if never claimed.
  Future<String?> loadStreakLastClaimDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_streakLastClaimKey);
  }

  Future<void> saveStreakLastClaimDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_streakLastClaimKey, date);
  }

  /// Today's daily challenge, encoded as
  /// "date|type|target|reward|completed" — one pref entry instead of four,
  /// since the fields always change together.
  Future<String?> loadDailyChallengeRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyChallengeKey);
  }

  Future<void> saveDailyChallengeRaw(String raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyChallengeKey, raw);
  }

  /// The [todayKey]-shaped date the free daily spin was last used, or
  /// null if never used.
  Future<String?> loadDailySpinLastDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailySpinLastDateKey);
  }

  Future<void> saveDailySpinLastDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailySpinLastDateKey, date);
  }

  /// Spare lives the player can spend to continue a run after dying.
  Future<int> loadHeartBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_heartBalanceKey) ?? 0;
  }

  Future<void> saveHeartBalance(int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_heartBalanceKey, total);
  }
}
