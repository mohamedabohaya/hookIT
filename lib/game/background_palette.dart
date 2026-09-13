import 'dart:ui';

/// One "world" the background can look like — a sky gradient plus three
/// hill-layer colors and a cloud tint. [Background] cycles through the
/// selected [MapTheme]'s list of these once every `metersPerLevel`, and the
/// Store lets the player pick which map's list is active.
class BackgroundPalette {
  const BackgroundPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.far,
    required this.mid,
    required this.near,
    required this.cloud,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color far;
  final Color mid;
  final Color near;
  final Color cloud;
}
