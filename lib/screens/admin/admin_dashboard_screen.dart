import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/store_config.dart';
import '../../providers/store_provider.dart';
import '../../providers/order_provider.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_banners_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalProducts = store.products.length;
    final totalCategories = store.categories.length;
    final totalOrders = orderProvider.orders.length;
    final totalRevenue = orderProvider.orders.fold(
      0.0,
      (sum, o) => sum + o.total,
    );
    final lowStockCount = store.products.where((p) => p.stock < 15).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Administration (Demo)'),
        backgroundColor: StoreConfig.secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demonstration Header Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.amber, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'OFFLINE DEMO ADMIN: Changes made here (adding/editing products, updating stock, importing phone photos, modifying orders) are saved persistently on this device.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Cards Grid
            const Text(
              'Store Metrics Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildMetricCard(
                  context,
                  title: 'Demo Revenue',
                  value:
                      '${StoreConfig.currencySymbol}${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                ),
                _buildMetricCard(
                  context,
                  title: 'Orders Placed',
                  value: '$totalOrders',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  title: 'Total Products',
                  value: '$totalProducts',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.deepPurple,
                ),
                _buildMetricCard(
                  context,
                  title: 'Low Stock Alert',
                  value: '$lowStockCount items',
                  icon: Icons.warning_amber_rounded,
                  color: lowStockCount > 0 ? Colors.orange : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Management Navigation Cards
            const Text(
              'Management Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context,
              title: 'Product Catalog & Inventory',
              subtitle:
                  'Add new items, edit prices, adjust stock & pick images',
              icon: Icons.checkroom_rounded,
              trailingBadge: '$totalProducts',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminProductsScreen(),
                  ),
                );
              },
            ),
            _buildNavigationTile(
              context,
              title: 'Category Management',
              subtitle: 'Edit fashion categories and visual thumbnails',
              icon: Icons.category_rounded,
              trailingBadge: '$totalCategories',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminCategoriesScreen(),
                  ),
                );
              },
            ),
            _buildNavigationTile(
              context,
              title: 'Promotional Banners',
              subtitle: 'Manage home hero carousel slides and special deals',
              icon: Icons.view_carousel_rounded,
              trailingBadge: '${store.banners.length}',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminBannersScreen()),
                );
              },
            ),
            _buildNavigationTile(
              context,
              title: 'Order Fulfillment & Status',
              subtitle: 'Track demo customer orders and update shipping stages',
              icon: Icons.local_shipping_outlined,
              trailingBadge: '$totalOrders',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Phone Photo Picker Capability Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? StoreConfig.cardColorDark : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    color: Colors.blue,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Photo Picker Enabled (v1.1)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You can pick high-resolution fashion photographs directly from Android Phone Gallery. Images are permanently saved in local app storage.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? StoreConfig.cardColorDark : StoreConfig.cardColorLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String trailingBadge,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: StoreConfig.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: StoreConfig.secondaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
