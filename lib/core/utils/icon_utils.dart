import 'package:flutter/material.dart';


class IconUtils {
  static IconData getIconByName(String name) {
    switch (name) {
      case 'fastfood': return Icons.fastfood;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'movie': return Icons.movie;
      case 'medical_services': return Icons.medical_services;
      case 'receipt': return Icons.receipt;
      case 'attach_money': return Icons.attach_money;
      case 'trending_up': return Icons.trending_up;
      // Add more defaults
      case 'help': return Icons.help_outline;
      default: return Icons.help_outline;
    }
  }
}
