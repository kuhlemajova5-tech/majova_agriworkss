import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'screens/onboarding/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JovasAgriWorksApp());
}

class JovasAgriWorksApp extends StatelessWidget {
  const JovasAgriWorksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOVAS AgriWorks',
      debugShowCheckedModeBanner: false,

      // Light mode
      theme: AppTheme.lightTheme,

      // Dark mode
      darkTheme: AppTheme.darkTheme,

      // Follow the phone's Light/Dark Mode
      themeMode: ThemeMode.system,

      // First screen
      home: const SplashScreen(),
    );
  }
}

