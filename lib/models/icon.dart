import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategorieIcons {
  final String? iconName;
  final IconData? iconData;

  CategorieIcons({
    this.iconName,
    this.iconData,
  });

  // Funktion zum Parsen des Icon-Namens in ein IconData
  static String toName(IconData? iconData) {
    switch (iconData) {
      case Icons.luggage:
        return 'Icons.luggage';
      case Icons.directions_car:
        return 'Icons.directions_car';
      case Icons.restaurant:
        return 'Icons.restaurant';
      case Icons.shopping_cart:
        return 'Icons.shopping_cart';
      case Icons.security:
        return 'Icons.security';
      case Icons.cottage:
        return 'Icons.cottage';
      case Icons.electric_bolt:
        return 'Icons.electric_bolt';
      case Icons.smartphone:
        return 'Icons.smartphone';
      case Icons.local_gas_station:
        return 'Icons.local_gas_station';
      case Icons.train:
        return 'Icons.train';
      case Icons.fastfood:
        return 'Icons.fastfood';
      case Icons.delivery_dining:
        return 'Icons.delivery_dining';
      case Icons.local_bar:
        return 'Icons.local_bar';
      case Icons.checkroom:
        return 'Icons.checkroom';
      case Icons.casino:
        return 'Icons.casino';
      case Icons.golf_course:
        return 'Icons.golf_course';
      case Icons.content_cut:
        return 'Icons.content_cut';
      case Icons.handyman:
        return 'Icons.handyman';
      case Icons.sports_esports:
        return 'Icons.sports_esports';
      case Icons.cake:
        return 'Icons.cake';
      case Icons.self_improvement:
        return 'Icons.self_improvement';
      case Icons.coronavirus:
        return 'Icons.coronavirus';
      case Icons.pets:
        return 'Icons.pets';
      case Icons.roller_skating:
        return 'Icons.roller_skating';
      case Symbols.health_and_beauty:
        return 'Symbols.health_and_beauty';
      case Icons.auto_stories:
        return 'Icons.auto_stories';
      case Icons.work:
        return 'Icons.work';
      case Icons.auto_awesome:
        return 'Icons.auto_awesome';
      case Icons.school:
        return 'Icons.school';
      case Icons.tv:
        return 'Icons.tv';
      case Icons.castle:
        return 'Icons.castle';
      case Icons.local_florist:
        return 'Icons.local_florist';
      case Icons.attractions:
        return 'Icons.attractions';
      case Icons.local_pharmacy:
        return 'Icons.local_pharmacy';
      default:
        return 'Icons.category';
    }
  }

  static IconData toIconData(String iconName) {
    switch (iconName) {
      case 'Icons.luggage':
        return Icons.luggage;
      case 'Icons.directions_car':
        return Icons.directions_car;
      case 'Icons.restaurant':
        return Icons.restaurant;
      case 'Icons.shopping_cart':
        return Icons.shopping_cart;
      case 'Icons.security':
        return Icons.security;
      case 'Icons.cottage':
        return Icons.cottage;
      case 'Icons.electric_bolt':
        return Icons.electric_bolt;
      case 'Icons.smartphone':
        return Icons.smartphone;
      case 'Icons.local_gas_station':
        return Icons.local_gas_station;
      case 'Icons.train':
        return Icons.train;
      case 'Icons.fastfood':
        return Icons.fastfood;
      case 'Icons.delivery_dining':
        return Icons.delivery_dining;
      case 'Icons.local_bar':
        return Icons.local_bar;
      case 'Icons.checkroom':
        return Icons.checkroom;
      case 'Icons.casino':
        return Icons.casino;
      case 'Icons.golf_course':
        return Icons.golf_course;
      case 'Icons.content_cut':
        return Icons.content_cut;
      case 'Icons.handyman':
        return Icons.handyman;
      case 'Icons.sports_esports':
        return Icons.sports_esports;
      case 'Icons.cake':
        return Icons.cake;
      case 'Icons.self_improvement':
        return Icons.self_improvement;
      case 'Icons.coronavirus':
        return Icons.coronavirus;
      case 'Icons.pets':
        return Icons.pets;
      case 'Icons.roller_skating':
        return Icons.roller_skating;
      case 'Symbols.health_and_beauty':
        return Symbols.health_and_beauty;
      case 'Icons.auto_stories':
        return Icons.auto_stories;
      case 'Icons.work':
        return Icons.work;
      case 'Icons.auto_awesome':
        return Icons.auto_awesome;
      case 'Icons.school':
        return Icons.school;
      case 'Icons.tv':
        return Icons.tv;
      case 'Icons.castle':
        return Icons.castle;
      case 'Icons.local_florist':
        return Icons.local_florist;
      case 'Icons.attractions':
        return Icons.attractions;
      case 'Icons.local_pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.category;
    }
  }

  static List<IconData> availableIcons = [
    // not available because default
    // Icons.luggage,
    // Icons.directions_car,
    // Icons.restaurant,
    // Icons.shopping_cart,
    Icons.security,
    Icons.cottage,
    Icons.electric_bolt,
    Icons.smartphone,
    Icons.local_gas_station,
    Icons.train,
    Symbols.health_and_beauty,
    Icons.fastfood,
    Icons.delivery_dining,
    Icons.local_bar,
    Icons.checkroom,
    Icons.casino,
    Icons.golf_course,
    Icons.content_cut,
    Icons.handyman,
    Icons.sports_esports,
    Icons.cake,
    Icons.self_improvement,
    Icons.coronavirus,
    Icons.pets,
    Icons.roller_skating,
    Icons.auto_stories,
    Icons.work,
    Icons.auto_awesome,
    Icons.school,
    Icons.tv,
    Icons.castle,
    Icons.local_florist,
    Icons.attractions,
    Icons.local_pharmacy,
  ];
}
