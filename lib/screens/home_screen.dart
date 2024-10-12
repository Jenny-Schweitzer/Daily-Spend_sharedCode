import 'package:flutter/material.dart';
import 'package:flutter_project/screens/show_expense_screen.dart';
import 'package:flutter_project/screens/show_income_screen.dart';
import 'package:flutter_project/screens/show_overview_screen.dart';
import 'package:flutter_project/screens/statistics_screen.dart';
import 'package:flutter_project/screens/widgets/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isFirstLaunch = true;

  // Eine Liste der Screens, die mit der Bottom Navigation verknüpft sind
  final List<Widget> _screens = [
    OverviewScreen(), // Index 0: Übersicht (Startseite)
    const StatisticScreen(), // Index 1: Statistiken
    const OverviewExpenseScreen(), // Index 2: Ausgabenübersicht
    const OverviewIncomeScreen(), // Index 3: Einnahmenübersicht
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch(); 
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasOnboarded = prefs.getBool('onboardingCompleted');

    // Falls der Wert `null` oder `false` ist, öffne das Onboarding
    if (hasOnboarded == null || !hasOnboarded) {
      _isFirstLaunch = true;
    } else {
      _isFirstLaunch = false;
    }

    if (_isFirstLaunch) {
      // Zeige Onboarding-Screen
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Aktualisiere den aktuellen Index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO: ergänze AppBar als Widged für einheitliches Erscheinungsbild über alle Screens hinweg
      
      // Ändere das Body-Widget basierend auf dem aktuellen Index
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
