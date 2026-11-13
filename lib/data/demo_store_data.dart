import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/banner_item.dart';
import '../models/banner_item.dart' as banner_models;
import '../config/asset_catalog.dart';

class DemoStoreData {
  static List<Category> getInitialCategories() {
    return [
      const Category(
        id: 'clothing',
        name: 'Clothing',
        description:
            'Everyday casual, stylish streetwear, and premium outfits.',
        imagePath: AssetCatalog.catClothing,
        iconData: Icons.checkroom_rounded,
      ),
      const Category(
        id: 'jeans',
        name: 'Jeans & Denim',
        description:
            'Slim fit, relaxed taper, classic distressed, and raw denim.',
        imagePath: AssetCatalog.catJeans,
        iconData: Icons.dry_cleaning_rounded,
      ),
      const Category(
        id: 'tops',
        name: 'Tops & Shirts',
        description:
            'Oxford button-downs, breathable tees, and cozy knit tops.',
        imagePath: AssetCatalog.catTops,
        iconData: Icons.layers_rounded,
      ),
      const Category(
        id: 'dresses',
        name: 'Dresses',
        description:
            'Floral midi, elegant evening, and effortless summer dresses.',
        imagePath: AssetCatalog.catDresses,
        iconData: Icons.filter_vintage_rounded,
      ),
      const Category(
        id: 'trousers',
        name: 'Trousers',
        description:
            'Tailored chinos, pleated dress slacks, and cargo joggers.',
        imagePath: AssetCatalog.catTrousers,
        iconData: Icons.style_rounded,
      ),
      const Category(
        id: 'socks',
        name: 'Socks & Hosiery',
        description:
            'Combed cotton crew socks, invisible loafers, and thermal wool.',
        imagePath: AssetCatalog.catSocks,
        iconData: Icons.all_inclusive_rounded,
      ),
      const Category(
        id: 'footwear',
        name: 'Footwear',
        description:
            'Minimalist sneakers, Chelsea boots, and leather dress shoes.',
        imagePath: AssetCatalog.catFootwear,
        iconData: Icons.skateboarding_rounded,
      ),
      const Category(
        id: 'accessories',
        name: 'Fashion Accessories',
        description:
            'Designer leather belts, aviator shades, caps, and scarves.',
        imagePath: AssetCatalog.catAccessories,
        iconData: Icons.watch_rounded,
      ),
      const Category(
        id: 'perfumes',
        name: 'Perfumes & Fragrances',
        description:
            'Long-lasting luxury ouds, signature perfumes, and fresh scented mists.',
        imagePath: AssetCatalog.catAccessories,
        iconData: Icons.spa_rounded,
      ),
    ];
  }

  static List<BannerItem> getInitialBanners() {
    return [
      const BannerItem(
        id: 'b1',
        title: 'Mid-Season Fashion Sale',
        subtitle: 'Up to 50% off select apparel & denim collections',
        imagePath: AssetCatalog.bannerHeroSale,
        targetCategoryId: 'clothing',
        badge: 'HOT DEAL • 50% OFF',
      ),
      const BannerItem(
        id: 'b2',
        title: 'Curated Streetwear Drop',
        subtitle: 'Explore authentic tops, joggers, and sneakers',
        imagePath: AssetCatalog.bannerTrending,
        targetCategoryId: 'tops',
        badge: 'NEW ARRIVALS',
      ),
      const BannerItem(
        id: 'b3',
        title: 'Weekend Style Clearance',
        subtitle: 'Huge savings on denim, dresses & accessories',
        imagePath: AssetCatalog.bannerClearance,
        targetCategoryId: 'jeans',
        badge: 'FLASH SALE',
      ),
    ];
  }

  static List<banner_models.Coupon> getDemoCoupons() {
    return const [
      banner_models.Coupon(
        code: 'FAVORITE10',
        discountPercent: 10,
        minOrderAmount: 25,
        description: '10% off on all orders over \$25',
      ),
      banner_models.Coupon(
        code: 'SAVE20',
        discountPercent: 20,
        minOrderAmount: 50,
        description: '20% off on orders over \$50',
      ),
      banner_models.Coupon(
        code: 'SUPER30',
        discountPercent: 30,
        minOrderAmount: 100,
        description: '30% VIP saving on orders over \$100',
      ),
    ];
  }

  static List<Product> getInitialProducts() {
    return const [
      Product(
        id: 'prod_001',
        title: 'Premium Tailored Oversized Blazer',
        description:
            'A structured modern silhouette crafted from breathable wool-blend fabric with clean lapels, double-breasted buttoning, and satin lining. Perfect for layering across professional and evening occasions.',
        categoryId: 'clothing',
        price: 89.99,
        originalPrice: 129.99,
        rating: 4.9,
        reviewCount: 168,
        stock: 24,
        images: [AssetCatalog.catClothing],
        availableSizes: ['S', 'M', 'L', 'XL'],
        availableColors: ['Midnight Black', 'Oatmeal Beige', 'Slate Grey'],
        isFeatured: true,
        isFlashDeal: true,
        badge: 'BESTSELLER',
        specifications: {
          'Material': '65% Wool, 35% Recycled Polyester',
          'Fit': 'Contemporary Oversized',
          'Care': 'Dry Clean Recommended',
          'Origin': 'Ethically Imported',
        },
      ),
      Product(
        id: 'prod_002',
        title: 'Vintage Washed Slim Taper Jeans',
        description:
            'Authentic 12.5oz cotton denim infused with a hint of stretch for all-day comfort. Features hand-sanded whiskering, durable copper rivets, and a versatile medium-indigo wash.',
        categoryId: 'jeans',
        price: 54.50,
        originalPrice: 79.00,
        rating: 4.8,
        reviewCount: 245,
        stock: 35,
        images: [AssetCatalog.catJeans],
        availableSizes: ['30W 32L', '32W 32L', '34W 32L', '36W 34L'],
        availableColors: ['Classic Indigo', 'Faded Washed', 'Carbon Black'],
        isFeatured: true,
        isFlashDeal: true,
        badge: 'TOP RATED',
        specifications: {
          'Fabric': '98% Cotton, 2% Elastane',
          'Rise': 'Mid Rise with Zip Fly',
          'Finish': 'Vintage Enzyme Wash',
        },
      ),
      Product(
        id: 'prod_003',
        title: 'Crisp Oxford Cotton Button-Down Shirt',
        description:
            'A wardrobe staple tailored with premium long-staple cotton yarn. Features a button-down collar, chest pocket, and garment-washed finish for an ultra-soft hand feel.',
        categoryId: 'tops',
        price: 38.00,
        originalPrice: 55.00,
        rating: 4.7,
        reviewCount: 92,
        stock: 40,
        images: [AssetCatalog.catTops],
        availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
        availableColors: ['Sky Blue', 'Crisp White', 'Pale Pink', 'Navy'],
        isFeatured: false,
        isFlashDeal: true,
        badge: 'DEAL OF THE DAY',
        specifications: {
          'Weave': 'Traditional Pinpoint Oxford',
          'Collar': 'Button-Down Collar',
          'Care': 'Machine Wash Warm, Tumble Dry Low',
        },
      ),
      Product(
        id: 'prod_004',
        title: 'Fluted Hem Satin Midi Slip Dress',
        description:
            'A liquid-drape slip dress cut on the bias to flatter effortlessly. Finished with adjustable delicate shoulder straps, subtle cowl neckline, and a gently fluted hemline.',
        categoryId: 'dresses',
        price: 64.00,
        originalPrice: 95.00,
        rating: 4.9,
        reviewCount: 310,
        stock: 18,
        images: [AssetCatalog.catDresses],
        availableSizes: ['XS', 'S', 'M', 'L'],
        availableColors: ['Emerald Green', 'Champagne Gold', 'Bordeaux Red'],
        isFeatured: true,
        isFlashDeal: false,
        badge: 'FAVORITE PICK',
        specifications: {
          'Fabric': 'Premium Heavyweight Silk Satin Finish',
          'Length': 'Midi Length (Approx 46")',
          'Details': 'Concealed Side Zipper',
        },
      ),
      Product(
        id: 'prod_005',
        title: 'Pleated Stretch Chino Trousers',
        description:
            'Modern relaxed-taper chinos designed with dual forward pleats, comfortable elasticized back waistband, and angled side slash pockets. Transition smoothly from the office to dinner.',
        categoryId: 'trousers',
        price: 48.00,
        originalPrice: 68.00,
        rating: 4.6,
        reviewCount: 115,
        stock: 22,
        images: [AssetCatalog.catTrousers],
        availableSizes: ['30', '32', '34', '36', '38'],
        availableColors: ['Khaki Tan', 'Deep Olive', 'Charcoal', 'Navy'],
        isFeatured: false,
        isFlashDeal: false,
        badge: '',
        specifications: {
          'Composition': '97% Cotton Twill, 3% Spandex',
          'Closure': 'Button & Zip Fly',
        },
      ),
      Product(
        id: 'prod_006',
        title: 'Combed Cotton Ribbed Crew Socks (5-Pack)',
        description:
            'Engineered for maximum foot comfort with cushioned footbeds, reinforced toe and heel caps, and stay-up ribbed cuffs that never slide down. Breathable and odor-resistant.',
        categoryId: 'socks',
        price: 18.50,
        originalPrice: 28.00,
        rating: 4.9,
        reviewCount: 420,
        stock: 60,
        images: [AssetCatalog.catSocks],
        availableSizes: ['One Size (Men 7-12 / Women 8-13)'],
        availableColors: [
          'Earth Tone Assortment',
          'Monochrome Pack',
          'Classic White',
        ],
        isFeatured: true,
        isFlashDeal: true,
        badge: 'VALUE BUNDLE',
        specifications: {
          'Yarn': '85% Ring-Spun Cotton, 12% Polyamide, 3% Spandex',
          'Pack Size': '5 Pairs',
        },
      ),
      Product(
        id: 'prod_007',
        title: 'Minimalist Low-Top Leather Sneakers',
        description:
            'Crafted with buttery full-grain Italian leather uppers on durable vulcanized rubber soles. Features waxed cotton laces, memory foam insoles, and subtle embossed branding.',
        categoryId: 'footwear',
        price: 98.00,
        originalPrice: 145.00,
        rating: 4.8,
        reviewCount: 188,
        stock: 15,
        images: [AssetCatalog.catFootwear],
        availableSizes: ['US 8', 'US 9', 'US 10', 'US 11', 'US 12'],
        availableColors: [
          'Pure Chalk White',
          'Triple Black',
          'Tan Suede Accent',
        ],
        isFeatured: true,
        isFlashDeal: false,
        badge: 'PREMIUM CRAFT',
        specifications: {
          'Upper': 'Full-Grain Calf Leather',
          'Sole': 'Natural Gum Rubber',
          'Lining': 'Breathable Microfiber',
        },
      ),
      Product(
        id: 'prod_008',
        title: 'Full-Grain Leather Dress Belt & Buckle',
        description:
            'A timeless essential crafted from vegetable-tanned genuine leather with burnished edge stitching and a solid brushed nickel pin buckle. Designed to age gracefully with a rich patina.',
        categoryId: 'accessories',
        price: 32.00,
        originalPrice: 48.00,
        rating: 4.7,
        reviewCount: 88,
        stock: 30,
        images: [AssetCatalog.catAccessories],
        availableSizes: ['32', '34', '36', '38', '40'],
        availableColors: ['Cognac Brown', 'Matte Black', 'Dark Espresso'],
        isFeatured: false,
        isFlashDeal: true,
        badge: 'ESSENTIAL',
        specifications: {
          'Material': '100% Top-Grain Cowhide Leather',
          'Width': '35mm (1.38 inches)',
          'Hardware': 'Antiallergic Brushed Nickel Alloy',
        },
      ),
      Product(
        id: 'prod_009',
        title: 'Royal Amber & Oud Luxury Eau De Parfum',
        description:
            'A captivating oriental fragrance featuring rich smoky oud, warm amber, damask rose, and velvety vanilla. Long-lasting sillage formulated for unforgettable presence.',
        categoryId: 'perfumes',
        price: 45.00,
        originalPrice: 70.00,
        rating: 4.9,
        reviewCount: 142,
        stock: 25,
        images: [AssetCatalog.catAccessories],
        availableSizes: ['50ml', '100ml'],
        availableColors: ['Royal Amber Edition'],
        isFeatured: true,
        isFlashDeal: true,
        badge: 'BESTSELLER',
        specifications: {
          'Fragrance Family': 'Oriental Woody',
          'Longevity': 'Up to 24 Hours',
          'Origin': 'Ikom Hub Fast Dispatch',
        },
      ),
    ];
  }
}
