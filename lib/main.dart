import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const HookItApp());
}

class HookItApp extends StatelessWidget {
  const HookItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hook It',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const SplashScreen(),
    );
  }
}
