import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Register a new customer
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'phone': phone?.trim() ?? '',
      },
    );
    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Request password recovery email
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  /// Fetch user profile from public.profiles
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  /// Check if the currently logged in user is an administrator
  static Future<bool> isCurrentUserAdmin() async {
    final profile = await fetchProfile();
    if (profile == null) return false;
    return profile['role'] == 'admin';
  }
}
