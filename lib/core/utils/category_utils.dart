import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryUtils {
  CategoryUtils._();

  static Color colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textMuted;
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static IconData iconFromName(String? name) {
    switch (name) {
      case 'restaurant':      return Icons.restaurant;
      case 'directions_car':  return Icons.directions_car;
      case 'home':            return Icons.home;
      case 'shopping_bag':    return Icons.shopping_bag;
      case 'movie':           return Icons.movie;
      case 'favorite':        return Icons.favorite;
      case 'school':          return Icons.school;
      case 'account_balance': return Icons.account_balance;
      case 'subscriptions':   return Icons.subscriptions;
      case 'local_cafe':      return Icons.local_cafe;
      case 'shopping_cart':   return Icons.shopping_cart;
      case 'flight':          return Icons.flight;
      case 'wifi':            return Icons.wifi;
      default:                return Icons.category;
    }
  }
}