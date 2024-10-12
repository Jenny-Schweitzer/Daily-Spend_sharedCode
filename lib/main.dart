import 'package:flutter/material.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/screens/onboarding_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailySpend',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
