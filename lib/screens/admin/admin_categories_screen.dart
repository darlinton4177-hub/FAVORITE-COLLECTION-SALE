import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/store_config.dart';
import '../../models/category.dart';
import '../../providers/store_provider.dart';
import '../../widgets/store_image_widget.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final categories = store.categories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories (${categories.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () => _showCategoryDialog(context, store),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          final cat = categories[index];
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
                    width: 50,
                    height: 50,
                    child: StoreImageWidget(
                      imagePath: cat.imagePath,
                      fallbackIcon: cat.iconData,
                      fallbackLabel: cat.name,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${cat.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: StoreConfig.secondaryColor,
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
                  tooltip: 'Replace Category Image',
                  onPressed: () async {
                    final path = await store.pickImageFromGallery();
                    if (path != null) {
                      store.updateCategory(cat.copyWith(imagePath: path));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () =>
                      _showCategoryDialog(context, store, category: cat),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    store.deleteCategory(cat.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, store),
        backgroundColor: StoreConfig.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Category',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    StoreProvider store, {
    Category? category,
  }) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');
    String imagePath = category?.imagePath ?? '';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(category != null ? 'Edit Category' : 'Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 50,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final id =
                    category?.id ??
                    nameCtrl.text.trim().toLowerCase().replaceAll(
                      RegExp(r'\s+'),
                      '_',
                    );

                final newCat = Category(
                  id: id,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imagePath: imagePath,
                  iconData: category?.iconData ?? Icons.category_rounded,
                );

                if (category != null) {
                  store.updateCategory(newCat);
                } else {
                  store.addCategory(newCat);
                }
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
