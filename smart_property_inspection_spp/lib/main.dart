import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const InspectionApp());
}

class InspectionApp extends StatelessWidget {
  const InspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Property Inspection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
