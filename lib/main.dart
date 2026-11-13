import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/store_config.dart';
import 'config/supabase_config.dart';
import 'providers/store_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  runApp(const FavoriteCollectionSaleApp());
}

class FavoriteCollectionSaleApp extends StatelessWidget {
  const FavoriteCollectionSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final colorSchemeLight = ColorScheme.fromSeed(
            seedColor: StoreConfig.primaryColor,
            primary: StoreConfig.primaryColor,
            secondary: StoreConfig.secondaryColor,
            brightness: Brightness.light,
          );

          final colorSchemeDark = ColorScheme.fromSeed(
            seedColor: StoreConfig.primaryColor,
            primary: StoreConfig.primaryColor,
            secondary: StoreConfig.secondaryColor,
            brightness: Brightness.dark,
          );

          return MaterialApp(
            title: StoreConfig.appName,
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: colorSchemeLight,
              scaffoldBackgroundColor: StoreConfig.surfaceColorLight,
              cardColor: StoreConfig.cardColorLight,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 1,
                centerTitle: false,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: colorSchemeDark,
              scaffoldBackgroundColor: StoreConfig.scaffoldDark,
              cardColor: StoreConfig.cardColorDark,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 1,
                centerTitle: false,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
