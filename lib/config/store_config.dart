import 'package:flutter/material.dart';

class StoreConfig {
  static const String appName = 'Favorite Collection Sale';
  static const String appTagline =
      'Discover Your Style. Premium Fashion & Marketplace Deals.';
  static const String storeDescription =
      'A premium fashion-shopping app for discovering and buying stylish clothing, '
      'jeans, tops, dresses, shirts, trousers, socks, footwear, and fashion accessories. '
      'Enjoy curated collections, flash deals, verified quality, and seamless demonstration shopping.';

  static const String storeEmail = 'support@favoritecollectionsale.com';
  static const String storePhone = '+1 (800) 555-FASHION';
  static const String storeAddress =
      'Fashion Plaza, 500 Avenue of Style, New York, NY';
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  static const double freeShippingThreshold = 50.0;
  static const double standardShippingFee = 4.99;
  static const double expressShippingFee = 12.99;
  static const double estimatedTaxRate = 0.08;

  // Demonstration Admin PIN
  static const String demoAdminPin = '1234';

  // Primary Theme Colors (Material 3 with Temu/Jumia warm energetic vibrancy & modern sleek chic)
  static const Color primaryColor = Color(
    0xFFE65100,
  ); // Warm vibrant orange/terracotta
  static const Color secondaryColor = Color(
    0xFF0D47A1,
  ); // Deep stylish navy blue
  static const Color accentColor = Color(0xFFFF9800); // Amber orange accent
  static const Color surfaceColorLight = Color(0xFFF9F9FB);
  static const Color cardColorLight = Colors.white;
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardColorDark = Color(0xFF1E1E1E);

  // Store Policies
  static const String returnPolicy =
      '30-day hassle-free returns on unworn fashion items with original tags intact.';
  static const String shippingPolicy =
      'Standard 3-5 business days shipping. Express 1-2 business days shipping available. Free standard shipping on orders over \$50.';
  static const String privacyPolicy =
      'We respect your privacy. This demonstration app operates securely and stores preferences locally on your device.';
  static const String termsOfService =
      'This application is an interactive ecommerce demonstration. Transactions simulated in this app do not charge real payment methods.';
}
