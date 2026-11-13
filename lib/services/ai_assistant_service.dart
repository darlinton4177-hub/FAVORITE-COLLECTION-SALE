import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import '../config/store_config.dart';
import '../models/category.dart';
import '../models/product.dart';

class AIMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Product> recommendedProducts;
  final List<String> suggestions;

  const AIMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedProducts = const [],
    this.suggestions = const [],
  });
}

class AIAssistantService {
  /// The official system prompt specified for Favorite Collection's AI Shopping Assistant.
  static const String systemPrompt =
      'You are "Favorite", the dedicated AI Shopping Assistant for Favorite Collection. '
      'When you greet, state "Hello! I am Favorite." You possess complete knowledge of all items in the shop, '
      'including oversized blazers, vintage slim taper jeans, crisp Oxford shirts, satin midi slip dresses, '
      'pleated stretch chinos, combed cotton ribbed crew socks, minimalist low-top leather sneakers, and full-grain leather dress belts, '
      'along with sale pricing, sizes, fast dispatch from the Ikom hub (2-4 business days), 30-day easy returns, and free shipping over ₦50,000 or \$35 USD. '
      'Once you welcome the customer, ask what they want, and automatically wait for their reply before responding again. '
      'Support English, Nigerian Pidgin, Igbo, and Yoruba.';

  /// Optional Gemini API Key (can be passed via environment or settings)
  static String? geminiApiKey;

  /// Main message processor: generates a tailored shopping response based on live catalog and policies.
  static Future<AIMessage> sendMessage({
    required String query,
    required List<Product> availableProducts,
    required List<Category> availableCategories,
    String? languageOverride, // 'en', 'pcm' (pidgin), 'ig' (igbo), 'yo' (yoruba)
  }) async {
    final cleanQuery = query.trim().toLowerCase();

    // 1. Determine language
    final lang = languageOverride ?? _detectLanguage(cleanQuery);

    // 2. Try Gemini API if key is present
    if (geminiApiKey != null && geminiApiKey!.isNotEmpty) {
      try {
        final geminiReply = await _callGeminiApi(
          userMessage: query,
          products: availableProducts,
          categories: availableCategories,
          language: lang,
        );
        if (geminiReply != null && geminiReply.isNotEmpty) {
          final matchedProducts = _findRelevantProducts(cleanQuery, availableProducts);
          return AIMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: geminiReply,
            isUser: false,
            timestamp: DateTime.now(),
            recommendedProducts: matchedProducts,
            suggestions: _getSuggestionsForLang(lang),
          );
        }
      } catch (e) {
        debugPrint('Gemini API call failed, using built-in catalog engine: $e');
      }
    }

    // 3. Fallback to Built-in Dynamic Catalog & Policy Engine
    return _generateCatalogResponse(
      query: cleanQuery,
      originalText: query,
      products: availableProducts,
      categories: availableCategories,
      lang: lang,
    );
  }

  static String _detectLanguage(String text) {
    if (text.contains('how far') ||
        text.contains('wetin') ||
        text.contains('dey') ||
        text.contains('abeg') ||
        text.contains('no wahala') ||
        text.contains('fit') ||
        text.contains('pidgin')) {
      return 'pcm';
    }
    if (text.contains('kedu') ||
        text.contains('nnọọ') ||
        text.contains('nnoo') ||
        text.contains('biko') ||
        text.contains('ego') ||
        text.contains('igbo')) {
      return 'ig';
    }
    if (text.contains('bawo') ||
        text.contains('e kaabo') ||
        text.contains('kabo') ||
        text.contains('dakun') ||
        text.contains('elo') ||
        text.contains('yoruba')) {
      return 'yo';
    }
    return 'en';
  }

  static List<Product> _findRelevantProducts(String query, List<Product> products) {
    final q = query.toLowerCase();
    return products.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.categoryId.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          (q.contains('blazer') && p.title.toLowerCase().contains('blazer')) ||
          (q.contains('dress') && p.categoryId == 'dresses') ||
          (q.contains('jean') && p.categoryId == 'jeans') ||
          (q.contains('top') && p.categoryId == 'tops') ||
          (q.contains('perfume') && p.categoryId == 'perfumes') ||
          (q.contains('accessory') && p.categoryId == 'accessories') ||
          (q.contains('belt') && p.categoryId == 'accessories') ||
          (q.contains('shoe') && p.categoryId == 'footwear') ||
          (q.contains('deal') && p.isFlashDeal);
    }).take(4).toList();
  }

  static AIMessage _generateCatalogResponse({
    required String query,
    required String originalText,
    required List<Product> products,
    required List<Category> categories,
    required String lang,
  }) {
    final matchedProducts = _findRelevantProducts(query, products);
    String responseText;

    final isShipping = query.contains('ship') ||
        query.contains('delivery') ||
        query.contains('ikom') ||
        query.contains('hub') ||
        query.contains('reach');
    final isReturns = query.contains('return') ||
        query.contains('refund') ||
        query.contains('exchange') ||
        query.contains('change') ||
        query.contains('30 day');
    final isPerfumes = query.contains('perfume') ||
        query.contains('fragrance') ||
        query.contains('scent') ||
        query.contains('oud');
    final isAccessories = query.contains('accessor') ||
        query.contains('belt') ||
        query.contains('shade') ||
        query.contains('bag') ||
        query.contains('watch');
    final isDresses = query.contains('dress') || query.contains('gown');
    final isJeans = query.contains('jean') || query.contains('denim');
    final isTops = query.contains('top') || query.contains('shirt') || query.contains('tee');
    final isDeals = query.contains('deal') ||
        query.contains('sale') ||
        query.contains('discount') ||
        query.contains('cheap') ||
        query.contains('coupon');

    switch (lang) {
      case 'pcm': // Nigerian Pidgin
        if (isShipping) {
          responseText =
              'No shaking! We dey fast-ship all orders straight from our Ikom hub to anywhere for Nigeria and Cameroon within 2 to 4 days. If your order reach ₦50,000 (or \$35), shipping dey totally FREE!\n\nWetin you wan order today?';
        } else if (isReturns) {
          responseText =
              'We get 30-day easy return policy! As long as the cloth or item never wear out and the original tags still dey body, we go sort you out sharp-sharp.\n\nWetin you wan check out today?';
        } else if (isPerfumes) {
          responseText =
              'Omo, our perfumes and luxury ouds dey sweet well-well! Royal Amber Oud dey last up to 24 hours straight from Ikom!\n\nWetin be your favorite scent?';
        } else if (isDeals) {
          responseText =
              'Better deals boku! Use coupon code FAVORITE10 to collect 10% discount, or SAVE20 for 20% off. Free shipping still dey for orders from ₦50,000 up!\n\nWetin you wan put for cart?';
        } else if (matchedProducts.isNotEmpty) {
          final p = matchedProducts.first;
          responseText =
              'See better choice for you: "${p.title}" dey go for ${StoreConfig.currencySymbol}${p.price.toStringAsFixed(2)}. Fresh stock ready for dispatch from Ikom hub!\n\nWetin you think about this one?';
        } else {
          responseText =
              'How far! I am Favorite. Welcome to the shop! I know about everything in our store. Wetin you wan check out today?';
        }
        break;

      case 'ig': // Igbo
        if (isShipping) {
          responseText =
              'Nnọọ! Anyị na-ezipụ ngwaahịa ngwa ngwa site na Ikom hub anyị n\'ime ụbọchị abụọ ruo anọ gafee Nigeria na Cameroon. Ọ bụrụ na ị zụọ ihe ruru ₦50,000 (ma ọ bụ \$35), nzipu bụ n\'efu!\n\nKedu ihe ị chọrọ ịtụ taa?';
        } else if (isReturns) {
          responseText =
              'Anyị nwere iwu nloghachi dị mfe nke ụbọchị 30. Ọ bụrụhaala na eyighị uwe ahụ ma akara ya dịkwa nma, ị nwere ike weghachite ya n\'enweghị nsogbu.\n\nKedu uwe ị chọrọ ịhụ?';
        } else if (isPerfumes) {
          responseText =
              'Anyị nwere ezigbo mmanụ na-esi ísì ụtọ (perfumes na ouds okomoko). Royal Amber Oud na-anọte aka ma na-esi nnukwu ụtọ.\n\nỊ chọrọ ka m gosi gị perfumes anyị?';
        } else if (matchedProducts.isNotEmpty) {
          final p = matchedProducts.first;
          responseText =
              'Lee nhọrọ mara mma: "${p.title}" na-aga maka ${StoreConfig.currencySymbol}${p.price.toStringAsFixed(2)}. Ezi ngwaahịa si na Ikom hub!\n\nKedu ihe ọzọ ị chọrọ?';
        } else {
          responseText =
              'Nnọọ! Abụ m Favorite. Nnọọ n\'ụlọ ahịa anyị! Ama m banyere ngwaahịa niile dị n\'ime ụlọ ahịa. Kedu ihe ị chọrọ ịhụ taa?';
        }
        break;

      case 'yo': // Yoruba
        if (isShipping) {
          responseText =
              'Ẹ ku abọ! A n fi awọn ọja ranṣẹ ni kiakia lati ibudo Ikom wa si ibikibi ni orilẹ-ede Naijiria ati Cameroon laarin ọjọ meji si mẹrin. Rira to ju ₦50,000 tabi \$35 jẹ ọfẹ ọfẹ!\n\nKí ni ẹ fẹ ra loni?';
        } else if (isReturns) {
          responseText =
              'A ni eto ifapada ọja irọrun fun ọjọ ọgbọn (30 days). Niwọn igba ti asọ naa ko ba ti bajẹ ti aami rẹ si wa nibe, o le dapada laisi wahala.\n\nIru aṣọ wo ni ẹ n wa?';
        } else if (isPerfumes) {
          responseText =
              'Awọn lofinda ati olofinda oud wa dara pupọ! Royal Amber Oud n gba oorun didun to pẹ to wakati 24.\n\nṢe ẹ fẹ ki n ṣe iṣeduro lofinda fun yin?';
        } else if (matchedProducts.isNotEmpty) {
          final p = matchedProducts.first;
          responseText =
              'Wo aṣayan to dara yi: "${p.title}" wa fun ${StoreConfig.currencySymbol}${p.price.toStringAsFixed(2)}. O wa ni imurasilẹ lati ibudo Ikom!\n\nKí ni ẹ ro nipa eyi?';
        } else {
          responseText =
              'Ẹ ku abọ! Emi ni Favorite. Ẹ ku abọ si ile itaja wa! Mo mọ gbogbo ohun ti o wa ninu itaja wa. Kí ni ẹ fẹ wa loni?';
        }
        break;

      case 'en':
      default:
        if (isShipping) {
          responseText =
              'All orders are dispatched swiftly from our centralized Ikom hub, delivering across Nigeria and Cameroon within 2–4 business days. We offer FREE shipping on all orders over ₦50,000 (or \$35 USD)!\n\nWhat items would you like to order today?';
        } else if (isReturns) {
          responseText =
              'Shop with complete confidence! Favorite Collection offers a 30-day hassle-free return policy on all unworn items with original tags intact.\n\nWhat items can I help style for you today?';
        } else if (isPerfumes) {
          responseText =
              'Explore our curated collection of luxury fragrances with 24-hour longevity, dispatched directly from our Ikom hub!\n\nWould you like me to recommend a fragrance for you?';
        } else if (isAccessories) {
          responseText =
              'Our fashion accessories feature handcrafted full-grain leather belts, designer sunglasses, and premium caps tailored to complete your look.\n\nWhat kind of accessory are you looking for?';
        } else if (isDresses) {
          responseText =
              'We carry gorgeous satin midi slip dresses and elegant gowns crafted with premium breathable fabrics.\n\nWhat style or color dress are you looking for?';
        } else if (isJeans) {
          responseText =
              'Our denim collection features vintage washed slim taper jeans with flexible stretch comfort.\n\nWhat size jeans do you wear?';
        } else if (isTops) {
          responseText =
              'Discover our tailored oversized blazers and crisp Oxford button-downs for everyday elegance.\n\nWhat type of top or blazer do you prefer?';
        } else if (isDeals) {
          responseText =
              'Enjoy incredible savings! Apply coupon code FAVORITE10 for 10% off your entire cart, or SAVE20 for 20% off. Plus, get free shipping when you spend over ₦50,000!\n\nWhat items are in your cart today?';
        } else if (matchedProducts.isNotEmpty) {
          final p = matchedProducts.first;
          responseText =
              'I recommend checking out "${p.title}" at ${StoreConfig.currencySymbol}${p.price.toStringAsFixed(2)}. It is in stock and ready for fast dispatch from our Ikom hub!\n\nWould you like more details or another recommendation?';
        } else {
          responseText =
              'Hello! I am Favorite. Welcome to the shop! I know about everything in our store, including blazers, jeans, tops, dresses, chinos, socks, footwear, and accessories. What would you like to find today?';
        }
        break;
    }

    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      recommendedProducts: matchedProducts,
      suggestions: _getSuggestionsForLang(lang),
    );
  }

  static List<String> _getSuggestionsForLang(String lang) {
    switch (lang) {
      case 'pcm':
        return [
          '🚚 Ikom Hub Delivery',
          '🔄 30-Day Returns',
          '🌸 Perfumes & Ouds',
          '👗 Hot Dresses & Tops',
          '🏷️ Free Shipping (₦50k)',
        ];
      case 'ig':
        return [
          '🚚 Nzipu si Ikom Hub',
          '🔄 Nloghachi Ụbọchị 30',
          '🌸 Perfumes pụrụ iche',
          '👗 Uwe mara mma',
          '🏷️ Nzipu n\'efu (₦50k)',
        ];
      case 'yo':
        return [
          '🚚 Gbigbe lati Ikom Hub',
          '🔄 Ifapada Ọjọ 30',
          '🌸 Awọn Lofinda Didun',
          '👗 Awọn Aṣọ Titun',
          '🏷️ Gbigbe Ọfẹ (₦50k)',
        ];
      case 'en':
      default:
        return [
          '🚚 Shipping from Ikom Hub',
          '🔄 30-Day Return Policy',
          '🌸 Perfumes & Fragrances',
          '👗 Dresses & Clothing Deals',
          '🏷️ Free Shipping (₦50k / \$35)',
        ];
    }
  }

  /// Calls Google Gemini API if an API key is configured
  static Future<String?> _callGeminiApi({
    required String userMessage,
    required List<Product> products,
    required List<Category> categories,
    required String language,
  }) async {
    final catalogSummary = products
        .take(12)
        .map((p) => '${p.title} (${p.categoryId}, ${StoreConfig.currencySymbol}${p.price})')
        .join(', ');

    final prompt = '$systemPrompt\n\n'
        'Live Store Inventory: $catalogSummary\n'
        'Store Currency: ${StoreConfig.currencySymbol} (${StoreConfig.currencyCode})\n'
        'Shipping Hub: ${StoreConfig.shippingHub}\n'
        'Free Shipping: ₦${StoreConfig.freeShippingThreshold.toInt()} or \$35 USD\n'
        'Language Request: $language\n\n'
        'Customer: $userMessage\n'
        'Assistant:';

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey',
    );

    try {
      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 350,
        }
      }));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text?.trim();
      }
    } catch (e) {
      debugPrint('Gemini HTTP error: $e');
    }
    return null;
  }
}
