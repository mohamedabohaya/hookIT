/// Returns today's local calendar date as a stable, comparable key like
/// "2026-09-11" — used by the daily-reward systems (streak, challenge,
/// spin) to detect day rollovers.
String todayKey([DateTime? now]) => _keyFor(now ?? DateTime.now());

/// The calendar date immediately before [key] (itself shaped like
/// [todayKey]'s output), used to tell whether a streak continues or
/// breaks.
String dayBefore(String key) {
  final parts = key.split('-');
  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  return _keyFor(date.subtract(const Duration(days: 1)));
}

String _keyFor(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
