import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/category.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _fillDatabaseWithDefault() async {
    //insert Default Categories into Database
    List<Category> defaultCategories = [
      Category(name: 'Vaccation', icon: 'Icons.luggage', color: '0xFF68764e'),
      Category(name: 'Car', icon: 'Icons.directions_car', color: '0xFF70435B'),
      Category(name: 'Food', icon: 'Icons.restaurant', color: '0xFF894D2A'),
      Category(
          name: 'Shopping', icon: 'Icons.shopping_cart', color: '0xFF3E7569'),
    ];
    for (Category defaultCategory in defaultCategories) {
      await DatabaseHelper.instance.insertCategory(defaultCategory.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode
                        .darken), // Leichte Abdunklung für bessere Lesbarkeit
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to DailySpend!',
                  style: TextStyle(
                    fontSize: AppFonds.superBig,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorBright,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Start by setting up your saving goal and income.\n'
                  'Track your expenses easily and reach your financial goals!',
                  style: TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    _fillDatabaseWithDefault();
                    // Abschließen des Onboardings und Weiterleitung zur Startseite
                    _completeOnboarding(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                        fontSize: AppFonds.buttonBig,
                        color: AppColors.onPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
