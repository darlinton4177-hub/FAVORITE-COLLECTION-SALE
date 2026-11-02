import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../providers/cart_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/store_image_widget.dart';
import 'shop_catalog_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeStorefrontTab(),
      const ShopCatalogScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Shop',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton: _currentIndex != 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              backgroundColor: StoreConfig.primaryColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  if (cart.itemCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }
}

class HomeStorefrontTab extends StatelessWidget {
  const HomeStorefrontTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: StoreConfig.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_mall_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StoreConfig.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Curated Fashion & Deals',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShopCatalogScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => store.init(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.banners.isNotEmpty) ...[
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    itemCount: store.banners.length,
                    itemBuilder: (ctx, idx) {
                      final banner = store.banners[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            StoreImageWidget(
                              imagePath: banner.imagePath,
                              fallbackLabel: banner.title,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: StoreConfig.primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      banner.badge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    banner.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    banner.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: StoreConfig.secondaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StoreConfig.secondaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: StoreConfig.secondaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Free Delivery >\$50',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.replay_rounded,
                            size: 16,
                            color: StoreConfig.secondaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '30d Easy Returns',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 16,
                            color: StoreConfig.secondaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Authentic Quality',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Explore Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        store.setSelectedCategory(null);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ShopCatalogScreen(),
                          ),
                        );
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: store.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (ctx, idx) {
                    final cat = store.categories[idx];
                    return InkWell(
                      onTap: () {
                        store.setSelectedCategory(cat.id);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ShopCatalogScreen(initialCategoryId: cat.id),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade100,
                              border: Border.all(
                                color: StoreConfig.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: ClipOval(
                              child: StoreImageWidget(
                                imagePath: cat.imagePath,
                                fallbackIcon: cat.iconData,
                                fallbackLabel: cat.name,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (store.flashDeals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                Text(
                                  'FLASH SALE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ending Soon',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          store.setSelectedSort('featured');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ShopCatalogScreen(),
                            ),
                          );
                        },
                        child: const Text('View Deals'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: store.flashDeals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (ctx, idx) {
                      final product = store.flashDeals[idx];
                      return SizedBox(
                        width: 160,
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending & Bestsellers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        store.setSelectedCategory(null);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ShopCatalogScreen(),
                          ),
                        );
                      },
                      child: const Text('Explore More'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: store.featuredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (ctx, idx) {
                    return ProductCard(product: store.featuredProducts[idx]);
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
