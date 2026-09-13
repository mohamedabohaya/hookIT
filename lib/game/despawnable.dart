import 'package:flame/components.dart';

/// Marks a world-space component as eligible for cleanup once it falls far
/// enough behind the player. Keeps the active component count bounded on an
/// endless level.
mixin Despawnable on PositionComponent {
  double get despawnX => position.x;
}
