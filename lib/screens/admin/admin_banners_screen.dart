import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/store_config.dart';
import '../../models/banner_item.dart';
import '../../providers/store_provider.dart';
import '../../widgets/store_image_widget.dart';

class AdminBannersScreen extends StatelessWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final banners = store.banners;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hero Banners (${banners.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Banner',
            onPressed: () => _showBannerDialog(context, store),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: banners.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          final banner = banners[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? StoreConfig.cardColorDark
                  : StoreConfig.cardColorLight,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 70,
                    height: 50,
                    child: StoreImageWidget(
                      imagePath: banner.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        banner.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Badge: ${banner.badge}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: StoreConfig.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: Colors.blue,
                  ),
                  tooltip: 'Replace Banner Photo',
                  onPressed: () async {
                    final path = await store.pickImageFromGallery();
                    if (path != null) {
                      store.updateBanner(
                        BannerItem(
                          id: banner.id,
                          title: banner.title,
                          subtitle: banner.subtitle,
                          imagePath: path,
                          targetCategoryId: banner.targetCategoryId,
                          badge: banner.badge,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () => store.deleteBanner(banner.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerDialog(context, store),
        backgroundColor: StoreConfig.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Banner', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showBannerDialog(BuildContext context, StoreProvider store) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final badgeCtrl = TextEditingController(text: 'SPECIAL OFFER');
    String imagePath = '';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Promotional Banner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Banner Title'),
                ),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle / Description',
                  ),
                ),
                TextField(
                  controller: badgeCtrl,
                  decoration: const InputDecoration(labelText: 'Badge Text'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 70,
                        height: 50,
                        child: StoreImageWidget(imagePath: imagePath),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final path = await store.pickImageFromGallery();
                        if (path != null) {
                          setState(() => imagePath = path);
                        }
                      },
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: const Text('Pick Image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final newBanner = BannerItem(
                  id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  imagePath: imagePath,
                  badge: badgeCtrl.text.trim(),
                );
                store.addBanner(newBanner);
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
