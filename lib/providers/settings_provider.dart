import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  UserProfile _userProfile = const UserProfile();
  ThemeMode _themeMode = ThemeMode.system;
  bool _hasSeenOnboarding = false;
  bool _isInitialized = false;

  UserProfile get userProfile => _userProfile;
  ThemeMode get themeMode => _themeMode;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    init();
  }

  Future<void> init() async {
    _userProfile = await LocalStorageService.loadUserProfile();
    final modeStr = await LocalStorageService.loadThemeMode();
    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    _hasSeenOnboarding = await LocalStorageService.hasSeenOnboarding();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await LocalStorageService.saveUserProfile(profile);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await LocalStorageService.saveThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await LocalStorageService.setHasSeenOnboarding(true);
    notifyListeners();
  }
}
