import 'dart:io';
import 'package:flutter/material.dart';
import '../config/store_config.dart';

class StoreImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final String fallbackLabel;

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

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (imagePath.isEmpty) {
      content = _buildPlaceholder(context);
    } else if (imagePath.startsWith('/') ||
        imagePath.contains('imported_images') ||
        imagePath.contains('data/user')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        content = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholder(context),
        );
      } else {
        content = _buildPlaceholder(context);
      }
    } else {
      content = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(context),
      );
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
