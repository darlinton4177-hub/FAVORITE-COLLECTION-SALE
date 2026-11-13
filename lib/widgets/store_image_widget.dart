import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/store_config.dart';
import '../providers/store_provider.dart';

class StoreImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final String fallbackLabel;

  static const String publicStorageBase =
      'https://tgcumdlpukuhebtwbgqn.supabase.co/storage/v1/object/public/banners/';

  const StoreImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.checkroom_rounded,
    this.fallbackLabel = '',
  });

  /// Resolves raw paths into proper network URLs, asset paths, or file paths.
  static String resolveImagePath(String raw) {
    var path = raw.trim();
    if (path.isEmpty) return '';

    // 1. Full HTTPS / HTTP URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // 2. Local asset references (support both 'assets/...' and '/assets/...')
    if (path.startsWith('/assets/')) {
      path = path.substring(1);
    }
    if (path.startsWith('assets/')) {
      // Graceful mapping for legacy non-existent paths:
      // 'assets/images/cat_clothing.png' -> 'assets/images/categories/clothing.png'
      if (path.contains('cat_')) {
        return path.replaceAll('cat_', 'categories/');
      }
      // 'assets/images/banner_hero_sale.png' -> 'assets/images/banners/hero_sale.png'
      if (path.contains('banner_')) {
        final bName = path.split('banner_').last;
        if (bName.contains('hero')) return 'assets/images/banners/hero_sale.png';
        if (bName.contains('trending')) return 'assets/images/banners/trending_fashion.png';
        if (bName.contains('clearance')) return 'assets/images/banners/clearance_deals.png';
        return 'assets/images/banners/$bName';
      }
      return path;
    }

    // 3. Absolute local file on device (e.g. from photo picker)
    if (path.contains('imported_images') ||
        path.contains('data/user') ||
        path.contains('cache/')) {
      return path;
    }

    // 4. Relative Supabase storage path (e.g. "categories/clothing.png", "trending_fashion.png")
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$publicStorageBase$path';
  }

  void _recordError(BuildContext context, String url, Object error) {
    try {
      final store = Provider.of<StoreProvider>(context, listen: false);
      store.recordImageError(url, error);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveImagePath(imagePath);
    Widget content;

    if (resolved.isEmpty) {
      content = _buildPlaceholder(context);
    } else if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      content = Image.network(
        resolved,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.withValues(alpha: 0.1),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          _recordError(context, resolved, error);
          return _buildPlaceholder(context);
        },
      );
    } else if (resolved.startsWith('assets/')) {
      content = Image.asset(
        resolved,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          _recordError(context, resolved, error);
          return _buildPlaceholder(context);
        },
      );
    } else {
      final file = File(resolved);
      if (file.existsSync()) {
        content = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            _recordError(context, resolved, error);
            return _buildPlaceholder(context);
          },
        );
      } else {
        _recordError(context, resolved, 'Local image file not found on device');
        content = _buildPlaceholder(context);
      }
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(gradient: bgGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StoreConfig.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                fallbackIcon,
                color: StoreConfig.primaryColor,
                size: (height != null && height! < 100) ? 24 : 36,
              ),
            ),
            if (fallbackLabel.isNotEmpty &&
                (height == null || height! > 100)) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  fallbackLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
