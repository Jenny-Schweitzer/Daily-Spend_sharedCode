import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, 
      onTap:
          onTap,
      selectedItemColor: AppColors.secondaryColor, 
      unselectedItemColor: AppColors.primaryColor,
      showSelectedLabels: true, // Labels für ausgewählte Icons anzeigen
      showUnselectedLabels: false, // Keine Labels für nicht ausgewählte Icons
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Symbols.home),
          label: 'Home',
           backgroundColor: AppColors.backgroundColorDark,
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.finance),
          label: 'Statistic',
           backgroundColor: AppColors.backgroundColorDark,
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.payments),
          label: 'Expense',
          backgroundColor: AppColors.backgroundColorDark,
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.savings),
          label: 'Income',
           backgroundColor: AppColors.backgroundColorDark,
        ),
      ],
    );
  }
}
