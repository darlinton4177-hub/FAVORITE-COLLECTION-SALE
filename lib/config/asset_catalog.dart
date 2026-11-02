class AssetCatalog {
  // App Branding
  static const String appLogo = 'assets/images/logo.png';

  // Promotional Banners
  static const String bannerHeroSale = 'assets/images/banners/hero_sale.png';
  static const String bannerTrending =
      'assets/images/banners/trending_fashion.png';
  static const String bannerClearance =
      'assets/images/banners/clearance_deals.png';

  // Categories
  static const String catClothing = 'assets/images/categories/clothing.png';
  static const String catJeans = 'assets/images/categories/jeans.png';
  static const String catTops = 'assets/images/categories/tops.png';
  static const String catDresses = 'assets/images/categories/dresses.png';
  static const String catTrousers = 'assets/images/categories/trousers.png';
  static const String catSocks = 'assets/images/categories/socks.png';
  static const String catFootwear = 'assets/images/categories/footwear.png';
  static const String catAccessories =
      'assets/images/categories/accessories.png';

  // Bundled Categories Map
  static const Map<String, String> categoryImages = {
    'clothing': catClothing,
    'jeans': catJeans,
    'tops': catTops,
    'dresses': catDresses,
    'trousers': catTrousers,
    'socks': catSocks,
    'footwear': catFootwear,
    'accessories': catAccessories,
  };

  // Bundled Banners List
  static const List<String> defaultBanners = [
    bannerHeroSale,
    bannerTrending,
    bannerClearance,
  ];
}
