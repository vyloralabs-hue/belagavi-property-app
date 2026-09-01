import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

/// Resilient Canonical Property Image Widget that handles:
/// 1. Remote URLs (http/https/blob)
/// 2. Local device files (file://, /data/... on mobile, drive paths on desktop)
/// 3. Supabase Storage relative paths (properties/...)
/// 4. Graceful fallback artwork with retry option and zero Flutter broken-image icons
class AppPropertyImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onRetry;

  const AppPropertyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.onRetry,
  });

  static const String _supabaseStorageBase = 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/';

  String get _resolvedUrl {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      return url;
    }
    if (_isLocalFile) {
      return url;
    }
    // Relative Supabase path
    if (url.startsWith('/')) {
      return '$_supabaseStorageBase${url.substring(1)}';
    }
    return '$_supabaseStorageBase$url';
  }

  bool get _isNetworkUrl {
    final url = _resolvedUrl;
    return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:');
  }

  bool get _isLocalFile {
    if (kIsWeb) return false;
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return false;
    return url.startsWith('/') ||
        url.startsWith('file://') ||
        url.contains(r'\') ||
        url.contains('/data/user/') ||
        url.contains('/storage/emulated/') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(url);
  }

  String get _cleanFilePath {
    final url = imageUrl?.trim() ?? '';
    return url.replaceFirst('file://', '');
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      content = _buildDefaultPlaceholder(context);
    } else if (_isNetworkUrl) {
      content = Image.network(
        _resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF1B2330),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppDesignSystem.brandGold,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorFallback(context);
        },
      );
    } else if (_isLocalFile) {
      final file = File(_cleanFilePath);
      if (file.existsSync()) {
        content = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorFallback(context);
          },
        );
      } else {
        content = _buildDefaultPlaceholder(context);
      }
    } else {
      content = _buildDefaultPlaceholder(context);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B2330),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_rounded,
              size: (height != null && height! < 100) ? 28 : 48,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
            ),
            if (height == null || height! >= 120) ...[
              const SizedBox(height: 6),
              Text(
                'Belagavi Property',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B2330),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: (height != null && height! < 100) ? 24 : 36,
              color: AppDesignSystem.brandGold.withValues(alpha: 0.7),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onRetry,
                child: const Text(
                  'Tap to retry',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppDesignSystem.brandGold,
                    fontWeight: FontWeight.bold,
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
