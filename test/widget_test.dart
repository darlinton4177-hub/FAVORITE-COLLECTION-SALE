import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:favorite_collection_sale/config/store_config.dart';
import 'package:favorite_collection_sale/data/demo_store_data.dart';
import 'package:favorite_collection_sale/models/product.dart';
import 'package:favorite_collection_sale/providers/cart_provider.dart';
import 'package:favorite_collection_sale/providers/store_provider.dart';
import 'package:favorite_collection_sale/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Store Configuration and Demo Data Tests', () {
    test('Store configuration branding is set properly', () {
      expect(StoreConfig.appName, 'Favorite Collection Sale');
      expect(StoreConfig.demoAdminPin, '1234');
      expect(StoreConfig.currencySymbol, '\$');
      expect(StoreConfig.freeShippingThreshold, 50.0);
    });

    test('Initial fashion categories contain required segments', () {
      final categories = DemoStoreData.getInitialCategories();
      final categoryIds = categories.map((c) => c.id).toList();

      expect(categoryIds, contains('clothing'));
      expect(categoryIds, contains('jeans'));
      expect(categoryIds, contains('tops'));
      expect(categoryIds, contains('dresses'));
      expect(categoryIds, contains('trousers'));
      expect(categoryIds, contains('socks'));
      expect(categoryIds, contains('footwear'));
      expect(categoryIds, contains('accessories'));
    });

    test('Initial products are loaded and have correct attributes', () {
      final products = DemoStoreData.getInitialProducts();
      expect(products.isNotEmpty, true);

      final blazer = products.firstWhere((p) => p.id == 'prod_001');
      expect(blazer.title, contains('Blazer'));
      expect(blazer.inStock, true);
      expect(blazer.discountPercentage, greaterThan(0));
      expect(blazer.availableSizes, isNotEmpty);
      expect(blazer.availableColors, isNotEmpty);
    });
  });

  group('Cart Provider & Calculations Tests', () {
    test('Cart additions, quantities, coupons, and totals work accurately', () {
      final cart = CartProvider();
      const product = Product(
        id: 'test_1',
        title: 'Denim Jacket',
        description: 'Test jacket',
        categoryId: 'clothing',
        price: 40.0,
        originalPrice: 60.0,
        stock: 5,
        images: [],
      );

      // Initial state
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0.0);

      // Add 1 item
      cart.addToCart(
        product,
        quantity: 1,
        selectedSize: 'M',
        selectedColor: 'Blue',
      );
      expect(cart.itemCount, 1);
      expect(cart.subtotal, 40.0);
      // Below $50 threshold -> standard shipping applied
      expect(cart.shippingFee, StoreConfig.standardShippingFee);

      // Add another identical item (should increment quantity)
      cart.addToCart(
        product,
        quantity: 1,
        selectedSize: 'M',
        selectedColor: 'Blue',
      );
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 80.0);
      // Over $50 threshold -> free shipping
      expect(cart.shippingFee, 0.0);

      // Apply coupon FAVORITE10 (10% off)
      final applied = cart.applyCoupon('FAVORITE10');
      expect(applied, true);
      expect(cart.discount, 8.0); // 10% of 80 is 8

      // Verify tax & total
      final expectedTax = (80.0 - 8.0) * StoreConfig.estimatedTaxRate;
      expect(cart.estimatedTax, closeTo(expectedTax, 0.001));
      expect(cart.totalAmount, closeTo(72.0 + expectedTax, 0.001));

      // Remove item
      final key = cart.cartList.first.uniqueId;
      cart.removeItem(key);
      expect(cart.itemCount, 0);
      expect(cart.totalAmount, 0.0);
    });
  });

  group('Widget Tests', () {
    testWidgets('ProductCard renders title, price, and responds to taps', (
      WidgetTester tester,
    ) async {
      const product = Product(
        id: 'widget_prod',
        title: 'Slim Fit Denim',
        description: 'Quality stretch denim',
        categoryId: 'jeans',
        price: 49.99,
        originalPrice: 79.99,
        rating: 4.8,
        reviewCount: 30,
        stock: 10,
        images: [],
        badge: 'SALE',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => StoreProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: ProductCard(product: product),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Slim Fit Denim'), findsWidgets);
      expect(find.text('\$49.99'), findsOneWidget);
      expect(find.text('SALE'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);
    });
  });
}
