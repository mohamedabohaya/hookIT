// Basic smoke test: the app boots to the animated splash screen, then
// auto-advances to the real start screen once its timer fires.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:run/main.dart';

void main() {
  testWidgets(
    'Splash screen leads to the start screen with ENDLESS and LEVELS',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const HookItApp());
      await tester.pump();
      expect(find.text('HOOK IT'), findsOneWidget);

      // Drive the splash's delayed navigation and page transition to
      // completion.
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 500));
      // The game runs a continuous ticker, so it never "settles" — pump a
      // handful of frames instead of using pumpAndSettle.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('ENDLESS'), findsOneWidget);
      expect(find.text('LEVELS'), findsOneWidget);
    },
  );
}
