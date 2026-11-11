import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B3D1B),
              Color(0xFF1B5E20),
              Color(0xFF43A047),
            ],
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),

                Icon(
                  Icons.agriculture_rounded,
                  size: 100,
                  color: Colors.white,
                ),

                SizedBox(height: 30),

                Text(
                  'JOVAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'AGRIWORKS',
                  style: TextStyle(
                    color: Color(0xFFC8E6C9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 5,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Smart Farming. Stronger Communities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                Spacer(),

                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),

                SizedBox(height: 20),

                Text(
                  'Growing better, together.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}