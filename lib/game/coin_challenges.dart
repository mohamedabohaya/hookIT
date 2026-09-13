/// The fixed sequence of Coin-challenge stages. Index 0 is Challenge 1.
/// Each entry is the number of coins the player must collect *during a
/// single run* to clear that challenge and unlock the next one — mirrors
/// [levelTargets], but scored by coins gathered instead of distance
/// travelled.
const List<int> coinTargets = [
  30,
  60,
  100,
  150,
  210,
  280,
  360,
  450,
  550,
  660,
];

int get coinLevelCount => coinTargets.length;
