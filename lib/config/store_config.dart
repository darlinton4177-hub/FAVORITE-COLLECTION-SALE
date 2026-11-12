import 'package:flutter/material.dart';

class StoreConfig {
  static const String appName = 'Favorite Collection';
  static const String appTagline = 'Shop More. Pay Less.';
  static const String storeDescription =
      'Favorite Collection - Discover Your Style. Premium Fashion & Marketplace Deals. '
      'Enjoy curated collections, flash deals, verified quality, and seamless online shopping.';

  static const String storeEmail = 'darlinton4177@gmail.com';
  static const String storePhone = '+234 (800) 555-STYLE';
  static const String storeAddress = 'Nigeria & Cameroon';
  
  // Master Currency Settings (Nigeria NGN)
  static const String currencySymbol = '₦';
  static const String currencyCode = 'NGN';
  static const double freeShippingThreshold = 50000.0; // ₦50,000
  static const double standardShippingFee = 2500.0;     // ₦2,500
  static const double expressShippingFee = 6500.0;      // ₦6,500
  static const double estimatedTaxRate = 0.075;         // 7.5% VAT

  // Admin PIN (change before production deployment)
  static const String demoAdminPin = '1234';

  // Primary Theme Colors (Material 3 with Temu/Jumia warm energetic vibrancy & modern sleek chic)
  static const Color primaryColor = Color(0xFFE65100);   // Warm vibrant orange/terracotta
  static const Color secondaryColor = Color(0xFF0D47A1); // Deep stylish navy blue
  static const Color accentColor = Color(0xFFFF9800);    // Amber orange accent
  static const Color surfaceColorLight = Color(0xFFF9F9FB);
  static const Color cardColorLight = Colors.white;
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardColorDark = Color(0xFF1E1E1E);

  // Store Policies
  static const String returnPolicy =
      '30-day hassle-free returns on unworn fashion items with original tags intact.';
  static const String shippingPolicy =
      'Standard 2-4 business days delivery across Nigeria and Cameroon. Express delivery available. Free shipping on orders over ₦50,000.';
  static const String privacyPolicy =
      'We respect your privacy. All customer data and payment transactions are secured with Supabase enterprise encryption.';
  static const String termsOfService =
      'Favorite Collection provides premium marketplace shopping with multi-currency checkout in NGN and XAF.';
}
