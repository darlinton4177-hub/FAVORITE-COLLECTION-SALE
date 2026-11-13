import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';
import '../services/ai_assistant_service.dart';
import '../widgets/store_image_widget.dart';
import 'product_detail_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  String _selectedLanguage = 'en'; // 'en', 'pcm', 'ig', 'yo'
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Initial greeting message from the AI Assistant (Explicitly named "Favorite")
    _messages.add(
      AIMessage(
        id: 'welcome',
        text:
            'Hello! I am Favorite.\n\n'
            'Welcome to the shop! I know about everything in our store—from our oversized blazers, slim taper jeans, and satin midi slip dresses to shoes, accessories, and fast 2–4 day delivery from our Ikom hub.\n\n'
            'What would you like to find today?',
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: const [
          '👗 Dresses & Tops Deals',
          '👖 Jeans & Blazers',
          '🚚 Shipping from Ikom Hub',
          '🏷️ Free Shipping (₦50k / \$35)',
          '🔄 30-Day Returns Policy',
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _isListening = false;
      _isLoading = true;
      _messages.add(
        AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    final store = Provider.of<StoreProvider>(context, listen: false);

    final reply = await AIAssistantService.sendMessage(
      query: query,
      availableProducts: store.products,
      availableCategories: store.categories,
      languageOverride: _selectedLanguage == 'en' ? null : _selectedLanguage,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Turn is concluded completely; stop listening until next trigger
        _isListening = false;
        _messages.add(reply);
      });
      _scrollToBottom();
    }
  }

  /// Push-to-Talk Simulation: Listen actively when triggered, then conclude turn completely
  void _togglePushToTalk() {
    if (_isListening) {
      // User tapped again to finish talking
      setState(() {
        _isListening = false;
      });
      _handleSubmitted('Tell me about your fast shipping from Ikom hub and latest fashion deals');
    } else {
      // Actively triggered by user
      setState(() {
        _isListening = true;
      });
    }
  }

  void _setLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
    String greeting;
    switch (lang) {
      case 'pcm':
        greeting =
            'How far! I am Favorite. Welcome to the shop! I know about everything inside store. Wetin you wan check out today?';
        break;
      case 'ig':
        greeting =
            'Nnọọ! Abụ m Favorite. Nnọọ n\'ụlọ ahịa anyị! Ama m banyere ngwaahịa niile dị n\'ime ụlọ ahịa. Kedu ihe ị chọrọ ịhụ taa?';
        break;
      case 'yo':
        greeting =
            'Ẹ ku abọ! Emi ni Favorite. Ẹ ku abọ si ile itaja wa! Mo mọ gbogbo ohun ti o wa ninu itaja wa. Kí ni ẹ fẹ wa loni?';
        break;
      case 'en':
      default:
        greeting =
            'Hello! I am Favorite. Welcome to the shop! I know about everything in our store. What would you like to find today?';
        break;
    }
    setState(() {
      _messages.add(
        AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: greeting,
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: const [
            '🚚 Shipping from Ikom Hub',
            '🔄 30-Day Return Policy',
            '🌸 Perfumes & Fragrances',
            '👗 Dresses & Tops Deals',
          ],
        ),
      );
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: StoreConfig.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: StoreConfig.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StoreConfig.aiAssistantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.redAccent : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isListening ? 'Listening (Tap to send)' : 'Online • Ready',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  AIMessage(
                    id: 'reset',
                    text:
                        'Session reset. Welcome to Favorite Collection! Ask me anything about our products, Ikom hub delivery, or 30-day returns.',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? StoreConfig.cardColorDark : Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Language: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                _buildLangChip('English', 'en'),
                const SizedBox(width: 6),
                _buildLangChip('Pidgin', 'pcm'),
                const SizedBox(width: 6),
                _buildLangChip('Igbo', 'ig'),
                const SizedBox(width: 6),
                _buildLangChip('Yoruba', 'yo'),
              ],
            ),
          ),

          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Favorite AI is styling your response...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          // Listening banner when push-to-talk is active
          if (_isListening)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.redAccent.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.2).animate(_pulseController),
                    child: const Icon(Icons.mic, color: Colors.redAccent, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Listening... Speak or tap Mic to conclude turn',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Input Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Push-to-Talk Mic button (Active trigger only)
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none_rounded,
                      color: _isListening ? Colors.redAccent : StoreConfig.primaryColor,
                    ),
                    tooltip: 'Push-to-Talk (Active trigger only)',
                    onPressed: _togglePushToTalk,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? 'Listening... tap mic to finish'
                            : 'Ask about dresses, perfumes, shipping...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? StoreConfig.cardColorDark : Colors.grey.shade100,
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: StoreConfig.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _handleSubmitted(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(String label, String code) {
    final isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => _setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? StoreConfig.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? StoreConfig.primaryColor : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage msg, bool isDark) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: StoreConfig.primaryColor,
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? StoreConfig.primaryColor
                        : (isDark ? StoreConfig.cardColorDark : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isUser ? Colors.white : null,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 11,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Turn completed • Idle',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),

          // Recommended Product Cards embedded in message
          if (msg.recommendedProducts.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: msg.recommendedProducts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, pIdx) {
                  final prod = msg.recommendedProducts[pIdx];
                  return _buildProductSnippet(prod, isDark);
                },
              ),
            ),
          ],

          // Quick Question Suggestion Chips
          if (!isUser && msg.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: msg.suggestions.map((sug) {
                return ActionChip(
                  label: Text(sug, style: const TextStyle(fontSize: 11)),
                  backgroundColor:
                      isDark ? StoreConfig.cardColorDark : Colors.white,
                  side: BorderSide(
                    color: StoreConfig.primaryColor.withValues(alpha: 0.3),
                  ),
                  onPressed: () => _handleSubmitted(sug),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductSnippet(Product prod, bool isDark) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? StoreConfig.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 65,
              child: StoreImageWidget(
                imagePath: prod.images.isNotEmpty ? prod.images.first : '',
                fallbackLabel: prod.title,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prod.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${StoreConfig.currencySymbol}${prod.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: StoreConfig.primaryColor,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: prod.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: StoreConfig.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
