import 'package:flutter/material.dart' show Color;

import 'background_palette.dart';

/// A purchasable/equippable look for the player's ball. [id] is the
/// persisted key; 'classic' is always owned and is the default.
class CharacterSkin {
  const CharacterSkin({
    required this.id,
    required this.name,
    required this.price,
    required this.bodyColors,
    required this.bellyColor,
    required this.outlineColor,
  });

  final String id;
  final String name;
  final int price;

  /// Radial-gradient stops for the body, light-to-dark (matches the 3
  /// stops [Player] renders with).
  final List<Color> bodyColors;
  final Color bellyColor;
  final Color outlineColor;
}

/// A purchasable/equippable world look. [id] is the persisted key;
/// 'classic' is always owned and is the default — its [palettes] are the
/// original hand-tuned progression, so a player who never opens the Store
/// sees exactly the same visuals as before the Store existed.
class MapTheme {
  const MapTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.previewColors,
    required this.palettes,
  });

  final String id;
  final String name;
  final int price;

  /// A couple of representative colors for the Store tile's swatch.
  final List<Color> previewColors;
  final List<BackgroundPalette> palettes;
}

const List<CharacterSkin> characterSkins = [
  CharacterSkin(
    id: 'classic',
    name: 'Classic',
    price: 0,
    bodyColors: [Color(0xFFFFF0B0), Color(0xFFFFD23F), Color(0xFFF2A81C)],
    bellyColor: Color(0xFFFFF3C4),
    outlineColor: Color(0xFF3A2E1E),
  ),
  CharacterSkin(
    id: 'ruby',
    name: 'Ruby',
    price: 200,
    bodyColors: [Color(0xFFFFD3D3), Color(0xFFFF5C5C), Color(0xFFB92E2E)],
    bellyColor: Color(0xFFFFE8E8),
    outlineColor: Color(0xFF4A1414),
  ),
  CharacterSkin(
    id: 'ocean',
    name: 'Ocean',
    price: 350,
    bodyColors: [Color(0xFFD0F0FF), Color(0xFF29B6F6), Color(0xFF01579B)],
    bellyColor: Color(0xFFE1F5FE),
    outlineColor: Color(0xFF0D2A3A),
  ),
  CharacterSkin(
    id: 'nebula',
    name: 'Nebula',
    price: 550,
    bodyColors: [Color(0xFFF0D9FF), Color(0xFFAB47BC), Color(0xFF4A148C)],
    bellyColor: Color(0xFFF3E5F5),
    outlineColor: Color(0xFF2A0A3A),
  ),
];

const List<MapTheme> mapThemes = [
  MapTheme(
    id: 'classic',
    name: 'Classic',
    price: 0,
    previewColors: [Color(0xFF9FDCF7), Color(0xFF5AB894)],
    palettes: [
      BackgroundPalette(
        skyTop: Color(0xFF9FDCF7),
        skyBottom: Color(0xFFE7F7EA),
        far: Color(0xFFBFE9F7),
        mid: Color(0xFF8FD3C7),
        near: Color(0xFF5AB894),
        cloud: Color(0x99FFFFFF),
      ),
      BackgroundPalette(
        skyTop: Color(0xFFFF9E7D),
        skyBottom: Color(0xFFFFD9A6),
        far: Color(0xFFF7C6A3),
        mid: Color(0xFFE8946F),
        near: Color(0xFFC9603E),
        cloud: Color(0x99FFEFE0),
      ),
      BackgroundPalette(
        skyTop: Color(0xFF6A5ACD),
        skyBottom: Color(0xFFFFAFC0),
        far: Color(0xFFC9A7E8),
        mid: Color(0xFF9C7BC9),
        near: Color(0xFF6B4E9E),
        cloud: Color(0x88F0DCFF),
      ),
      BackgroundPalette(
        skyTop: Color(0xFF0B1E3D),
        skyBottom: Color(0xFF1B3A5C),
        far: Color(0xFF33547B),
        mid: Color(0xFF24405F),
        near: Color(0xFF182B44),
        cloud: Color(0x55CFE0F5),
      ),
      BackgroundPalette(
        skyTop: Color(0xFFFFD6E8),
        skyBottom: Color(0xFFBFE3FF),
        far: Color(0xFFFFC7DD),
        mid: Color(0xFFA8D6E8),
        near: Color(0xFF6FB6D9),
        cloud: Color(0x99FFFFFF),
      ),
    ],
  ),
  MapTheme(
    id: 'dunes',
    name: 'Sunset Dunes',
    price: 200,
    previewColors: [Color(0xFFFFB74D), Color(0xFF8D5524)],
    palettes: [
      BackgroundPalette(
        skyTop: Color(0xFFFFB74D),
        skyBottom: Color(0xFFFFF3E0),
        far: Color(0xFFFFCC80),
        mid: Color(0xFFD7823B),
        near: Color(0xFF8D5524),
        cloud: Color(0x99FFF3E0),
      ),
    ],
  ),
  MapTheme(
    id: 'aurora',
    name: 'Midnight Aurora',
    price: 350,
    previewColors: [Color(0xFF0F3D3E), Color(0xFF1E5C4F)],
    palettes: [
      BackgroundPalette(
        skyTop: Color(0xFF071426),
        skyBottom: Color(0xFF0F3D3E),
        far: Color(0xFF123B4F),
        mid: Color(0xFF1E5C4F),
        near: Color(0xFF123326),
        cloud: Color(0x5580FFDA),
      ),
    ],
  ),
  MapTheme(
    id: 'volcano',
    name: 'Volcanic Ash',
    price: 550,
    previewColors: [Color(0xFF3B0F0F), Color(0xFF6E1F1F)],
    palettes: [
      BackgroundPalette(
        skyTop: Color(0xFF1A0A0A),
        skyBottom: Color(0xFF3B0F0F),
        far: Color(0xFF4A1414),
        mid: Color(0xFF6E1F1F),
        near: Color(0xFF2A0A0A),
        cloud: Color(0x55FF7043),
      ),
    ],
  ),
];
