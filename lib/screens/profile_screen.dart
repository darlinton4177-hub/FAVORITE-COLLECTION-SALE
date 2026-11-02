import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../providers/settings_provider.dart';
import 'order_history_screen.dart';
import 'wishlist_screen.dart';
import 'admin/admin_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _secretTapCount = 0;

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
            '${3 - _secretTapCount} more taps to open Admin Panel demo',
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
    final user = settings.userProfile;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: StoreConfig.primaryColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'U',
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
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditProfileDialog(context, settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuTile(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Order History',
              subtitle: 'Check order statuses and demo receipts',
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
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
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
                title: const Text('Store Administration (Demo)'),
                subtitle: const Text(
                  'Tap 3 times or click to enter demo admin panel (PIN: 1234)',
                ),
                onTap: _onAdminSecretTap,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '${StoreConfig.appName} v1.0.0 (Template v1.1)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Offline demonstration ready • No live cards charged',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
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
              Text(
                'Shipping Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(StoreConfig.shippingPolicy, style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text(
                'Returns Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(StoreConfig.returnPolicy, style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text(
                'Demo Terms & Conditions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

  void _showEditProfileDialog(BuildContext context, SettingsProvider settings) {
    final nameCtrl = TextEditingController(text: settings.userProfile.name);
    final emailCtrl = TextEditingController(text: settings.userProfile.email);
    final phoneCtrl = TextEditingController(text: settings.userProfile.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Customer Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.updateUserProfile(
                settings.userProfile.copyWith(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
