import '../config/supabase_config.dart';
import '../providers/store_provider.dart';
import '../services/supabase_store_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import 'auth/auth_screen.dart';
import 'order_history_screen.dart';
import 'wishlist_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'ai_assistant_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _secretTapCount = 0;
  Map<String, dynamic>? _liveProfile;
@override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!AuthService.isAuthenticated) {
      setState(() => _liveProfile = null);
      return;
    }

    try {
      final profile = await AuthService.fetchProfile();
      if (mounted) {
        setState(() {
          _liveProfile = profile;
        });
      }
    } finally {
      if (mounted) {
        }
    }
  }

  void _onAdminSecretTap() {
    _secretTapCount++;
    if (_secretTapCount >= 3) {
      _secretTapCount = 0;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${3 - _secretTapCount} more taps to open Admin Panel',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isLoggedIn = AuthService.isAuthenticated;
    final userName = _liveProfile?['name'] ?? (isLoggedIn ? (AuthService.currentUser?.email ?? 'Customer') : settings.userProfile.name);
    final userEmail = _liveProfile?['email'] ?? (isLoggedIn ? (AuthService.currentUser?.email ?? '') : settings.userProfile.email);
    final userPhone = _liveProfile?['phone'] ?? (isLoggedIn ? '' : settings.userProfile.phone);
    final userRole = _liveProfile?['role'] ?? 'customer';
    final isAdmin = userRole == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('My Account & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // USER ACCOUNT CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? StoreConfig.cardColorDark
                    : StoreConfig.cardColorLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoggedIn
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: isAdmin
                              ? StoreConfig.secondaryColor
                              : StoreConfig.primaryColor,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isAdmin) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: StoreConfig.secondaryColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              if (userPhone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  userPhone,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          tooltip: 'Sign Out',
                          onPressed: () async {
                            await AuthService.signOut();
                            await _loadProfile();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logged out successfully')),
                              );
                            }
                          },
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          size: 48,
                          color: StoreConfig.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome to Favorite Collection Sale',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to track orders, save wishlists, and manage your delivery addresses.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoreConfig.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In or Create Account'),
                            onPressed: () async {
                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (_) => const AuthScreen()),
                              );
                              if (result == true) {
                                await _loadProfile();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // DIRECT ADMIN PANEL ACCESS (If user has role == 'admin')
            if (isAdmin)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.dashboard_customize, color: Colors.white),
                  title: const Text(
                    'Open Store Admin Console',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Full admin access to products, orders & inventory',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),
              ),

            _buildMenuTile(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'AI Shopping Assistant',
              subtitle: 'Chat in English, Pidgin, Igbo, or Yoruba',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
                );
              },
            ),
            _buildMenuTile(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Order History',
              subtitle: 'Check order statuses and receipts',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),

            _buildMenuTile(
              context,
              icon: Icons.favorite_border,
              title: 'Wishlist & Favorites',
              subtitle: 'View saved fashion pieces',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),

            _buildMenuTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Theme Settings',
              subtitle: 'Current: ${settings.themeMode.name.toUpperCase()}',
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (mode) {
                  if (mode != null) settings.setThemeMode(mode);
                },
              ),
            ),

            _buildMenuTile(
              context,
              icon: Icons.shield_outlined,
              title: 'Store Policies',
              subtitle: 'Shipping, returns & privacy policies',
              onTap: () => _showPoliciesDialog(context),
            ),

            const SizedBox(height: 12),

            // Secret Admin Panel fallback (for non-admin users)
            if (!isAdmin)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.blueGrey,
                  ),
                  title: const Text('Store Administration'),
                  subtitle: const Text(
                    'Tap 3 times or click to access the admin panel',
                  ),
                  onTap: _onAdminSecretTap,
                ),
              ),

            
            // DIAGNOSTICS & SYSTEM STATUS
            Consumer<StoreProvider>(
              builder: (context, store, _) {
                final sourceColor = store.dataSource == DataSource.live
                    ? Colors.green
                    : (store.dataSource == DataSource.cached ? Colors.orange : Colors.red);
                final sourceLabel = store.dataSource == DataSource.live
                    ? 'LIVE (Supabase)'
                    : (store.dataSource == DataSource.cached ? 'CACHED (Offline)' : 'ERROR / OFFLINE');

                return Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242426) : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: sourceColor),
                          const SizedBox(width: 6),
                          const Text(
                            'About & Diagnostics',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: sourceColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sourceLabel,
                              style: TextStyle(
                                color: sourceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      _buildDiagRow('App Version', 'v1.0.0+1 (Release)'),
                      _buildDiagRow('Backend Host', Uri.parse(SupabaseConfig.url).host),
                      _buildDiagRow(
                        'Rows Synced',
                        'Categories: ${store.categoriesFetched} | Products: ${store.productsFetched} | Banners: ${store.bannersFetched}',
                      ),
                      if (store.firstFailingImageUrl != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Image Resolution Failure:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                store.firstFailingImageUrl!,
                                style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (store.firstFailingImageError != null)
                                Text(
                                  store.firstFailingImageError!,
                                  style: const TextStyle(fontSize: 9, color: Colors.red),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ] else ...[
                        _buildDiagRow('Image Status', 'All images resolving OK'),
                      ],
                      if (store.lastError != null && store.lastError!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Last Error: ${store.lastError}',
                            style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            Text(
              '${StoreConfig.appName} v1.0.0 (Template v1.1)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Supabase Connected • Nigeria (NGN) & Cameroon (XAF)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  
  Widget _buildDiagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? StoreConfig.cardColorDark : StoreConfig.cardColorLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: StoreConfig.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showPoliciesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Store Information & Policies'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping Policy', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(StoreConfig.shippingPolicy, style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('Returns Policy', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(StoreConfig.returnPolicy, style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(StoreConfig.termsOfService, style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
