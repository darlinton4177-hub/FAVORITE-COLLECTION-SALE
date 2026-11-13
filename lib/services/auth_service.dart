import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpRateLimitResult {
  final bool isAllowed;
  final int remainingAttempts;
  final String? errorMessage;

  const OtpRateLimitResult({
    required this.isAllowed,
    required this.remainingAttempts,
    this.errorMessage,
  });
}

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Maximum allowed verification codes per identifier (email or phone) within 24 hours.
  static const int maxCodesPerDay = 3;

  /// Check whether an email or phone is allowed to receive a verification code today.
  static Future<OtpRateLimitResult> checkOtpRateLimit(String identifier) async {
    final cleanId = identifier.trim().toLowerCase();
    if (cleanId.isEmpty) {
      return const OtpRateLimitResult(
        isAllowed: false,
        remainingAttempts: 0,
        errorMessage: 'Please enter a valid email or phone number.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final key = 'otp_log_$cleanId';
    final existingJson = prefs.getString(key);

    List<int> timestamps = [];
    if (existingJson != null) {
      try {
        final decoded = jsonDecode(existingJson) as List<dynamic>;
        timestamps = decoded.map((e) => e as int).toList();
      } catch (_) {
        timestamps = [];
      }
    }

    // Filter to last 24 hours
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - (24 * 60 * 60 * 1000);
    timestamps = timestamps.where((ts) => ts > cutoff).toList();

    if (timestamps.length >= maxCodesPerDay) {
      return OtpRateLimitResult(
        isAllowed: false,
        remainingAttempts: 0,
        errorMessage:
            'Security Limit: This email has already received $maxCodesPerDay verification codes in the last 24 hours. Please wait before requesting another.',
      );
    }

    final remaining = maxCodesPerDay - timestamps.length;
    return OtpRateLimitResult(
      isAllowed: true,
      remainingAttempts: remaining,
    );
  }

  /// Record an OTP dispatch attempt for rate limiting.
  static Future<void> _recordOtpDispatch(String identifier) async {
    final cleanId = identifier.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    final key = 'otp_log_$cleanId';
    final existingJson = prefs.getString(key);

    List<int> timestamps = [];
    if (existingJson != null) {
      try {
        final decoded = jsonDecode(existingJson) as List<dynamic>;
        timestamps = decoded.map((e) => e as int).toList();
      } catch (_) {
        timestamps = [];
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - (24 * 60 * 60 * 1000);
    timestamps = timestamps.where((ts) => ts > cutoff).toList();
    timestamps.add(now);

    await prefs.setString(key, jsonEncode(timestamps));
  }

  /// Send verification code via Email or Phone with rate limiting (max 3/day).
  static Future<OtpRateLimitResult> sendVerificationCode({
    required String identifier,
    required bool isEmail,
  }) async {
    final rateLimit = await checkOtpRateLimit(identifier);
    if (!rateLimit.isAllowed) {
      return rateLimit;
    }

    final cleanId = identifier.trim();
    if (isEmail) {
      await _client.auth.signInWithOtp(
        email: cleanId,
        shouldCreateUser: true,
      );
    } else {
      await _client.auth.signInWithOtp(
        phone: cleanId,
        shouldCreateUser: true,
      );
    }

    // Record the successful dispatch
    await _recordOtpDispatch(identifier);

    final updatedRate = await checkOtpRateLimit(identifier);
    return updatedRate;
  }

  /// Verify 6-digit OTP code sent to Email or Phone.
  static Future<AuthResponse> verifyOtpCode({
    required String identifier,
    required String token,
    required bool isEmail,
  }) async {
    final cleanId = identifier.trim();
    final cleanToken = token.trim();

    if (isEmail) {
      return await _client.auth.verifyOTP(
        email: cleanId,
        token: cleanToken,
        type: OtpType.email,
      );
    } else {
      return await _client.auth.verifyOTP(
        phone: cleanId,
        token: cleanToken,
        type: OtpType.sms,
      );
    }
  }

  /// Register a new customer with email and password
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
