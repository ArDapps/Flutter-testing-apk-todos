import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/local_storage_service.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animation and data loading
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final hasSeenOnboarding = await LocalStorageService().hasSeenOnboarding();
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => hasSeenOnboarding 
            ? const MainScreen() 
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
            )
            .animate()
            .fade(duration: 1000.ms)
            .scale(delay: 500.ms, duration: 500.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
