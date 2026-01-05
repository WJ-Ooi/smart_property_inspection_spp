import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () async {
      final loggedIn = await SessionService.isLoggedIn();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
