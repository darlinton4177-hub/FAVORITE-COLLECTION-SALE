import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/store_config.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsSignUp;
  final bool isMandatoryGate;
  const AuthScreen({
    super.key,
    this.initialIsSignUp = false,
    this.isMandatoryGate = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _otpIdentifierController = TextEditingController();
  final _otpCodeController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // OTP State
  bool _isCodeSent = false;
  int _remainingDailyAttempts = 3;

  @override
  void dispose() {
    _otpIdentifierController.dispose();
    _otpCodeController.dispose();
    super.dispose();
  }

  void _onSuccess() {
    if (widget.isMandatoryGate) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }

  /// Send verification code with 3-per-day rate limit
  Future<void> _handleSendOtp() async {
    final identifier = _otpIdentifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email or phone number');
      return;
    }

    final isEmail = identifier.contains('@');
    if (isEmail && !identifier.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.sendVerificationCode(
        identifier: identifier,
        isEmail: isEmail,
      );

      if (!result.isAllowed) {
        setState(() {
          _errorMessage = result.errorMessage ??
              'Limit reached: Maximum 3 verification codes per day.';
        });
        return;
      }

      setState(() {
        _isCodeSent = true;
        _remainingDailyAttempts = result.remainingAttempts;
        _successMessage =
            'A 6-digit confirmation code from Favorite Collection has been sent to $identifier. Enter the code below:';
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Verify 6-digit OTP code
  Future<void> _handleVerifyOtp() async {
    final identifier = _otpIdentifierController.text.trim();
    final token = _otpCodeController.text.trim();

    if (token.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isEmail = identifier.contains('@');
      final res = await AuthService.verifyOtpCode(
        identifier: identifier,
        token: token,
        isEmail: isEmail,
      );

      if (res.session != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verified and signed in successfully!')),
        );
        _onSuccess();
      } else {
        setState(() => _errorMessage = 'Invalid or expired code. Please try again.');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed. Please check the code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isMandatoryGate,
        title: Text(
          StoreConfig.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to ${StoreConfig.appName}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your email or phone number to receive a 6-digit verification code from Favorite Collection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Error Banner
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success Banner
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Step 1: Input Identifier
              if (!_isCodeSent) ...[
                TextFormField(
                  controller: _otpIdentifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address or Phone Number',
                    hintText: 'name@example.com or +234...',
                    prefixIcon: Icon(Icons.person_pin_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Security Rule: Maximum 3 verification codes per email per day.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoreConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Send Verification Code',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ] else ...[
                // Step 2: 6-digit Code Entry
                TextFormField(
                  controller: _otpCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    labelText: '6-Digit Verification Code',
                    hintText: '••••••',
                    counterText: '',
                    prefixIcon: Icon(Icons.key_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Codes left today: $_remainingDailyAttempts / 3',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCodeSent = false;
                          _otpCodeController.clear();
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                      child: const Text('Change Email / Phone', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoreConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Verify & Enter Store',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
