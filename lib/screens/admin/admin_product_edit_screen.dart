import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/store_config.dart';
import '../../config/asset_catalog.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../widgets/store_image_widget.dart';

class AdminProductEditScreen extends StatefulWidget {
  final Product? product;

  const AdminProductEditScreen({super.key, this.product});

  @override
  State<AdminProductEditScreen> createState() => _AdminProductEditScreenState();
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _origPriceController;
  late TextEditingController _stockController;
  late TextEditingController _badgeController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;

  late String _selectedCategoryId;
  late List<String> _images;
  bool _isFeatured = false;
  bool _isFlashDeal = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p?.price.toString() ?? '39.99',
    );
    _origPriceController = TextEditingController(
      text: p?.originalPrice.toString() ?? '59.99',
    );
    _stockController = TextEditingController(text: p?.stock.toString() ?? '20');
    _badgeController = TextEditingController(text: p?.badge ?? '');
    _sizesController = TextEditingController(
      text: p?.availableSizes.join(', ') ?? 'S, M, L, XL',
    );
    _colorsController = TextEditingController(
      text: p?.availableColors.join(', ') ?? 'Black, White, Blue',
    );

    _selectedCategoryId = p?.categoryId ?? 'clothing';
    _images = p != null ? List.from(p.images) : [AssetCatalog.catClothing];
    _isFeatured = p?.isFeatured ?? false;
    _isFlashDeal = p?.isFlashDeal ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _origPriceController.dispose();
    _stockController.dispose();
    _badgeController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Fashion Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section (Bundled or Phone Gallery)
              const Text(
                'Product Images',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (ctx, idx) {
                    if (idx == _images.length) {
                      return InkWell(
                        onTap: () => _showImageSourceDialog(store),
                        child: Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final imgPath = _images[idx];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 100,
                            height: 120,
                            child: StoreImageWidget(
                              imagePath: imgPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              if (_images.length > 1) {
                                setState(() => _images.removeAt(idx));
                              }
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Form fields
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: store.categories.any(
                  (c) => c.id == _selectedCategoryId,
                )
                    ? _selectedCategoryId
                    : (store.categories.isNotEmpty
                        ? store.categories.first.id
                        : null),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: store.categories.map((cat) {
                  return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategoryId = val);
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Sale Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => double.tryParse(val ?? '') == null
                          ? 'Invalid price'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _origPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Original Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => double.tryParse(val ?? '') == null
                          ? 'Invalid price'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Qty',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => int.tryParse(val ?? '') == null
                          ? 'Invalid stock'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _badgeController,
                decoration: const InputDecoration(
                  labelText: 'Promo Badge (e.g. FLASH DEAL, BESTSELLER)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _sizesController,
                decoration: const InputDecoration(
                  labelText: 'Available Sizes (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _colorsController,
                decoration: const InputDecoration(
                  labelText: 'Available Colors (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Detailed Product Description',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter description'
                    : null,
              ),
              const SizedBox(height: 14),

              SwitchListTile(
                title: const Text('Featured on Homepage'),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              SwitchListTile(
                title: const Text('Include in Flash Deals'),
                value: _isFlashDeal,
                onChanged: (val) => setState(() => _isFlashDeal = val),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Product' : 'Create Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoreConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(StoreProvider store) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: StoreConfig.primaryColor,
              ),
              title: const Text(
                'Pick Photo from Phone Gallery (Android Picker)',
              ),
              subtitle: const Text(
                'Imports high-res photo to app persistent storage',
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                final path = await store.pickImageFromGallery();
                if (path != null && mounted) {
                  setState(() => _images.add(path));
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.collections_bookmark_outlined,
                color: StoreConfig.secondaryColor,
              ),
              title: const Text('Choose from Bundled Assets'),
              subtitle: const Text('Select pre-packaged fashion catalog asset'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showBundledAssetsPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBundledAssetsPicker() {
    final assets = AssetCatalog.categoryImages.values.toList();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Select Bundled Asset'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: assets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (c, i) => InkWell(
              onTap: () {
                setState(() => _images.add(assets[i]));
                Navigator.of(dialogCtx).pop();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: StoreImageWidget(
                  imagePath: assets[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final store = Provider.of<StoreProvider>(context, listen: false);

    final sizes = _sizesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final colors = _colorsController.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final newProduct = Product(
      id: widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
      price: double.parse(_priceController.text.trim()),
      originalPrice: double.parse(_origPriceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      images: _images.isNotEmpty ? _images : [AssetCatalog.catClothing],
      availableSizes: sizes,
      availableColors: colors,
      badge: _badgeController.text.trim(),
      isFeatured: _isFeatured,
      isFlashDeal: _isFlashDeal,
      rating: widget.product?.rating ?? 4.8,
      reviewCount: widget.product?.reviewCount ?? 10,
    );

    if (widget.product != null) {
      store.updateProduct(newProduct);
    } else {
      store.addProduct(newProduct);
    }

    Navigator.of(context).pop();
  }
}
