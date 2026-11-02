import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../providers/cart_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class ShopCatalogScreen extends StatelessWidget {
  final String? initialCategoryId;

  const ShopCatalogScreen({super.key, this.initialCategoryId});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final products = store.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Catalog'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: StoreConfig.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => store.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search jeans, tops, dresses, shoes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: store.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => store.setSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected:
                              store.selectedCategoryId == null ||
                              store.selectedCategoryId!.isEmpty,
                          onSelected: (_) => store.setSelectedCategory(null),
                          selectedColor: StoreConfig.primaryColor,
                          labelStyle: TextStyle(
                            color:
                                (store.selectedCategoryId == null ||
                                    store.selectedCategoryId!.isEmpty)
                                ? Colors.white
                                : null,
                            fontWeight:
                                (store.selectedCategoryId == null ||
                                    store.selectedCategoryId!.isEmpty)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      ...store.categories.map((cat) {
                        final isSel = store.selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat.name),
                            selected: isSel,
                            onSelected: (_) =>
                                store.setSelectedCategory(cat.id),
                            selectedColor: StoreConfig.primaryColor,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : null,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${products.length} Items found',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    DropdownButton<String>(
                      value: store.selectedSort,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.sort_rounded, size: 18),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'featured',
                          child: Text('Featured Deals'),
                        ),
                        DropdownMenuItem(
                          value: 'price_low',
                          child: Text('Price: Low to High'),
                        ),
                        DropdownMenuItem(
                          value: 'price_high',
                          child: Text('Price: High to Low'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Customer Rating'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) store.setSelectedSort(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No products match your criteria',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('Try modifying your search or filters'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemBuilder: (ctx, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
